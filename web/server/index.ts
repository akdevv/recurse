import { Hono } from "hono";
import { serve } from "@hono/node-server";
import { serveStatic } from "@hono/node-server/serve-static";
import { relative, join } from "node:path";
import { db, nowIso, addXp, ROOT } from "./db.ts";
import * as C from "./content.ts";
import { judge } from "./judge/judge.ts";
import {
  me,
  moduleViews,
  nextAction,
  problemStatuses,
  topicStatus,
  topicWrapped,
  activityMap,
} from "./progress.ts";
import { localDate } from "./engine/dates.ts";
import { unlocks } from "./engine/hints.ts";
import {
  outcomeOf,
  solveXp,
  QUIZ_XP_PER_CORRECT,
  EXPLAIN_XP,
  REVIEW_XP,
  GRADE_XP_PER_POINT,
} from "./engine/xp.ts";
import { firstReview, nextReview, INTERVALS } from "./engine/srs.ts";
import { gradeExplain, tutorReply } from "./ai.ts";
import { chestsView, maybeSolveChest, openChest } from "./chests.ts";
import {
  noteActivity,
  notifyStatus,
  schedule,
  send,
  snooze,
  subscribe,
  unsubscribe,
} from "./notify.ts";
import {
  abandonBoss,
  activeRunForAttempt,
  bossState,
  deadline,
  finishBoss,
  markSolved,
  startBoss,
} from "./boss.ts";
import { patterns, stats } from "./stats.ts";
import { rewards, setAvailed } from "./rewards.ts";
import { getSettings, saveSettings } from "./settings.ts";
import type {
  EarnedChest,
  JudgeResult,
  Outcome,
  Settings,
} from "../shared/types.ts";

type Attempt = {
  id: number;
  problem_id: string;
  started_at: string;
  finished_at: string | null;
  active_seconds: number;
  hints_used: number;
  solution_viewed: number;
  approach: string;
  code: string | null;
  outcome: string | null;
  explain: string | null;
};

const app = new Hono();
const api = new Hono();

const latestAttempt = (pid: string) =>
  db
    .prepare(
      "SELECT * FROM attempts WHERE problem_id = ? ORDER BY id DESC LIMIT 1",
    )
    .get(pid) as Attempt | undefined;
const openAttempt = (pid: string) =>
  db
    .prepare(
      "SELECT * FROM attempts WHERE problem_id = ? AND finished_at IS NULL ORDER BY id DESC LIMIT 1",
    )
    .get(pid) as Attempt | undefined;
const everSolved = (pid: string) =>
  !!db
    .prepare(
      "SELECT 1 FROM attempts WHERE problem_id = ? AND outcome IS NOT NULL",
    )
    .get(pid);
const explainOf = (tid: string) =>
  (
    db
      .prepare("SELECT explain FROM topic_progress WHERE topic_id = ?")
      .get(tid) as { explain: string | null } | undefined
  )?.explain ?? "";
const addReview = (type: "problem" | "topic", id: string, outcome: Outcome) => {
  const r = firstReview(outcome, localDate());
  db.prepare(
    "INSERT OR IGNORE INTO reviews (item_type, item_id, interval_idx, due) VALUES (?, ?, ?, ?)",
  ).run(type, id, r.idx, r.due);
};
const logSubmission = (
  attemptId: number,
  kind: "run" | "submit",
  res: JudgeResult,
  code: string,
) =>
  db
    .prepare(
      "INSERT INTO submissions (attempt_id, ts, kind, verdict, passed, total, code) VALUES (?, ?, ?, ?, ?, ?, ?)",
    )
    .run(attemptId, nowIso(), kind, res.verdict, res.passed, res.total, code);

api.get("/home", (c) =>
  c.json({ me: me(), next: nextAction(), activity: activityMap() }),
);
api.get("/me", (c) => c.json(me()));
api.get("/stats", (c) => c.json(stats()));
api.get("/rewards", (c) => c.json(rewards()));
api.get("/patterns", (c) => c.json(patterns()));
api.post("/rewards/:id/availed", async (c) => {
  const { availed } = await c.req.json<{ availed: boolean }>();
  setAvailed(c.req.param("id"), availed);
  return c.json(rewards());
});
api.get("/boss/:mid", (c) => {
  const s = bossState(c.req.param("mid"));
  return s ? c.json(s) : c.notFound();
});
api.post("/boss/:mid/start", (c) => c.json(startBoss(c.req.param("mid"))));
api.post("/boss/runs/:id/abandon", (c) => {
  abandonBoss(Number(c.req.param("id")));
  return c.json({ ok: true });
});
api.post("/boss/runs/:id/finish", async (c) => {
  const { text } = await c.req.json<{ text: string }>();
  if (text.trim().length < 40)
    return c.json({ error: "Explain it in a few sentences first." }, 400);
  return c.json(await finishBoss(Number(c.req.param("id")), text));
});
api.get("/chests", (c) => c.json(chestsView()));
api.post("/chests/:id/open", (c) =>
  c.json({ reward: openChest(Number(c.req.param("id"))) }),
);
api.get("/settings", (c) => c.json(getSettings()));
api.put("/settings", async (c) => {
  const s = saveSettings(await c.req.json<Partial<Settings>>());
  schedule();
  return c.json(s);
});
api.get("/notify", (c) => c.json(notifyStatus()));
api.post("/notify/subscribe", async (c) => {
  subscribe(await c.req.json());
  return c.json(notifyStatus());
});
api.post("/notify/unsubscribe", async (c) => {
  unsubscribe((await c.req.json<{ endpoint: string }>()).endpoint);
  return c.json(notifyStatus());
});
api.post("/notify/test", async (c) => {
  await send("test", {
    title: "Reminders are on",
    body: "This is what a nudge looks like. Tap to open Recurse.",
    url: "/",
  });
  return c.json({ ok: true });
});
api.post("/notify/snooze", (c) => {
  snooze();
  return c.json(notifyStatus());
});
api.get("/course", (c) =>
  c.json({ course: C.course(), modules: moduleViews() }),
);

api.post("/activity", async (c) => {
  const { seconds, problemId } = await c.req.json<{
    seconds: number;
    problemId?: string;
  }>();
  const s = Math.max(0, Math.min(120, Math.round(seconds)));
  noteActivity();
  if (!s) return c.json(me().today);
  db.prepare(
    "INSERT INTO activity (date, seconds) VALUES (?, ?) ON CONFLICT(date) DO UPDATE SET seconds = seconds + excluded.seconds",
  ).run(localDate(), s);
  if (problemId)
    db.prepare(
      "UPDATE attempts SET active_seconds = active_seconds + ? WHERE problem_id = ? AND finished_at IS NULL",
    ).run(s, problemId);
  return c.json(me().today);
});

api.get("/topics/:id", (c) => {
  const t = C.topic(c.req.param("id"));
  if (!t) return c.notFound();
  const statuses = problemStatuses();
  const status = topicStatus(t, statuses);
  const home = C.modules().find((m) => m.topics.includes(t.id))!;
  return c.json({
    topic: t,
    module: {
      id: home.id,
      title: home.title,
      number: home.number,
      topicIndex: home.topics.indexOf(t.id),
      topicCount: home.topics.length,
    },
    content: t.status === "ready" ? C.topicContent(t.id) : null,
    status,
    wrapped: status.complete ? topicWrapped(t) : null,
    explain: explainOf(t.id),
    problems: t.problems.map((ref) => {
      if (!C.hasProblem(ref.id))
        return {
          ...ref,
          available: false,
          title: ref.id,
          difficulty: null,
          lc: null,
          status: "new",
        };
      const p = C.problem(ref.id);
      return {
        ...ref,
        available: true,
        title: p.title,
        difficulty: p.difficulty,
        lc: p.lc,
        status: statuses[ref.id] ?? "new",
      };
    }),
  });
});

const upsertTopic = (tid: string, col: string, val: unknown) =>
  db
    .prepare(
      `INSERT INTO topic_progress (topic_id, ${col}) VALUES (?, ?) ON CONFLICT(topic_id) DO UPDATE SET ${col} = excluded.${col}`,
    )
    .run(tid, val as any);

api.post("/topics/:id/lesson-done", (c) => {
  upsertTopic(c.req.param("id"), "lesson_done_at", nowIso());
  return c.json({ ok: true });
});

api.post("/topics/:id/quiz", async (c) => {
  const tid = c.req.param("id");
  const { answers } = await c.req.json<{ answers: number[] }>();
  const quiz = C.quiz(tid);
  const correct = quiz.map((q, i) => answers[i] === q.answer);
  const score = correct.filter(Boolean).length;
  const prev =
    (
      db
        .prepare("SELECT quiz_best FROM topic_progress WHERE topic_id = ?")
        .get(tid) as { quiz_best: number | null } | undefined
    )?.quiz_best ?? 0;
  // XP only for beating your best, so re-taking can't be farmed
  const xp = addXp(
    Math.max(0, score - Math.round(prev * quiz.length)) * QUIZ_XP_PER_CORRECT,
    "quiz",
    tid,
  );
  if (score / quiz.length > prev)
    upsertTopic(tid, "quiz_best", score / quiz.length);
  return c.json({ correct, score, total: quiz.length, xp });
});

api.post("/topics/:id/explain", async (c) => {
  const tid = c.req.param("id");
  const { text } = await c.req.json<{ text: string }>();
  if (text.trim().length < 40)
    return c.json({ error: "Write at least a few sentences." }, 400);
  const first = !explainOf(tid);
  db.prepare(
    `INSERT INTO topic_progress (topic_id, explain, explain_at) VALUES (?, ?, ?)
    ON CONFLICT(topic_id) DO UPDATE SET explain = excluded.explain, explain_at = excluded.explain_at`,
  ).run(tid, text, nowIso());
  if (first) addReview("topic", tid, "solved");
  return c.json({
    ok: true,
    xp: first ? addXp(EXPLAIN_XP, "explain", tid) : 0,
  });
});

const tutorMessages = (attemptId: number) =>
  db
    .prepare(
      "SELECT role, text FROM tutor_messages WHERE attempt_id = ? ORDER BY id",
    )
    .all(attemptId) as { role: "user" | "tutor"; text: string }[];

api.post("/problems/:id/tutor", async (c) => {
  const pid = c.req.param("id");
  const { message, code } = await c.req.json<{
    message: string;
    code?: string;
  }>();
  const text = (message ?? "").trim().slice(0, 1500);
  const a = openAttempt(pid);
  if (!a) return c.json({ error: "Start the problem first." }, 400);
  if (code !== undefined) {
    // autosave is debounced: use the code on screen right now
    db.prepare("UPDATE attempts SET code = ? WHERE id = ?").run(code, a.id);
    a.code = code;
  }
  if (activeRunForAttempt(a.id))
    return c.json({ error: "No tutor in a boss fight." }, 403);
  if (a.hints_used < 1)
    return c.json({ error: "The tutor opens after you reveal hint 1." }, 403);
  if (!text) return c.json({ error: "Ask something first." }, 400);
  const p = C.problem(pid);
  const history = [...tutorMessages(a.id), { role: "user" as const, text }];
  let reply: string;
  try {
    reply = await tutorReply({
      title: p.title,
      statement: C.statement(pid)
        .replace(/<[^>]+>/g, " ")
        .replace(/&[a-z#0-9]+;/g, " ")
        .replace(/\s+/g, " "),
      hints: p.hints.slice(0, a.hints_used),
      code: a.code ?? p.starter,
      history,
    });
  } catch (e) {
    console.error("tutor failed:", e);
    return c.json(
      { error: "The tutor is unavailable right now. Try again in a minute." },
      503,
    );
  }
  const ins = db.prepare(
    "INSERT INTO tutor_messages (attempt_id, ts, role, text) VALUES (?, ?, ?, ?)",
  );
  ins.run(a.id, nowIso(), "user", text);
  ins.run(a.id, nowIso(), "tutor", reply);
  return c.json({ messages: tutorMessages(a.id) });
});

function problemView(pid: string) {
  const { problem: p, statement, files } = C.loadProblem(pid);
  const a = latestAttempt(pid);
  const home = C.problemHome(pid);
  const finished = !!a?.finished_at;
  // a boss fight is a mock interview (until explained, even after Accepted): no hints, solutions or tutor
  const boss = a ? activeRunForAttempt(a.id) : undefined;
  const showSolutions = !boss && (everSolved(pid) || !!a?.solution_viewed);
  const { solutions, hints, lcHints, ...meta } = p;
  return {
    problem: meta,
    statement,
    home: home && {
      moduleId: home.module.id,
      topicId: home.topic.id,
      topicTitle: home.topic.title,
      role: home.role,
    },
    status: problemStatuses()[pid] ?? "new",
    attempt: a && {
      id: a.id,
      activeSeconds: a.active_seconds,
      hintsUsed: a.hints_used,
      solutionViewed: !!a.solution_viewed,
      code: a.code ?? p.starter,
      finished,
      outcome: a.outcome,
      explain: a.explain ?? "",
    },
    unlocks: boss
      ? {
          hintsAvailable: 0,
          nextHintAt: null,
          solutionAvailable: false,
          solutionAt: 0,
        }
      : unlocks(a && !finished ? a.active_seconds : 0, hints.length),
    boss: boss && {
      runId: boss.id,
      moduleId: boss.module_id,
      deadline: deadline(boss),
    },
    hintCount: hints.length,
    hints: hints.slice(0, finished ? hints.length : (a?.hints_used ?? 0)),
    solutionCount: solutions.length,
    solutions: showSolutions
      ? solutions.map((s) => ({ ...s, ...files(s.id) }))
      : null,
    explainKeyPoints: finished ? p.explain.keyPoints : null,
    tutor: {
      unlocked: !boss && !!a && a.hints_used >= 1,
      open: !boss && !!a && !finished && a.hints_used >= 1,
      messages: a ? tutorMessages(a.id) : [],
    },
    submissions: a
      ? db
          .prepare(
            "SELECT id, ts, kind, verdict, passed, total FROM submissions WHERE attempt_id = ? ORDER BY id DESC LIMIT 20",
          )
          .all(a.id)
      : [],
  };
}

api.get("/problems/:id", (c) =>
  C.hasProblem(c.req.param("id"))
    ? c.json(problemView(c.req.param("id")))
    : c.notFound(),
);

// continue the latest attempt; "fresh" starts a new one after a finished attempt
api.post("/problems/:id/start", async (c) => {
  const pid = c.req.param("id");
  const { fresh } = await c.req
    .json<{ fresh?: boolean }>()
    .catch(() => ({ fresh: false }));
  const latest = latestAttempt(pid);
  if (!latest || (fresh && latest.finished_at)) {
    db.prepare(
      "INSERT INTO attempts (problem_id, started_at) VALUES (?, ?)",
    ).run(pid, nowIso());
  }
  return c.json(problemView(pid));
});

api.post("/problems/:id/save", async (c) => {
  const pid = c.req.param("id");
  const body = await c.req.json<{
    code?: string;
    explain?: string;
  }>();
  const a = latestAttempt(pid);
  if (!a) return c.json({ error: "no attempt" }, 400);
  if (body.code !== undefined && !a.finished_at)
    db.prepare("UPDATE attempts SET code = ? WHERE id = ?").run(
      body.code,
      a.id,
    );
  if (body.explain !== undefined)
    db.prepare("UPDATE attempts SET explain = ? WHERE id = ?").run(
      body.explain,
      a.id,
    );
  return c.json({ ok: true });
});

api.post("/problems/:id/hint", (c) => {
  const pid = c.req.param("id");
  const a = openAttempt(pid);
  if (!a) return c.json({ error: "no open attempt" }, 400);
  if (activeRunForAttempt(a.id))
    return c.json({ error: "No hints in a boss fight." }, 403);
  const u = unlocks(a.active_seconds, C.problem(pid).hints.length);
  if (a.hints_used >= u.hintsAvailable)
    return c.json(
      { error: "Not unlocked yet. Keep struggling a bit longer." },
      403,
    );
  db.prepare(
    "UPDATE attempts SET hints_used = hints_used + 1 WHERE id = ?",
  ).run(a.id);
  return c.json(problemView(pid));
});

api.post("/problems/:id/solution", (c) => {
  const pid = c.req.param("id");
  const a = openAttempt(pid);
  if (a) {
    if (activeRunForAttempt(a.id))
      return c.json({ error: "No solutions in a boss fight." }, 403);
    if (!unlocks(a.active_seconds, 0).solutionAvailable)
      return c.json(
        { error: "Solutions unlock after 30 min of active work." },
        403,
      );
    db.prepare("UPDATE attempts SET solution_viewed = 1 WHERE id = ?").run(
      a.id,
    );
  }
  return c.json(problemView(pid));
});

api.post("/problems/:id/run", async (c) => {
  const pid = c.req.param("id");
  const { code, custom } = await c.req.json<{
    code: string;
    custom?: string[];
  }>();
  const a = latestAttempt(pid);
  const res = await judge(pid, code, "run", custom ?? []);
  if (a) logSubmission(a.id, "run", res, code);
  return c.json({ result: res });
});

api.post("/problems/:id/submit", async (c) => {
  const pid = c.req.param("id");
  const { code } = await c.req.json<{ code: string }>();
  const a = latestAttempt(pid);
  if (!a) return c.json({ error: "no attempt" }, 400);
  const res = await judge(pid, code, "submit");
  logSubmission(a.id, "submit", res, code);
  let xp = 0,
    outcome: Outcome | null = null,
    chest: EarnedChest | null = null;
  if (res.verdict === "Accepted" && !a.finished_at) {
    const inBoss = !!activeRunForAttempt(a.id); // boss wins drop their own chest
    markSolved(a.id);
    outcome = outcomeOf(a.hints_used, !!a.solution_viewed);
    const firstSolve = !everSolved(pid);
    db.prepare(
      "UPDATE attempts SET finished_at = ?, outcome = ?, code = ? WHERE id = ?",
    ).run(nowIso(), outcome, code, a.id);
    if (firstSolve) {
      xp = addXp(
        solveXp(
          C.problem(pid).difficulty,
          a.hints_used,
          !!a.solution_viewed,
          C.problemHome(pid)?.role === "optional",
        ),
        "solve",
        pid,
      );
      addReview("problem", pid, outcome);
      if (!inBoss) chest = maybeSolveChest(pid, outcome);
    }
  }
  return c.json({ result: res, outcome, xp, chest });
});

api.get("/reviews", (c) => {
  const rows = db
    .prepare("SELECT * FROM reviews WHERE due <= ? ORDER BY due")
    .all(localDate()) as {
    item_type: "problem" | "topic";
    item_id: string;
    interval_idx: number;
    due: string;
  }[];
  const titleOf = (type: string, id: string) =>
    type === "problem" && C.hasProblem(id)
      ? C.problem(id).title
      : (C.topic(id)?.title ?? id);
  const upcoming = (
    db
      .prepare(
        "SELECT item_type, item_id, due FROM reviews WHERE due > ? ORDER BY due LIMIT 10",
      )
      .all(localDate()) as { item_type: string; item_id: string; due: string }[]
  ).map((u) => ({
    type: u.item_type,
    id: u.item_id,
    title: titleOf(u.item_type, u.item_id),
    due: u.due,
  }));
  const items = rows.map((r) => {
    const base = {
      type: r.item_type,
      id: r.item_id,
      due: r.due,
      interval: INTERVALS[r.interval_idx],
      next: {
        pass: INTERVALS[Math.min(r.interval_idx + 1, INTERVALS.length - 1)],
        fail: INTERVALS[0],
      },
    };
    if (r.item_type === "problem" && C.hasProblem(r.item_id)) {
      const { problem: p, files } = C.loadProblem(r.item_id);
      const ref = p.solutions.find((s) => s.reference)!;
      return {
        ...base,
        title: p.title,
        difficulty: p.difficulty,
        prompt:
          "Without looking: what's the approach, and its time/space complexity? Say it out loud or write it.",
        keyPoints: p.explain.keyPoints,
        reveal: {
          title: ref.title,
          time: ref.time,
          space: ref.space,
          ...files(ref.id),
        },
      };
    }
    const t = C.topic(r.item_id);
    return {
      ...base,
      title: t?.title ?? r.item_id,
      difficulty: null,
      prompt: t?.explain.prompt ?? "",
      keyPoints: t?.explain.keyPoints ?? [],
      reveal: null,
    };
  });
  return c.json({ items, upcoming });
});

api.post("/reviews", async (c) => {
  const { type, id, passed } = await c.req.json<{
    type: string;
    id: string;
    passed: boolean;
  }>();
  const row = db
    .prepare(
      "SELECT interval_idx FROM reviews WHERE item_type = ? AND item_id = ?",
    )
    .get(type, id) as { interval_idx: number } | undefined;
  if (!row) return c.json({ error: "not found" }, 404);
  const n = nextReview(row.interval_idx, passed, localDate());
  db.prepare(
    "UPDATE reviews SET interval_idx = ?, due = ?, last_result = ? WHERE item_type = ? AND item_id = ?",
  ).run(n.idx, n.due, passed ? "pass" : "fail", type, id);
  // same XP either way, so admitting you forgot costs nothing
  return c.json({ next: n, xp: addXp(REVIEW_XP, "review", `${type}:${id}`) });
});

function rubric(kind: string, id: string) {
  if (kind === "topic") {
    const t = C.topic(id);
    return t && { question: t.explain.prompt, keyPoints: t.explain.keyPoints };
  }
  if (kind === "problem" && C.hasProblem(id)) {
    const p = C.problem(id);
    return {
      question: `Walk me through your solution to "${p.title}": the approach, why it works, and its time and space complexity.`,
      keyPoints: p.explain.keyPoints,
    };
  }
  return null;
}

const latestGrade = (kind: string, ref: string) => {
  const row = db
    .prepare(
      "SELECT json FROM grades WHERE kind = ? AND ref = ? ORDER BY id DESC LIMIT 1",
    )
    .get(kind, ref) as { json: string } | undefined;
  return row ? JSON.parse(row.json) : null;
};

api.get("/grades/:kind/:id", (c) =>
  c.json({ grade: latestGrade(c.req.param("kind"), c.req.param("id")) }),
);

api.post("/grades/:kind/:id", async (c) => {
  const { kind, id } = c.req.param();
  const { text } = await c.req.json<{ text: string }>();
  const r = rubric(kind, id);
  if (!r) return c.json({ error: "Nothing to grade against." }, 404);
  if (text.trim().length < 20)
    return c.json({ error: "Write a bit more first." }, 400);
  let grade;
  try {
    grade = await gradeExplain({ ...r, answer: text });
  } catch (e) {
    console.error("grade failed:", e);
    return c.json(
      { error: "AI grading is unavailable right now. Use the checklist." },
      503,
    );
  }
  const best = (
    db
      .prepare("SELECT MAX(score) AS s FROM grades WHERE kind = ? AND ref = ?")
      .get(kind, id) as { s: number | null }
  ).s;
  db.prepare(
    "INSERT INTO grades (kind, ref, ts, score, json) VALUES (?, ?, ?, ?, ?)",
  ).run(kind, id, nowIso(), grade.score, JSON.stringify(grade));
  const gain = Math.max(0, grade.score - (best ?? 0));
  const xp = addXp(gain * GRADE_XP_PER_POINT, "grade", `${kind}:${id}`);
  return c.json({ grade, xp });
});

app.onError((e, c) => {
  const status = (e as { status?: number }).status;
  if (!status) console.error(e);
  return c.json({ error: e.message }, (status ?? 500) as 400);
});
app.route("/api", api);
app.use(
  "/content/*",
  serveStatic({
    root: relative(process.cwd(), join(ROOT, "courses")),
    rewriteRequestPath: (p) => p.replace(/^\/content/, ""),
  }),
);
if (process.env.NODE_ENV === "production") {
  const dist = relative(process.cwd(), join(import.meta.dirname, "..", "dist"));
  app.use("/*", serveStatic({ root: dist }));
  app.get("*", serveStatic({ path: join(dist, "index.html") }));
}

const port = Number(process.env.PORT ?? 3001);
serve({ fetch: app.fetch, port }, () => {
  console.log(`api on http://localhost:${port}`);
  schedule();
});

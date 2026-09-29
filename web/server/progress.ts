import { db } from "./db.ts";
import * as C from "./content.ts";
import { computeStreak, DAILY_GOAL_S } from "./engine/streak.ts";
import { getSettings } from "./settings.ts";
import { levelInfo } from "./engine/xp.ts";
import { localDate } from "./engine/dates.ts";
import { bonusFreezes, chestsWaiting } from "./chests.ts";
import type {
  Me,
  NextAction,
  ModuleView,
  Outcome,
  ProblemRef,
  ProblemStatus,
  Topic,
  TopicProblem,
  TopicStatus,
} from "../shared/types.ts";

const RANK: Record<Outcome, number> = { solved: 3, hinted: 2, assisted: 1 };
export const QUIZ_PASS = 0.7;

export const isSolved = (s: string | undefined) => !!s && s in RANK;

export function problemStatuses(): Record<string, ProblemStatus> {
  const out: Record<string, ProblemStatus> = {};
  // opening a problem isn't starting it: "in-progress" needs real work
  for (const r of db
    .prepare(
      "SELECT problem_id, outcome, active_seconds > 0 OR approach != '' AS worked FROM attempts",
    )
    .all() as {
    problem_id: string;
    outcome: Outcome | null;
    worked: number;
  }[]) {
    const cur = out[r.problem_id];
    if (!r.outcome) {
      if (!cur && r.worked) out[r.problem_id] = "in-progress";
      continue;
    }
    if (!isSolved(cur) || RANK[r.outcome] > RANK[cur as Outcome])
      out[r.problem_id] = r.outcome;
  }
  return out;
}

export function topicStatus(
  t: Topic,
  statuses = problemStatuses(),
): TopicStatus {
  const row = db
    .prepare("SELECT * FROM topic_progress WHERE topic_id = ?")
    .get(t.id) as
    | {
        lesson_done_at: string | null;
        quiz_best: number | null;
        explain: string | null;
      }
    | undefined;
  const required = t.problems.filter((p) => p.role !== "optional");
  const solved = required.filter((p) => isSolved(statuses[p.id])).length;
  const hasQuiz = t.status === "ready" && C.quiz(t.id).length > 0;
  const lessonDone = !!row?.lesson_done_at;
  const quizBest = row?.quiz_best ?? null;
  const explained = !!row?.explain;
  const complete =
    t.status === "ready" &&
    lessonDone &&
    explained &&
    solved === required.length &&
    (!hasQuiz || (quizBest ?? 0) >= QUIZ_PASS);
  return {
    lessonDone,
    quizBest,
    hasQuiz,
    explained,
    solved,
    required: required.length,
    complete,
  };
}

export function topicWrapped(t: Topic) {
  const ids = t.problems.map((p) => p.id);
  const marks = ids.map(() => "?").join(",");
  const attempts = (
    ids.length
      ? db
          .prepare(
            `SELECT problem_id, outcome, active_seconds, finished_at FROM attempts WHERE problem_id IN (${marks})`,
          )
          .all(...ids)
      : []
  ) as {
    problem_id: string;
    outcome: Outcome | null;
    active_seconds: number;
    finished_at: string | null;
  }[];
  const solved = new Set(
    attempts.filter((a) => a.outcome).map((a) => a.problem_id),
  );
  const clean = new Set(
    attempts.filter((a) => a.outcome === "solved").map((a) => a.problem_id),
  );
  const optional = t.problems.filter(
    (p) => p.role === "optional" && solved.has(p.id),
  ).length;
  const row = db
    .prepare(
      "SELECT lesson_done_at, quiz_best, explain_at FROM topic_progress WHERE topic_id = ?",
    )
    .get(t.id) as
    | {
        lesson_done_at: string | null;
        quiz_best: number | null;
        explain_at: string | null;
      }
    | undefined;
  const best = (kind: string, refs: string[]) =>
    refs.length
      ? ((
          db
            .prepare(
              `SELECT MAX(score) AS s FROM grades WHERE kind = ? AND ref IN (${refs.map(() => "?").join(",")})`,
            )
            .get(kind, ...refs) as { s: number | null }
        ).s ?? null)
      : null;
  const stamps = [
    row?.lesson_done_at,
    row?.explain_at,
    ...attempts.filter((a) => a.outcome).map((a) => a.finished_at),
  ].filter(Boolean) as string[];
  return {
    seconds: attempts.reduce((s, a) => s + a.active_seconds, 0),
    solved: solved.size,
    optional,
    total: ids.length,
    hintFree: solved.size ? clean.size / solved.size : 0,
    quizBest: row?.quiz_best ?? null,
    bestExplain: best("topic", [t.id]),
    bestProblemExplain: best("problem", ids),
    masteredAt: stamps.sort().at(-1) ?? null,
  };
}

function topicProblem(
  ref: ProblemRef,
  statuses: Record<string, ProblemStatus>,
): TopicProblem {
  if (C.hasProblem(ref.id)) {
    const p = C.problem(ref.id);
    return {
      id: ref.id,
      title: p.title,
      role: ref.role,
      difficulty: p.difficulty,
      lc: p.lc?.id ?? null,
      available: true,
      status: statuses[ref.id] ?? "new",
    };
  }
  return {
    id: ref.id,
    title: ref.title ?? ref.id,
    role: ref.role,
    difficulty: ref.difficulty ?? null,
    lc: ref.lc ?? null,
    available: false,
    status: "new",
  };
}

export function moduleViews(): ModuleView[] {
  const statuses = problemStatuses();
  const views = C.modules().map((m) => {
    const topicViews = m.topics.map((tid) => {
      const t = C.topic(tid)!;
      return {
        id: t.id,
        title: t.title,
        status: t.status,
        ...topicStatus(t, statuses),
        problems: t.problems.map((ref) => topicProblem(ref, statuses)),
      };
    });
    return {
      ...m,
      topicViews,
      complete: topicViews.every((t) => t.complete),
      unlocked: false,
    };
  });
  const done = new Set(views.filter((v) => v.complete).map((v) => v.id));
  for (const v of views) v.unlocked = v.prereqs.every((p) => done.has(p));
  return views;
}

export function activityMap(): Record<string, number> {
  return Object.fromEntries(
    (
      db.prepare("SELECT date, seconds FROM activity").all() as {
        date: string;
        seconds: number;
      }[]
    ).map((r) => [r.date, r.seconds]),
  );
}

const reviewsDue = () =>
  (
    db
      .prepare("SELECT COUNT(*) AS n FROM reviews WHERE due <= ?")
      .get(localDate()) as { n: number }
  ).n;

export function me(): Me {
  const xp = (
    db
      .prepare("SELECT COALESCE(SUM(amount), 0) AS xp FROM xp_events")
      .get() as { xp: number }
  ).xp;
  const s = computeStreak(activityMap(), localDate(), bonusFreezes());
  return {
    username: getSettings().username,
    xp,
    level: levelInfo(xp),
    today: { seconds: s.todaySeconds, goal: DAILY_GOAL_S, done: s.todayDone },
    weekStreak: s.weekStreak,
    dayStreak: s.dayStreak,
    freezes: s.freezes,
    thisWeek: s.thisWeek,
    reviewsDue: reviewsDue(),
    chests: chestsWaiting(),
  };
}

/** Next best thing to do: due reviews first, then the first unfinished step in course order. */
export function nextAction(): NextAction {
  const due = reviewsDue();
  if (due > 0)
    return {
      kind: "review",
      title: `${due} review${due === 1 ? "" : "s"} due`,
      context: "Spaced repetition",
      href: "/review",
    };
  const statuses = problemStatuses();
  for (const m of moduleViews()) {
    if (!m.unlocked) continue;
    for (const tv of m.topicViews) {
      if (tv.status !== "ready" || tv.complete) continue;
      const t = C.topic(tv.id)!;
      const href = `/course/${m.id}/${t.id}`;
      const context = `Module ${m.number} · ${m.title}`;
      if (!tv.lessonDone)
        return { kind: "learn", title: t.title, context, href };
      const next = t.problems.find(
        (p) => p.role !== "optional" && !isSolved(statuses[p.id]),
      );
      if (next && C.hasProblem(next.id))
        return {
          kind: "solve",
          title: C.problem(next.id).title,
          context: t.title,
          href: `/problems/${next.id}`,
        };
      return { kind: "finish", title: t.title, context, href };
    }
  }
  return {
    kind: "browse",
    title: "Browse the course",
    context: "",
    href: "/course",
  };
}

import { readFileSync } from "node:fs";
import { join } from "node:path";
import { db } from "./db.ts";
import * as C from "./content.ts";
import {
  activityMap,
  isSolved,
  moduleViews,
  problemStatuses,
} from "./progress.ts";
import { addDays, localDate, weekStart } from "./engine/dates.ts";
import { DAILY_GOAL_S } from "./engine/streak.ts";

const WEEKS = 12;
const DAYS = 30;

export function stats() {
  const today = localDate();
  const activity = activityMap();
  const statuses = Object.values(problemStatuses());

  const firstWeek = addDays(weekStart(today), -(WEEKS - 1) * 7);
  const firstDay = addDays(today, -(DAYS - 1));
  const from = firstWeek < firstDay ? firstWeek : firstDay;
  const xpByDay: Record<string, number> = {};
  for (const r of db
    .prepare("SELECT ts, amount FROM xp_events WHERE ts >= ?")
    .all(new Date(`${from}T00:00:00`).toISOString()) as {
    ts: string;
    amount: number;
  }[]) {
    const d = localDate(new Date(r.ts));
    xpByDay[d] = (xpByDay[d] ?? 0) + r.amount;
  }
  const bucket = (start: string, n: number) => {
    const ds = Array.from({ length: n }, (_, i) => addDays(start, i));
    return {
      start,
      minutes: Math.round(ds.reduce((a, d) => a + (activity[d] ?? 0), 0) / 60),
      xp: ds.reduce((a, d) => a + (xpByDay[d] ?? 0), 0),
    };
  };
  const weeks = Array.from({ length: WEEKS }, (_, i) =>
    bucket(addDays(firstWeek, i * 7), 7),
  );
  const daily = Array.from({ length: DAYS }, (_, i) =>
    bucket(addDays(firstDay, i), 1),
  );

  const grades = (
    db
      .prepare(
        "SELECT kind, ref, ts, score FROM grades ORDER BY id DESC LIMIT 30",
      )
      .all() as { kind: string; ref: string; ts: string; score: number }[]
  )
    .reverse()
    .map((g) => ({
      ...g,
      title:
        g.kind === "problem" && C.hasProblem(g.ref)
          ? C.problem(g.ref).title
          : g.kind === "boss"
            ? C.module_(g.ref).title
            : (C.topic(g.ref)?.title ?? g.ref),
    }));

  const quiz = db
    .prepare(
      "SELECT AVG(quiz_best) AS avg FROM topic_progress WHERE quiz_best IS NOT NULL",
    )
    .get() as { avg: number | null };

  const modules = moduleViews().map((m) => {
    const probs = m.topicViews
      .flatMap((t) => t.problems)
      .filter((p, i, a) => a.findIndex((q) => q.id === p.id) === i);
    return {
      id: m.id,
      number: m.number,
      title: m.title,
      topics: m.topicViews.length,
      topicsDone: m.topicViews.filter((t) => t.complete).length,
      problems: probs.length,
      solved: probs.filter((p) => isSolved(p.status)).length,
    };
  });

  const days = Object.values(activity);
  return {
    totals: {
      activeSeconds: days.reduce((a, s) => a + s, 0),
      activeDays: days.filter((s) => s > 0).length,
      goalDays: days.filter((s) => s >= DAILY_GOAL_S).length,
      solved: statuses.filter((s) => s === "solved").length,
      hinted: statuses.filter((s) => s === "hinted").length,
      assisted: statuses.filter((s) => s === "assisted").length,
      quizAvg: quiz.avg,
      explainAvg: grades.length
        ? grades.reduce((a, g) => a + g.score, 0) / grades.length
        : null,
    },
    weeks,
    days: daily,
    grades,
    modules,
  };
}

type Pattern = {
  id: string;
  name: string;
  signals: string;
  complexity: string;
};

/** Pattern catalog joined with the topics that teach each one and the problems that use it. */
export function patterns() {
  const catalog = JSON.parse(
    readFileSync(join(C.COURSE_DIR, "patterns.json"), "utf8"),
  ) as Pattern[];
  const views = moduleViews();
  const topics = views.flatMap((m) =>
    m.topicViews.map((tv) => ({ m, tv, t: C.topic(tv.id)! })),
  );
  return catalog.map((p) => {
    const tps = topics.filter(({ t }) => t.patterns.includes(p.id));
    const probs = new Map<
      string,
      { id: string; title: string; status: string; available: boolean }
    >();
    for (const { tv } of tps) for (const q of tv.problems) probs.set(q.id, q);
    for (const { tv } of topics)
      for (const q of tv.problems)
        if (q.available && C.problem(q.id).patterns.includes(p.id))
          probs.set(q.id, q);
    return {
      ...p,
      topics: tps.map(({ m, tv }) => ({
        id: tv.id,
        title: tv.title,
        moduleId: m.id,
        moduleNumber: m.number,
        moduleTitle: m.title,
        ready: tv.status === "ready",
        complete: tv.complete,
      })),
      problems: [...probs.values()].map((q) => ({
        id: q.id,
        title: q.title,
        available: q.available,
        solved: isSolved(q.status),
      })),
    };
  });
}

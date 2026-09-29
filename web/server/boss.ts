import { db, nowIso, addXp, fail } from "./db.ts";
import * as C from "./content.ts";
import { isSolved, moduleViews, problemStatuses } from "./progress.ts";
import { gradeExplain } from "./ai.ts";
import { earnChest } from "./chests.ts";
import { localDate } from "./engine/dates.ts";

export const BOSS_XP = 100;
export const BOSS_PASS_SCORE = 3;

export type BossRun = {
  id: number;
  module_id: string;
  problem_id: string;
  attempt_id: number;
  started_at: string;
  limit_s: number;
  solved_at: string | null;
  finished_at: string | null;
  score: number | null;
  passed: number | null;
};

const run = (id: number) =>
  db.prepare("SELECT * FROM boss_runs WHERE id = ?").get(id) as
    BossRun | undefined;

export const activeRunForAttempt = (attemptId: number) =>
  db
    .prepare(
      "SELECT * FROM boss_runs WHERE attempt_id = ? AND finished_at IS NULL",
    )
    .get(attemptId) as BossRun | undefined;

export const deadline = (r: BossRun) =>
  new Date(Date.parse(r.started_at) + r.limit_s * 1000).toISOString();

const view = (r: BossRun) => ({
  id: r.id,
  problemId: r.problem_id,
  problemTitle: C.hasProblem(r.problem_id)
    ? C.problem(r.problem_id).title
    : r.problem_id,
  startedAt: r.started_at,
  deadline: deadline(r),
  solvedIn: r.solved_at
    ? Math.round((Date.parse(r.solved_at) - Date.parse(r.started_at)) / 1000)
    : null,
  finished: !!r.finished_at,
  score: r.score,
  passed: r.passed === null ? null : !!r.passed,
});

export function bossState(moduleId: string) {
  const m = moduleViews().find((x) => x.id === moduleId);
  if (!m) return null;
  const runs = (
    db
      .prepare(
        "SELECT * FROM boss_runs WHERE module_id = ? ORDER BY id DESC LIMIT 10",
      )
      .all(moduleId) as BossRun[]
  ).map(view);
  const pool = candidates(moduleId);
  return {
    module: {
      id: m.id,
      number: m.number,
      title: m.title,
      limitMin: m.boss.timeLimitMin,
      topicsLeft: m.topicViews.filter((t) => !t.complete).length,
    },
    available: pool.length > 0,
    active: runs.find((r) => !r.finished) ?? null,
    last: runs.find((r) => r.finished) ?? null,
    beaten: runs.some((r) => r.passed),
    runs,
  };
}

/** The module's playable core/guided problems: the unsolved ones, or all once every one is solved. */
function candidates(moduleId: string) {
  const statuses = problemStatuses();
  const ids = C.module_(moduleId)
    .topics.flatMap((tid) => C.topic(tid)?.problems ?? [])
    .filter((p) => p.role !== "optional" && C.hasProblem(p.id))
    .map((p) => p.id);
  const uniq = [...new Set(ids)];
  const fresh = uniq.filter((id) => !isSolved(statuses[id]));
  return fresh.length ? fresh : uniq;
}

export function startBoss(moduleId: string) {
  if (!C.course().modules.includes(moduleId))
    throw fail("No such module.", 404);
  const pool = candidates(moduleId);
  if (!pool.length) throw fail("This module has no problems yet.");
  db.prepare(
    "UPDATE boss_runs SET finished_at = ?, passed = 0 WHERE module_id = ? AND finished_at IS NULL",
  ).run(nowIso(), moduleId);
  const pid = pool[Math.floor(Math.random() * pool.length)];
  const now = nowIso();
  const a = db
    .prepare("INSERT INTO attempts (problem_id, started_at) VALUES (?, ?)")
    .run(pid, now);
  db.prepare(
    "INSERT INTO boss_runs (module_id, problem_id, attempt_id, started_at, limit_s) VALUES (?, ?, ?, ?, ?)",
  ).run(
    moduleId,
    pid,
    Number(a.lastInsertRowid),
    now,
    C.module_(moduleId).boss.timeLimitMin * 60,
  );
  return { problemId: pid };
}

export function markSolved(attemptId: number) {
  db.prepare(
    "UPDATE boss_runs SET solved_at = ? WHERE attempt_id = ? AND solved_at IS NULL AND finished_at IS NULL",
  ).run(nowIso(), attemptId);
}

export function abandonBoss(id: number) {
  db.prepare(
    "UPDATE boss_runs SET finished_at = ?, passed = 0 WHERE id = ? AND finished_at IS NULL",
  ).run(nowIso(), id);
}

export async function finishBoss(id: number, text: string) {
  const r = run(id);
  if (!r || r.finished_at) throw fail("This boss fight is already over.");
  if (!r.solved_at) throw fail("Solve the problem first.");
  const p = C.problem(r.problem_id);
  let grade;
  try {
    grade = await gradeExplain({
      question: `You just solved "${p.title}" in a timed interview. Walk me through it: the approach, why it's correct, and the time and space complexity.`,
      keyPoints: p.explain.keyPoints,
      answer: text,
    });
  } catch (e) {
    console.error("boss grading failed:", e);
    throw fail(
      "AI grading is unavailable right now. Try again in a minute.",
      503,
    );
  }
  const inTime =
    Date.parse(r.solved_at) - Date.parse(r.started_at) <= r.limit_s * 1000;
  const passed = inTime && grade.score >= BOSS_PASS_SCORE;
  const firstWin =
    passed &&
    !db
      .prepare("SELECT 1 FROM boss_runs WHERE module_id = ? AND passed = 1")
      .get(r.module_id);
  db.prepare(
    "UPDATE boss_runs SET finished_at = ?, score = ?, passed = ? WHERE id = ?",
  ).run(nowIso(), grade.score, passed ? 1 : 0, id);
  db.prepare(
    "INSERT INTO grades (kind, ref, ts, score, json) VALUES ('boss', ?, ?, ?, ?)",
  ).run(r.module_id, nowIso(), grade.score, JSON.stringify(grade));
  const xp = firstWin ? addXp(BOSS_XP, "boss", r.module_id) : 0;
  // one chest per module per day, so re-running a boss can't farm them
  const today = localDate();
  const chestToday = (
    db
      .prepare("SELECT ts FROM chests WHERE source = 'boss' AND ref = ?")
      .all(r.module_id) as { ts: string }[]
  ).some((c) => localDate(new Date(c.ts)) === today);
  const chest = passed && !chestToday ? earnChest("boss", r.module_id) : null;
  return { run: view(run(id)!), grade, inTime, xp, chest };
}

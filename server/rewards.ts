import { db, nowIso, fail } from "./db.ts";
import * as C from "./content.ts";
import { activityMap, moduleViews } from "./progress.ts";
import { addDays, weekStart } from "./engine/dates.ts";
import { DAILY_GOAL_S, DAYS_PER_WEEK, FREEZE_DAY_S } from "./engine/streak.ts";

type Unlock = { topics?: string[]; modules?: string[]; boss?: string };

/** Real-world rewards, unlocked by finishing parts of the course. */
const REWARD_PATH: {
  id: string;
  label: string; // "unlocks after" text
  title: string;
  note: string;
  icon: string;
  size: "small" | "medium" | "big";
  unlock: Unlock;
}[] = [
  {
    id: "coffee-1",
    label: "Your first two topics",
    title: "Coffee",
    note: "A quick first win",
    icon: "coffee",
    size: "small",
    unlock: { topics: ["python-for-dsa", "complexity-analysis"] },
  },
  {
    id: "coffee-2",
    label: "Foundations",
    title: "Coffee",
    note: "",
    icon: "coffee",
    size: "small",
    unlock: { modules: ["foundations"] },
  },
  {
    id: "coffee-3",
    label: "Arrays & Strings",
    title: "Coffee",
    note: "",
    icon: "coffee",
    size: "small",
    unlock: { modules: ["arrays-strings"] },
  },
  {
    id: "coffee-4",
    label: "Hashing",
    title: "Coffee",
    note: "",
    icon: "coffee",
    size: "small",
    unlock: { modules: ["hashing"] },
  },
  {
    id: "meal",
    label: "Two Pointers & Windows",
    title: "A nice meal",
    note: "Somewhere you've wanted to try",
    icon: "meal",
    size: "small",
    unlock: { modules: ["two-pointers-sliding-window"] },
  },
  {
    id: "coffee-5",
    label: "Sorting & Searching",
    title: "Coffee",
    note: "Binary search conquered",
    icon: "coffee",
    size: "small",
    unlock: { modules: ["sorting-searching"] },
  },
  {
    id: "tshirt",
    label: "Linked Lists & Stacks",
    title: "A T-shirt",
    note: "One you actually like",
    icon: "shirt",
    size: "medium",
    unlock: { modules: ["linked-lists", "stacks-queues"] },
  },
  {
    id: "movie",
    label: "Recursion",
    title: "Movie night",
    note: "Big screen, snacks included",
    icon: "movie",
    size: "medium",
    unlock: { modules: ["recursion-backtracking"] },
  },
  {
    id: "shoes",
    label: "Trees",
    title: "New shoes",
    note: "Halfway there",
    icon: "shoes",
    size: "medium",
    unlock: { modules: ["trees"] },
  },
  {
    id: "book",
    label: "Heaps",
    title: "A book",
    note: "Any book, not a DSA one",
    icon: "book",
    size: "medium",
    unlock: { modules: ["heaps"] },
  },
  {
    id: "gear",
    label: "Graphs",
    title: "Headphones",
    note: "Or a game, your call",
    icon: "headphones",
    size: "medium",
    unlock: { modules: ["graphs"] },
  },
  {
    id: "grand",
    label: "Everything + the DP boss",
    title: "The big one: ₹10,000",
    note: "Anything you want within the budget",
    icon: "gift",
    size: "big",
    unlock: {
      modules: [
        "greedy-intervals",
        "dynamic-programming",
        "tries",
        "bit-manipulation",
        "advanced-structures",
      ],
      boss: "dynamic-programming",
    },
  },
];

export function rewardPath() {
  const views = moduleViews();
  const topicDone = new Set(
    views
      .flatMap((m) => m.topicViews)
      .filter((t) => t.complete)
      .map((t) => t.id),
  );
  const topicsOf = (mid: string) =>
    views.find((m) => m.id === mid)?.topicViews.map((t) => t.id) ?? [];
  const claims = Object.fromEntries(
    (
      db.prepare("SELECT id, claimed_at FROM reward_claims").all() as {
        id: string;
        claimed_at: string;
      }[]
    ).map((r) => [r.id, r.claimed_at]),
  );
  const bossWon = (mid: string) =>
    !!db
      .prepare("SELECT 1 FROM boss_runs WHERE module_id = ? AND passed = 1")
      .get(mid);

  return REWARD_PATH.map((r) => {
    // the finale needs the whole course, not just its listed modules
    const mods =
      r.size === "big" ? views.map((m) => m.id) : (r.unlock.modules ?? []);
    const needed = [...(r.unlock.topics ?? []), ...mods.flatMap(topicsOf)];
    const done = needed.filter((t) => topicDone.has(t)).length;
    const boss = r.unlock.boss ? bossWon(r.unlock.boss) : true;
    const unlocked = done === needed.length && boss;
    return {
      id: r.id,
      title: r.title,
      label: r.label,
      note: r.note,
      icon: r.icon,
      size: r.size,
      requires: [
        ...(r.unlock.topics ?? []).map((t) => C.topic(t)?.title ?? t),
        ...(r.size === "big"
          ? ["every module"]
          : (r.unlock.modules ?? []).map((m) => C.module_(m).title)),
        ...(r.unlock.boss
          ? [`${C.module_(r.unlock.boss).title} boss fight`]
          : []),
      ],
      progress: {
        done,
        total: needed.length,
        boss: r.unlock.boss ? boss : null,
      },
      status: claims[r.id] ? "availed" : unlocked ? "unlocked" : "locked",
      availedAt: claims[r.id] ?? null,
    };
  });
}

export function setAvailed(id: string, availed: boolean) {
  const r = rewardPath().find((x) => x.id === id);
  if (!r) throw fail("No such reward.");
  if (r.status === "locked") throw fail("That reward is still locked.");
  if (availed)
    db.prepare(
      "INSERT OR IGNORE INTO reward_claims (id, claimed_at) VALUES (?, ?)",
    ).run(id, nowIso());
  else db.prepare("DELETE FROM reward_claims WHERE id = ?").run(id);
}

type Badge = {
  id: string;
  name: string;
  desc: string;
  art: string;
  value: number;
  tiers: number[]; // one entry = single achievement, three = bronze/silver/gold
};

/** Counted from recorded effort, so once earned they can't be lost. */
export function badges(): Badge[] {
  const activity = activityMap();
  const dates = Object.keys(activity).sort();
  const goal = (d: string) => (activity[d] ?? 0) >= DAILY_GOAL_S;
  const count = (sql: string) =>
    (db.prepare(sql).get() as { n: number | null }).n ?? 0;

  const attempts = db
    .prepare(
      "SELECT problem_id, outcome, active_seconds FROM attempts WHERE outcome IS NOT NULL",
    )
    .all() as { problem_id: string; outcome: string; active_seconds: number }[];
  const solved = new Set(attempts.map((a) => a.problem_id)).size;
  const clean = new Set(
    attempts.filter((a) => a.outcome === "solved").map((a) => a.problem_id),
  ).size;
  const speedruns = new Set(
    attempts
      .filter(
        (a) =>
          a.outcome === "solved" &&
          a.active_seconds < 600 &&
          C.hasProblem(a.problem_id) &&
          C.problem(a.problem_id).difficulty === "Easy",
      )
      .map((a) => a.problem_id),
  ).size;
  const perfectWeeks = [...new Set(dates.map(weekStart))].filter(
    (ws) =>
      Array.from({ length: 7 }, (_, i) => addDays(ws, i)).filter(goal).length >=
      DAYS_PER_WEEK,
  ).length;
  const comebacks = dates.filter(
    (d) => goal(d) && !goal(addDays(d, -1)) && goal(addDays(d, -2)),
  ).length;
  const stretch = new Set(
    attempts
      .filter(
        (a) =>
          C.hasProblem(a.problem_id) &&
          C.problem(a.problem_id).difficulty !== "Easy",
      )
      .map((a) => a.problem_id),
  ).size;
  const views = moduleViews();
  const topicsDone = views
    .flatMap((m) => m.topicViews)
    .filter((t) => t.complete).length;
  const modulesDone = views.filter(
    (m) => m.complete && m.topicViews.length,
  ).length;

  return [
    {
      id: "first-solve",
      name: "First Accepted",
      desc: "problems solved",
      art: "check",
      value: solved,
      tiers: [1],
    },
    {
      id: "solver",
      name: "Problem Solver",
      desc: "problems solved",
      art: "code",
      value: solved,
      tiers: [25, 75, 150],
    },
    {
      id: "no-hints",
      name: "No Hints Needed",
      desc: "solved hint-free",
      art: "bulb",
      value: clean,
      tiers: [10, 40, 100],
    },
    {
      id: "stretch",
      name: "Stretch Goals",
      desc: "Medium/Hard solved",
      art: "mountain",
      value: stretch,
      tiers: [1, 15, 50],
    },
    {
      id: "speedrun",
      name: "Speedrun",
      desc: "Easy clean under 10 min",
      art: "bolt",
      value: speedruns,
      tiers: [1, 10, 30],
    },
    {
      id: "explainer",
      name: "Clear Explainer",
      desc: "4/5+ explanations",
      art: "speech",
      value: count("SELECT COUNT(*) AS n FROM grades WHERE score >= 4"),
      tiers: [1, 15, 50],
    },
    {
      id: "perfect",
      name: "Perfect Score",
      desc: "5/5 explanations",
      art: "star",
      value: count("SELECT COUNT(*) AS n FROM grades WHERE score = 5"),
      tiers: [1],
    },
    {
      id: "quiz-ace",
      name: "Quiz Ace",
      desc: "perfect quizzes",
      art: "target",
      value: count(
        "SELECT COUNT(*) AS n FROM topic_progress WHERE quiz_best >= 1",
      ),
      tiers: [1, 10, 30],
    },
    {
      id: "reviewer",
      name: "Spaced Out",
      desc: "reviews done",
      art: "cards",
      value: count(
        "SELECT COUNT(*) AS n FROM xp_events WHERE reason = 'review'",
      ),
      tiers: [10, 50, 200],
    },
    {
      id: "perfect-week",
      name: "Full Week",
      desc: "5-goal-day weeks",
      art: "calendar",
      value: perfectWeeks,
      tiers: [1, 4, 12],
    },
    {
      id: "marathon",
      name: "Deep Work",
      desc: "3h+ focus days",
      art: "hourglass",
      value: dates.filter((d) => activity[d] >= FREEZE_DAY_S).length,
      tiers: [1, 5, 15],
    },
    {
      id: "comeback",
      name: "Comeback",
      desc: "comebacks",
      art: "rebound",
      value: comebacks,
      tiers: [1],
    },
    {
      id: "topics",
      name: "Topic Master",
      desc: "topics completed",
      art: "book",
      value: topicsDone,
      tiers: [1, 10, 40],
    },
    {
      id: "boss",
      name: "Boss Slayer",
      desc: "bosses defeated",
      art: "swords",
      value: count(
        "SELECT COUNT(DISTINCT module_id) AS n FROM boss_runs WHERE passed = 1",
      ),
      tiers: [1, 5, 12],
    },
    {
      id: "modules",
      name: "Module Master",
      desc: "modules completed",
      art: "laurel",
      value: modulesDone,
      tiers: [1, 5, 16],
    },
  ];
}

export const rewards = () => ({ path: rewardPath(), badges: badges() });

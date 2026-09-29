// Run: node server/engine/selfcheck.ts   (fails loudly if engine logic breaks)
import assert from "node:assert/strict";
import { addDays, weekStart } from "./dates.ts";
import { computeStreak, DAILY_GOAL_S, FREEZE_DAY_S } from "./streak.ts";
import { levelInfo, outcomeOf, solveXp } from "./xp.ts";
import { firstReview, nextReview } from "./srs.ts";
import { unlocks } from "./hints.ts";
import { nextReminderAt, CAP_PLANNED } from "./reminders.ts";

// dates: 2026-09-28 is a Monday
assert.equal(weekStart("2026-09-28"), "2026-09-28");
assert.equal(weekStart("2026-10-04"), "2026-09-28");
assert.equal(addDays("2026-09-30", 2), "2026-10-02");

const days = (start: string, n: number, s = DAILY_GOAL_S) =>
  Object.fromEntries(
    Array.from({ length: n }, (_, i) => [addDays(start, i), s]),
  );

// two full weeks of Mon–Fri → streak 2; current week with 3 days doesn't break it
{
  const a = {
    ...days("2026-09-14", 5),
    ...days("2026-09-21", 5),
    ...days("2026-09-28", 3),
  };
  const s = computeStreak(a, "2026-09-30");
  assert.equal(s.weekStreak, 2);
  assert.equal(s.thisWeekDays, 3);
}
// a 4-day week breaks the streak without freezes
{
  const a = { ...days("2026-09-14", 5), ...days("2026-09-21", 4) };
  assert.equal(computeStreak(a, "2026-09-28").weekStreak, 0);
}
// a 4-day week with one 3h+ day is covered by the freeze it earned
{
  const a = {
    ...days("2026-09-14", 5),
    ...days("2026-09-21", 3),
    "2026-09-24": FREEZE_DAY_S,
  };
  const s = computeStreak(a, "2026-09-28");
  assert.equal(s.weekStreak, 2);
  assert.equal(s.freezes, 0);
}
// current week reaching 5 counts immediately; today's progress
{
  const a = { ...days("2026-09-28", 5), "2026-10-02": 600 + DAILY_GOAL_S };
  const s = computeStreak(a, "2026-10-02");
  assert.equal(s.weekStreak, 1);
  assert.ok(s.todayDone);
}
// a freeze from a mystery chest covers a short week, and bonus freezes still cap at 2
{
  const a = { ...days("2026-09-14", 5), ...days("2026-09-21", 4) };
  assert.equal(
    computeStreak(a, "2026-09-28", { "2026-09-22": 1 }).weekStreak,
    2,
  );
  assert.equal(computeStreak({}, "2026-09-28", { "2026-09-28": 5 }).freezes, 2);
}
assert.equal(computeStreak({}, "2026-09-28").weekStreak, 0);

assert.equal(solveXp("Easy", 0, false, false), 20);
assert.equal(solveXp("Medium", 1, false, false), 30);
assert.equal(solveXp("Medium", 0, true, false), 8);
assert.equal(outcomeOf(0, false), "solved");
assert.equal(outcomeOf(2, false), "hinted");
assert.equal(outcomeOf(0, true), "assisted");
assert.deepEqual(
  [
    levelInfo(0).level,
    levelInfo(99).level,
    levelInfo(100).level,
    levelInfo(300).level,
  ],
  [1, 1, 2, 3],
);

assert.deepEqual(firstReview("solved", "2026-09-28"), {
  idx: 1,
  due: "2026-10-01",
});
assert.deepEqual(firstReview("assisted", "2026-09-28"), {
  idx: 0,
  due: "2026-09-29",
});
assert.deepEqual(nextReview(1, true, "2026-09-28"), {
  idx: 2,
  due: "2026-10-05",
});
assert.deepEqual(nextReview(4, true, "2026-09-28").idx, 4);
assert.deepEqual(nextReview(3, false, "2026-09-28"), {
  idx: 0,
  due: "2026-09-29",
});

assert.equal(unlocks(0, 2).hintsAvailable, 0);
assert.equal(unlocks(600, 2).hintsAvailable, 1);
assert.equal(unlocks(1300, 2).hintsAvailable, 2);
assert.equal(unlocks(1300, 1).hintsAvailable, 1);
assert.equal(unlocks(1799, 2).solutionAvailable, false);
assert.equal(unlocks(1800, 2).solutionAvailable, true);

// reminders: first one late morning, gaps shrink, nothing once done / past the window / over the cap
{
  const base = {
    window: { start: "10:00", end: "23:00" },
    plannedDay: true,
    catchUp: false,
    todayDone: false,
    sentToday: 0,
    lastSentAt: null,
  };
  const morning = new Date(2026, 8, 28, 9, 0);
  const first = nextReminderAt({ ...base, now: morning })!;
  assert.ok(first.getHours() === 11 && first.getMinutes() <= 30);
  assert.equal(
    nextReminderAt({ ...base, now: morning })!.getTime(),
    first.getTime(),
  );
  const noon = new Date(2026, 8, 28, 12, 0);
  const g1 = nextReminderAt({
    ...base,
    now: noon,
    sentToday: 1,
    lastSentAt: noon,
  })!;
  const late = new Date(2026, 8, 28, 21, 0);
  const g2 = nextReminderAt({
    ...base,
    now: late,
    sentToday: 1,
    lastSentAt: late,
  })!;
  assert.ok(g2.getTime() - late.getTime() < g1.getTime() - noon.getTime());
  assert.equal(nextReminderAt({ ...base, now: noon, todayDone: true }), null);
  assert.equal(
    nextReminderAt({ ...base, now: new Date(2026, 8, 28, 23, 30) }),
    null,
  );
  assert.equal(
    nextReminderAt({
      ...base,
      now: noon,
      sentToday: CAP_PLANNED,
      lastSentAt: noon,
    }),
    null,
  );
  assert.equal(nextReminderAt({ ...base, now: noon, plannedDay: false }), null);
  assert.ok(
    nextReminderAt({ ...base, now: noon, plannedDay: false, catchUp: true }),
  );
}

// day streak: consecutive 30-min days; an unfinished today doesn't break it
{
  const g = DAILY_GOAL_S;
  const a = {
    "2026-09-25": g,
    "2026-09-26": g,
    "2026-09-27": g,
    "2026-09-28": 60,
  };
  assert.equal(computeStreak(a, "2026-09-28").dayStreak, 3);
  assert.equal(
    computeStreak({ ...a, "2026-09-28": g }, "2026-09-28").dayStreak,
    4,
  );
  assert.equal(computeStreak(a, "2026-09-29").dayStreak, 0);
}

console.log("engine selfcheck ok");

import { addDays, weekStart } from "./dates.ts";

export const DAILY_GOAL_S = 30 * 60;
export const DAYS_PER_WEEK = 5;
export const FREEZE_DAY_S = 3 * 60 * 60;
export const MAX_FREEZES = 2;

export type StreakState = {
  weekStreak: number; // consecutive successful weeks (current week counts once it hits the target)
  dayStreak: number; // consecutive goal days up to today (today counts once done; not done yet doesn't break it)
  thisWeekDays: number;
  thisWeek: { date: string; seconds: number; qualifies: boolean }[];
  freezes: number;
  todaySeconds: number;
  todayDone: boolean;
};

/**
 * Derived purely from daily activity, so there's no streak state to corrupt.
 * Per finished week: earn freezes from long days (cap 2), then cover any shortfall below 5 days with freezes;
 * if the shortfall can't be covered, the streak resets.
 */
export function computeStreak(
  activity: Record<string, number>,
  today: string,
  bonusFreezes: Record<string, number> = {}, // date → freezes granted that day (mystery chests)
): StreakState {
  const qualifies = (d: string) => (activity[d] ?? 0) >= DAILY_GOAL_S;
  const dates = Object.keys(activity)
    .filter((d) => activity[d] > 0)
    .sort();
  const currentWeek = weekStart(today);
  let streak = 0;
  let freezes = 0;

  const earned = (days: string[]) =>
    days.filter((d) => (activity[d] ?? 0) >= FREEZE_DAY_S).length +
    days.reduce((n, d) => n + (bonusFreezes[d] ?? 0), 0);
  const weekDays = (ws: string) =>
    Array.from({ length: 7 }, (_, i) => addDays(ws, i));
  if (dates.length) {
    for (let ws = weekStart(dates[0]); ws < currentWeek; ws = addDays(ws, 7)) {
      const days = weekDays(ws);
      freezes = Math.min(MAX_FREEZES, freezes + earned(days));
      const shortfall = Math.max(
        0,
        DAYS_PER_WEEK - days.filter(qualifies).length,
      );
      if (shortfall <= freezes) {
        freezes -= shortfall;
        streak++;
      } else {
        streak = 0;
      }
    }
  }

  const thisWeek = weekDays(currentWeek).map((date) => ({
    date,
    seconds: activity[date] ?? 0,
    qualifies: qualifies(date),
  }));
  const thisWeekDays = thisWeek.filter((d) => d.qualifies).length;
  // freezes earned this week are usable now too
  freezes = Math.min(
    MAX_FREEZES,
    freezes + earned(thisWeek.map((d) => d.date)),
  );
  const todaySeconds = activity[today] ?? 0;
  let day = qualifies(today) ? today : addDays(today, -1);
  let dayStreak = 0;
  for (; qualifies(day); day = addDays(day, -1)) dayStreak++; // ponytail: freezes only protect the weekly streak

  return {
    weekStreak: streak + (thisWeekDays >= DAYS_PER_WEEK ? 1 : 0),
    dayStreak,
    thisWeekDays,
    thisWeek,
    freezes,
    todaySeconds,
    todayDone: todaySeconds >= DAILY_GOAL_S,
  };
}

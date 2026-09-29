import { addDays } from "./dates.ts";
import type { Outcome } from "../../shared/types.ts";

export const INTERVALS = [1, 3, 7, 21, 60]; // days

/** First review after a solve: clean solves wait longer, assisted ones come back tomorrow. */
export function firstReview(outcome: Outcome, today: string) {
  const idx = outcome === "solved" ? 1 : 0;
  return { idx, due: addDays(today, INTERVALS[idx]) };
}

export function nextReview(idx: number, passed: boolean, today: string) {
  const next = passed ? Math.min(idx + 1, INTERVALS.length - 1) : 0;
  return { idx: next, due: addDays(today, INTERVALS[next]) };
}

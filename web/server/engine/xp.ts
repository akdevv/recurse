import type { Difficulty, Outcome } from "../../shared/types.ts";

const BASE: Record<Difficulty, number> = { Easy: 20, Medium: 40, Hard: 80 };

export function outcomeOf(hintsUsed: number, solutionViewed: boolean): Outcome {
  if (solutionViewed) return "assisted";
  return hintsUsed > 0 ? "hinted" : "solved";
}

/** Effort-based: unassisted > hinted > solution-viewed. Time spent alone never gives XP. */
export function solveXp(
  d: Difficulty,
  hintsUsed: number,
  solutionViewed: boolean,
  optional: boolean,
): number {
  let xp = BASE[d];
  if (solutionViewed) xp *= 0.2;
  else xp *= 1 - 0.25 * Math.min(hintsUsed, 2);
  if (optional) xp *= 1.25;
  return Math.round(xp);
}

export const QUIZ_XP_PER_CORRECT = 5;
export const EXPLAIN_XP = 15;
export const REVIEW_XP = 10;
export const GRADE_XP_PER_POINT = 5; // per point above your previous best explain score

// Level L needs 50·L·(L-1) total XP: L2 = 100, L3 = 300, L4 = 600, L5 = 1000 …
export function levelInfo(xp: number) {
  let level = 1;
  while (50 * (level + 1) * level <= xp) level++;
  const floor = 50 * level * (level - 1);
  const next = 50 * (level + 1) * level;
  return {
    level,
    xp,
    into: xp - floor,
    need: next - floor,
    title: TITLES[Math.min(level - 1, TITLES.length - 1)],
  };
}

const TITLES = [
  "Novice",
  "Loop Learner",
  "Big-O Spotter",
  "Array Apprentice",
  "Hash Handler",
  "Pointer Pilot",
  "Window Walker",
  "Search Seeker",
  "List Linker",
  "Stack Stacker",
  "Recursion Rider",
  "Tree Climber",
  "Heap Keeper",
  "Graph Walker",
  "Greedy Gambler",
  "DP Initiate",
  "DP Adept",
  "Algorithm Artisan",
];

import type { Difficulty } from "@shared/types.ts";

export const DIFFICULTIES: Difficulty[] = ["Easy", "Medium", "Hard"];

export const DIFF_TONE: Record<
  Difficulty,
  { text: string; bar: string; badge: string }
> = {
  Easy: {
    text: "text-success",
    bar: "bg-success",
    badge: "bg-success/10 text-success",
  },
  Medium: {
    text: "text-warning",
    bar: "bg-warning",
    badge: "bg-warning/10 text-warning",
  },
  Hard: {
    text: "text-destructive",
    bar: "bg-destructive",
    badge: "bg-destructive/10 text-destructive",
  },
};

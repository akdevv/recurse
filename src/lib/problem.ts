import type { JudgeResult, Outcome } from "@shared/types.ts";

export type RunOutput = {
  id: number;
  kind: "run" | "submit";
  res: JudgeResult;
  outcome?: Outcome | null;
};

export const OUTCOME_LABEL: Record<Outcome, string> = {
  solved: "Solved clean",
  hinted: "Solved with hints",
  assisted: "Solved after viewing the solution",
};

/** A solution's explanation followed by its code, as one markdown document. */
export const solutionMarkdown = (s: { md: string; code: string }) =>
  `${s.md}\n\n\`\`\`python\n${s.code}\`\`\``;

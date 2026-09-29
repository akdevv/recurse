export type Progress = "done" | "started" | "new";

const SOLVED = new Set(["solved", "hinted", "assisted"]);

export const problemProgress = (status: string): Progress =>
  SOLVED.has(status) ? "done" : status === "in-progress" ? "started" : "new";

export const PROGRESS_BAR: Record<Progress, string> = {
  done: "bg-success",
  started: "bg-primary",
  new: "bg-foreground/10",
};

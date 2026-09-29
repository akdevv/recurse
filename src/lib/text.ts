export const slugify = (s: string) =>
  s
    .toLowerCase()
    .replace(/<[^>]+>/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");

export const lcId = (n: number) => String(n).padStart(4, "0");

export const pad2 = (n: number) => String(n).padStart(2, "0");

/** Appends dictated text to what's already typed. */
export const appendSpeech = (typed: string, spoken: string) =>
  (typed.trim() ? typed.trimEnd() + " " : "") + spoken;

/** "29 Sep" */
export const shortDate = (iso: string) =>
  new Date(iso).toLocaleDateString("en", { day: "numeric", month: "short" });

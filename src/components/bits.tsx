import { DIFF_TONE } from "@/lib/difficulty.ts";
import type { Difficulty } from "@shared/types.ts";

export function Diff({ d }: { d: Difficulty | null }) {
  if (!d) return null;
  return (
    <span
      className={`rounded-full px-2 py-0.5 text-[11px] font-medium ${DIFF_TONE[d].badge}`}
    >
      {d}
    </span>
  );
}

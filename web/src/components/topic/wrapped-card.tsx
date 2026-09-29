import type { ReactNode } from "react";
import { LuAward } from "react-icons/lu";
import type { TopicWrapped } from "@shared/types.ts";

const fmtTime = (s: number) => {
  const h = Math.floor(s / 3600);
  const m = Math.round((s % 3600) / 60);
  return h ? `${h}h ${m}m` : `${m}m`;
};
const pct = (x: number) => `${Math.round(x * 100)}%`;

/** Shown once a topic is mastered: what it took, in numbers. */
export default function WrappedCard({
  title,
  w,
}: {
  title: string;
  w: TopicWrapped;
}) {
  const explain = Math.max(w.bestExplain ?? -1, w.bestProblemExplain ?? -1);
  const line =
    w.hintFree >= 0.999
      ? "Every problem solved without a single hint."
      : w.hintFree >= 0.6
        ? `${pct(w.hintFree)} of it without hints.`
        : "You pushed through the hard parts.";

  return (
    <div className="overflow-hidden rounded-2xl border border-success/25 bg-gradient-to-br from-success/10 via-card to-card">
      <div className="flex items-center gap-4 px-6 pt-5 pb-4">
        <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-success/15 text-success ring-1 ring-success/25 ring-inset">
          <LuAward className="size-5" />
        </span>
        <div className="min-w-0 flex-1">
          <div className="text-xs font-medium text-success">
            Topic mastered
            {w.masteredAt &&
              ` · ${new Date(w.masteredAt).toLocaleDateString("en", { day: "numeric", month: "short", year: "numeric" })}`}
          </div>
          <div className="text-lg font-semibold tracking-tight text-balance">
            {title}, wrapped
          </div>
          <div className="text-sm text-muted-foreground">{line}</div>
        </div>
      </div>
      <dl className="grid grid-cols-2 border-t border-success/15 sm:grid-cols-5">
        <Stat label="Focused time">{fmtTime(w.seconds)}</Stat>
        <Stat label="Problems solved">
          {w.solved}
          <span className="text-sm font-normal text-muted-foreground">
            /{w.total}
          </span>
          {w.optional > 0 && (
            <span className="ml-1 text-xs font-normal text-success">
              +{w.optional} optional
            </span>
          )}
        </Stat>
        <Stat label="Hint-free">{w.solved ? pct(w.hintFree) : "–"}</Stat>
        <Stat label="Quiz best">
          {w.quizBest === null ? "–" : pct(w.quizBest)}
        </Stat>
        <Stat label="Best explanation">
          {explain < 0 ? (
            "–"
          ) : (
            <>
              {explain}
              <span className="text-sm font-normal text-muted-foreground">
                /5
              </span>
            </>
          )}
        </Stat>
      </dl>
    </div>
  );
}

function Stat({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5 border-success/15 px-6 py-3.5 not-last:border-r max-sm:odd:border-r max-sm:[&:nth-child(n+3)]:border-t">
      <dt className="text-xs text-muted-foreground">{label}</dt>
      <dd className="text-lg font-semibold tracking-tight tabular-nums">
        {children}
      </dd>
    </div>
  );
}

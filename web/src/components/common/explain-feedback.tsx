import { useState } from "react";
import {
  LuCircle,
  LuCircleCheck,
  LuLoaderCircle,
  LuMessageSquareQuote,
  LuSparkles,
} from "react-icons/lu";
import { post, useApi, xpToast } from "@/lib/api.ts";
import Button from "@/components/common/button.tsx";
import type { Grade } from "@shared/types.ts";

const VERDICT = (s: number) =>
  s >= 5
    ? {
        label: "Interview-ready",
        tone: "bg-success/10 text-success ring-success/20",
      }
    : s >= 4
      ? { label: "Strong", tone: "bg-success/10 text-success ring-success/20" }
      : s >= 3
        ? {
            label: "Getting there",
            tone: "bg-warning/10 text-warning ring-warning/20",
          }
        : {
            label: "Needs work",
            tone: "bg-destructive/10 text-destructive ring-destructive/20",
          };

/** Key-point checklist plus AI grading of an explanation. `answer` is what gets graded. */
export default function ExplainFeedback({
  kind,
  refId,
  answer,
  keyPoints,
  className = "px-6 py-5",
}: {
  kind: "topic" | "problem";
  refId: string;
  answer: string;
  keyPoints: string[];
  className?: string;
}) {
  const [saved] = useApi<{ grade: Grade | null }>(`/grades/${kind}/${refId}`);
  const [fresh, setFresh] = useState<Grade | null>(null);
  const [manual, setManual] = useState<Set<number> | null>(null);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");
  const grade = fresh ?? saved?.grade ?? null;

  const covered =
    manual ??
    new Set(
      grade ? keyPoints.flatMap((_, i) => (grade.covered?.[i] ? [i] : [])) : [],
    );
  const toggle = (i: number) => {
    const next = new Set(covered);
    if (next.has(i)) next.delete(i);
    else next.add(i);
    setManual(next);
  };

  const run = async () => {
    setBusy(true);
    setErr("");
    try {
      const r = await post<{ grade: Grade; xp: number }>(
        `/grades/${kind}/${refId}`,
        { text: answer },
      );
      setFresh(r.grade);
      setManual(null);
      xpToast(r.xp);
    } catch (e: any) {
      setErr(e.message);
    }
    setBusy(false);
  };

  const v = grade && VERDICT(grade.score);

  return (
    <div className={`flex flex-col gap-4 ${className}`}>
      {grade && v && (
        <div className="flex flex-col gap-3 rounded-lg border border-border bg-background/40 p-4">
          <div className="flex items-center gap-2.5">
            <span
              className={`rounded-full px-2 py-0.5 text-xs font-semibold tabular-nums ring-1 ring-inset ${v.tone}`}
            >
              {grade.score}/5
            </span>
            <span className="text-sm font-medium">{v.label}</span>
            <span className="ml-auto flex items-center gap-1 text-[11px] text-muted-foreground">
              <LuSparkles className="size-3" />
              AI interviewer
            </span>
          </div>
          <p className="text-sm leading-6 text-foreground/85">
            {grade.feedback}
          </p>
          {grade.followUp && (
            <div className="flex gap-2.5 border-t border-border pt-3">
              <LuMessageSquareQuote className="mt-1 size-3.5 shrink-0 text-primary" />
              <p className="text-sm leading-6">
                <span className="text-muted-foreground">Follow-up: </span>
                {grade.followUp}
              </p>
            </div>
          )}
        </div>
      )}

      {keyPoints.length > 0 && (
        <div>
          <div className="flex items-baseline justify-between gap-4">
            <span className="text-sm font-medium">Did you cover these?</span>
            <span className="text-xs text-muted-foreground tabular-nums">
              {covered.size}/{keyPoints.length}
            </span>
          </div>
          <ul className="mt-2 flex flex-col">
            {keyPoints.map((k, i) => {
              const on = covered.has(i);
              return (
                <li key={k}>
                  <button
                    onClick={() => toggle(i)}
                    aria-pressed={on}
                    className="flex w-full gap-3 py-1.5 text-left text-sm leading-6"
                  >
                    {on ? (
                      <LuCircleCheck className="mt-1 size-4 shrink-0 text-success" />
                    ) : (
                      <LuCircle className="mt-1 size-4 shrink-0 text-muted-foreground/40" />
                    )}
                    <span
                      className={
                        on ? "text-foreground" : "text-muted-foreground"
                      }
                    >
                      {k}
                    </span>
                  </button>
                </li>
              );
            })}
          </ul>
        </div>
      )}

      <div className="flex items-center justify-between gap-4">
        <span
          className={`text-xs ${err ? "text-destructive" : "text-muted-foreground"}`}
        >
          {err ||
            (busy
              ? "The interviewer is reading your answer…"
              : "Get an honest score, what you missed and a follow-up question.")}
        </span>
        <Button
          size="sm"
          variant="secondary"
          disabled={busy || answer.trim().length < 20}
          onClick={run}
        >
          {busy ? (
            <LuLoaderCircle className="size-3.5 animate-spin" />
          ) : (
            <LuSparkles className="size-3.5 text-primary" />
          )}
          {grade ? "Grade again" : "Grade with AI"}
        </Button>
      </div>
    </div>
  );
}

import { useState } from "react";
import {
  LuCheck,
  LuChevronLeft,
  LuChevronRight,
  LuRotateCcw,
  LuX,
} from "react-icons/lu";
import { post, xpToast } from "@/lib/api.ts";
import { QUIZ_PASS } from "@/lib/topic-steps.ts";
import Button from "@/components/common/button.tsx";
import CodeBlock from "@/components/common/code-block.tsx";
import InlineText from "@/components/common/inline-text.tsx";
import type { QuizQ } from "@shared/types.ts";

type Result = { correct: boolean[]; score: number; total: number };

const letter = (i: number) => String.fromCharCode(65 + i);

export default function Quiz({
  topicId,
  quiz,
  best,
  onDone,
}: {
  topicId: string;
  quiz: QuizQ[];
  best: number | null;
  onDone: () => void;
}) {
  const [answers, setAnswers] = useState<(number | null)[]>(() =>
    quiz.map(() => null),
  );
  const [idx, setIdx] = useState(0);
  const [result, setResult] = useState<Result | null>(null);

  const retry = () => {
    setAnswers(quiz.map(() => null));
    setIdx(0);
    setResult(null);
  };

  if (result)
    return (
      <Results quiz={quiz} answers={answers} result={result} onRetry={retry} />
    );

  const q = quiz[idx];
  const picked = answers[idx];
  const answered = answers.filter((a) => a !== null).length;
  const allAnswered = answered === quiz.length;

  const go = (k: number) => setIdx(Math.max(0, Math.min(quiz.length - 1, k)));
  const pick = (oi: number) =>
    setAnswers(answers.map((a, k) => (k === idx ? oi : a)));
  const submit = async () => {
    const r = await post<Result & { xp: number }>(`/topics/${topicId}/quiz`, {
      answers,
    });
    setResult(r);
    xpToast(r.xp);
    onDone();
  };

  const onKey = (e: React.KeyboardEvent) => {
    const n =
      "1234".indexOf(e.key) + 1 || "abcd".indexOf(e.key.toLowerCase()) + 1;
    if (n && n <= q.options.length) pick(n - 1);
    else if (e.key === "ArrowRight") go(idx + 1);
    else if (e.key === "ArrowLeft") go(idx - 1);
    else if (e.key === "Enter") {
      if (idx < quiz.length - 1) go(idx + 1);
      else if (allAnswered) submit();
    }
  };

  return (
    <div
      tabIndex={0}
      onKeyDown={onKey}
      title="Keys: 1–4 to answer, ← → to move"
      className="overflow-hidden rounded-xl border border-border bg-card outline-none focus-visible:ring-[3px] focus-visible:ring-ring/30"
    >
      <div className="flex items-center justify-between gap-4 border-b border-border px-4 py-2.5">
        <NavButton
          onClick={() => go(idx - 1)}
          disabled={idx === 0}
          aria-label="Previous question"
        >
          <LuChevronLeft className="size-4" />
          Prev
        </NavButton>
        <span className="text-xs text-muted-foreground tabular-nums">
          Question{" "}
          <span className="font-medium text-foreground">{idx + 1}</span> of{" "}
          {quiz.length}
        </span>
        <NavButton
          onClick={() => go(idx + 1)}
          disabled={idx === quiz.length - 1}
          aria-label="Next question"
        >
          Next
          <LuChevronRight className="size-4" />
        </NavButton>
      </div>

      <div className="flex flex-col gap-5 px-6 py-6">
        <p className="text-base leading-7 font-medium">
          <InlineText text={q.q} />
        </p>

        {q.code && <CodeBlock code={q.code} />}

        <div className="grid gap-2">
          {q.options.map((o, oi) => {
            const on = picked === oi;
            return (
              <button
                key={oi}
                onClick={() => pick(oi)}
                aria-pressed={on}
                className={`group flex min-h-11 items-center gap-3 rounded-lg px-3.5 py-2.5 text-left text-sm ring-1 transition-all ring-inset ${
                  on
                    ? "bg-primary/10 text-foreground ring-primary/60"
                    : "text-foreground/85 ring-border hover:bg-accent/40 hover:ring-foreground/20"
                }`}
              >
                <span
                  className={`grid size-5 shrink-0 place-items-center rounded font-mono text-[10px] font-medium transition-colors ${
                    on
                      ? "bg-primary text-primary-foreground"
                      : "bg-secondary text-muted-foreground group-hover:text-foreground"
                  }`}
                >
                  {letter(oi)}
                </span>
                <span className="flex-1">
                  <InlineText text={o} />
                </span>
              </button>
            );
          })}
        </div>
      </div>

      <div className="flex items-center justify-between gap-4 border-t border-border px-6 py-3.5">
        <span className="text-xs text-muted-foreground tabular-nums">
          {answered} of {quiz.length} answered
          {best !== null && (
            <span className="text-muted-foreground/60">
              {" "}
              · best {Math.round(best * 100)}%
            </span>
          )}
        </span>
        <Button size="sm" onClick={submit} disabled={!allAnswered}>
          Check answers
        </Button>
      </div>
    </div>
  );
}

function Results({
  quiz,
  answers,
  result,
  onRetry,
}: {
  quiz: QuizQ[];
  answers: (number | null)[];
  result: Result;
  onRetry: () => void;
}) {
  const passed = result.score / result.total >= QUIZ_PASS;
  const need = Math.ceil(result.total * QUIZ_PASS);

  return (
    <div className="overflow-hidden rounded-xl border border-border bg-card">
      <div className="flex items-center justify-between gap-4 px-6 py-5">
        <div>
          <div className="flex items-center gap-2.5">
            <span className="text-lg font-semibold tabular-nums">
              {result.score} of {result.total} correct
            </span>
            <span
              className={`rounded-full px-2 py-0.5 text-[11px] font-medium ${
                passed
                  ? "bg-success/15 text-success"
                  : "bg-warning/15 text-warning"
              }`}
            >
              {passed ? "Passed" : "Not passed"}
            </span>
          </div>
          <p className="mt-0.5 text-sm text-muted-foreground">
            {passed
              ? "Nice work. Move on to the problems."
              : `You need ${need} to pass. Check what you missed, then retake.`}
          </p>
        </div>
        <Button variant="secondary" size="sm" onClick={onRetry}>
          <LuRotateCcw className="size-3.5" />
          Retake
        </Button>
      </div>

      <ol className="divide-y divide-border border-t border-border">
        {quiz.map((q, qi) => {
          const ok = result.correct[qi];
          const mine = answers[qi];
          return (
            <li key={q.id} className="flex gap-3 px-6 py-4">
              {ok ? (
                <LuCheck className="mt-1 size-4 shrink-0 text-success" />
              ) : (
                <LuX className="mt-1 size-4 shrink-0 text-destructive" />
              )}
              <div className="flex min-w-0 flex-1 flex-col gap-1">
                <p className="text-sm leading-6">
                  <InlineText text={q.q} />
                </p>
                {!ok && (
                  <>
                    <p className="text-[13px] leading-6 text-muted-foreground">
                      {mine !== null && (
                        <>
                          <span className="line-through decoration-muted-foreground/50">
                            <InlineText text={q.options[mine]} />
                          </span>
                          <span className="mx-1.5">→</span>
                        </>
                      )}
                      <span className="font-medium text-success">
                        <InlineText text={q.options[q.answer]} />
                      </span>
                    </p>
                    <p className="text-[13px] leading-6 text-muted-foreground">
                      <InlineText text={q.why} />
                    </p>
                  </>
                )}
              </div>
            </li>
          );
        })}
      </ol>
    </div>
  );
}

function NavButton({
  children,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      {...props}
      className="flex h-8 items-center gap-1 rounded-md px-2.5 text-xs font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-foreground disabled:pointer-events-none disabled:opacity-30"
    >
      {children}
    </button>
  );
}

import { useEffect, useState } from "react";
import { Link } from "react-router";
import type { IconType } from "react-icons";
import {
  LuBookOpen,
  LuCalendarClock,
  LuChevronDown,
  LuCircleCheck,
  LuCode,
  LuEye,
  LuMessageSquareQuote,
  LuPartyPopper,
  LuRotateCcw,
} from "react-icons/lu";
import { post, useApi, xpToast } from "@/lib/api.ts";
import { appendSpeech } from "@/lib/text.ts";
import { solutionMarkdown } from "@/lib/problem.ts";
import Markdown from "@/components/markdown.tsx";
import Button from "@/components/common/button.tsx";
import ExplainFeedback from "@/components/common/explain-feedback.tsx";
import MicButton from "@/components/common/mic-button.tsx";
import { Diff } from "@/components/bits.tsx";
import type { Difficulty } from "@shared/types.ts";

type Item = {
  type: "problem" | "topic";
  id: string;
  title: string;
  difficulty: Difficulty | null;
  due: string;
  interval: number;
  next: { pass: number; fail: number };
  prompt: string;
  keyPoints: string[];
  reveal: {
    title: string;
    time: string;
    space: string;
    code: string;
    md: string;
  } | null;
};
type Upcoming = { type: string; id: string; title: string; due: string };

const TYPE_ICON: Record<string, IconType> = {
  problem: LuCode,
  topic: LuBookOpen,
};

const days = (n: number) => (n === 1 ? "1 day" : `${n} days`);

export default function Review() {
  const [d, reload] = useApi<{ items: Item[]; upcoming: Upcoming[] }>(
    "/reviews",
  );
  const [done, setDone] = useState(0);
  if (!d) return null;

  const it = d.items[0];
  const total = d.items.length + done;

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-8 py-8">
      {it ? (
        <>
          <div className="flex flex-col gap-4">
            <div className="flex items-end justify-between gap-6">
              <div>
                <h1 className="text-xl font-semibold tracking-tight">
                  Today's review
                </h1>
                <p className="mt-1 text-sm text-muted-foreground">
                  Recall each one before you look. Forgetting costs no XP.
                </p>
              </div>
              <div className="shrink-0 text-right">
                <div className="text-[11px] font-medium tracking-wider text-muted-foreground/70 uppercase">
                  Card
                </div>
                <div className="tabular-nums">
                  <span className="text-2xl font-semibold tracking-tight">
                    {done + 1}
                  </span>
                  <span className="text-sm text-muted-foreground">
                    {" "}
                    / {total}
                  </span>
                </div>
              </div>
            </div>
            <div className="flex gap-1.5">
              {Array.from({ length: total }, (_, i) => (
                <span
                  key={i}
                  className={`h-1.5 flex-1 rounded-full transition-colors ${
                    i < done
                      ? "bg-success"
                      : i === done
                        ? "bg-primary"
                        : "bg-secondary"
                  }`}
                />
              ))}
            </div>
          </div>
          <Card
            key={`${it.type}:${it.id}`}
            it={it}
            onGrade={async (passed) => {
              const r = await post("/reviews", {
                type: it.type,
                id: it.id,
                passed,
              });
              xpToast(r.xp);
              reload();
              setDone(done + 1);
            }}
          />
        </>
      ) : (
        <AllClear done={done} />
      )}

      {d.upcoming.length > 0 && <ComingUp items={d.upcoming} />}
    </div>
  );
}

function Card({
  it,
  onGrade: grade,
}: {
  it: Item;
  onGrade: (passed: boolean) => void;
}) {
  const [notes, setNotes] = useState("");
  const [revealed, setRevealed] = useState(false);
  const [showRef, setShowRef] = useState(false);
  const Icon = TYPE_ICON[it.type] ?? LuCode;

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.target instanceof HTMLTextAreaElement || e.metaKey || e.ctrlKey)
        return;
      if (!revealed && e.key === " ") {
        e.preventDefault();
        setRevealed(true);
      } else if (revealed && e.key === "1") grade(false);
      else if (revealed && e.key === "2") grade(true);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  });

  return (
    <div className="overflow-hidden rounded-xl border border-border bg-card">
      <div className="flex items-center gap-3 border-b border-border px-6 py-4">
        <span className="grid size-8 shrink-0 place-items-center rounded-md bg-primary/10 text-primary ring-1 ring-primary/20 ring-inset">
          <Icon className="size-4" />
        </span>
        <div className="flex min-w-0 flex-1 flex-col">
          <span className="truncate font-semibold tracking-tight">
            {it.title}
          </span>
          <span className="text-xs text-muted-foreground">
            {it.type === "problem" ? "Problem" : "Topic"} · last seen{" "}
            {days(it.interval)} ago
          </span>
        </div>
        <Diff d={it.difficulty} />
      </div>

      <div className="px-6 pt-5 pb-4">
        <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
          <LuMessageSquareQuote className="size-3.5 text-primary" />
          Interviewer
        </div>
        <p className="mt-1 text-[15px] leading-7 font-medium">{it.prompt}</p>
      </div>

      <textarea
        value={notes}
        onChange={(e) => setNotes(e.target.value)}
        placeholder="Recall it from memory first. Writing it down is optional, but it helps."
        className="block min-h-32 w-full resize-y border-y border-border bg-background/40 px-6 py-4 text-sm leading-6 outline-none placeholder:text-muted-foreground/60 focus:bg-background/70"
      />

      {!revealed ? (
        <div className="flex items-center justify-between gap-4 px-6 py-3.5">
          <span className="text-xs text-muted-foreground">
            Press <Kbd>Space</Kbd> to check yourself
          </span>
          <div className="flex items-center gap-2">
            <MicButton onText={(t) => setNotes((s) => appendSpeech(s, t))} />
            <Button size="sm" onClick={() => setRevealed(true)}>
              <LuEye className="size-3.5" />
              Show answer
            </Button>
          </div>
        </div>
      ) : (
        <>
          <ExplainFeedback
            kind={it.type}
            refId={it.id}
            answer={notes}
            keyPoints={it.keyPoints}
          />

          {it.reveal && (
            <div className="border-t border-border">
              <button
                onClick={() => setShowRef(!showRef)}
                aria-expanded={showRef}
                className="flex w-full items-center gap-3 px-6 py-3.5 text-left text-sm transition-colors hover:bg-accent/40"
              >
                <span className="font-medium">Reference solution</span>
                <span className="text-xs text-muted-foreground">
                  {it.reveal.title}
                </span>
                <span className="ml-auto flex gap-1.5 font-mono text-[11px] text-muted-foreground">
                  <span className="rounded bg-secondary px-1.5 py-0.5">
                    {it.reveal.time} time
                  </span>
                  <span className="rounded bg-secondary px-1.5 py-0.5">
                    {it.reveal.space} space
                  </span>
                </span>
                <LuChevronDown
                  className={`size-4 shrink-0 text-muted-foreground transition-transform ${showRef ? "rotate-180" : ""}`}
                />
              </button>
              {showRef && (
                <div className="px-6 pb-5">
                  <Markdown text={solutionMarkdown(it.reveal)} />
                </div>
              )}
            </div>
          )}

          <div className="flex flex-wrap items-center gap-2 border-t border-border bg-background/30 px-6 py-3.5">
            {it.type === "problem" && (
              <Link
                to={`/problems/${it.id}`}
                className="flex h-8 items-center gap-1.5 rounded-md px-2.5 text-xs font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
              >
                <LuRotateCcw className="size-3.5" />
                Re-solve it
              </Link>
            )}
            <div className="ml-auto flex items-center gap-2">
              <GradeButton
                variant="secondary"
                hotkey="1"
                label="Forgot"
                hint={`again in ${days(it.next.fail)}`}
                onClick={() => grade(false)}
              />
              <GradeButton
                variant="primary"
                hotkey="2"
                label="Got it"
                hint={`next in ${days(it.next.pass)}`}
                onClick={() => grade(true)}
              />
            </div>
          </div>
        </>
      )}
    </div>
  );
}

function GradeButton({
  variant,
  hotkey,
  label,
  hint,
  onClick,
}: {
  variant: "primary" | "secondary";
  hotkey: string;
  label: string;
  hint: string;
  onClick: () => void;
}) {
  return (
    <Button
      variant={variant}
      onClick={onClick}
      title={`Press ${hotkey}`}
      className="h-auto flex-col gap-0 px-4 py-1.5"
    >
      <span>{label}</span>
      <span
        className={`text-[10px] font-normal ${variant === "primary" ? "text-primary-foreground/70" : "text-muted-foreground"}`}
      >
        {hint}
      </span>
    </Button>
  );
}

function AllClear({ done }: { done: number }) {
  return (
    <div className="flex flex-col items-center gap-2 rounded-xl border border-border bg-card px-6 py-12 text-center">
      <span className="mb-2 grid size-11 place-items-center rounded-xl bg-success/10 text-success ring-1 ring-success/20 ring-inset">
        {done ? (
          <LuPartyPopper className="size-5" />
        ) : (
          <LuCircleCheck className="size-5" />
        )}
      </span>
      <h1 className="text-lg font-semibold tracking-tight">
        {done
          ? `Session done: ${done} review${done === 1 ? "" : "s"}`
          : "All caught up"}
      </h1>
      <p className="max-w-md text-sm leading-6 text-muted-foreground">
        Solved problems and finished topics come back here after 1, 3, 7, 21 and
        60 days. Recalling them right before you'd forget is what makes them
        stick.
      </p>
    </div>
  );
}

function ComingUp({ items }: { items: Upcoming[] }) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const when = (due: string) => {
    const n = Math.round(
      (new Date(`${due}T00:00:00`).getTime() - today.getTime()) / 86_400_000,
    );
    return n <= 1 ? "Tomorrow" : `In ${n} days`;
  };

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center gap-2 text-xs font-medium text-muted-foreground">
        <LuCalendarClock className="size-3.5" />
        Coming up
      </div>
      <ul className="divide-y divide-border overflow-hidden rounded-xl border border-border bg-card">
        {items.map((u) => {
          const Icon = TYPE_ICON[u.type] ?? LuCode;
          return (
            <li
              key={`${u.type}:${u.id}`}
              className="flex h-11 items-center gap-3 px-5 text-sm"
            >
              <Icon className="size-4 shrink-0 text-muted-foreground" />
              <span className="min-w-0 flex-1 truncate">{u.title}</span>
              <span className="text-xs text-muted-foreground capitalize">
                {u.type}
              </span>
              <span
                className="w-20 text-right text-xs text-muted-foreground tabular-nums"
                title={u.due}
              >
                {when(u.due)}
              </span>
            </li>
          );
        })}
      </ul>
    </div>
  );
}

function Kbd({ children }: { children: string }) {
  return (
    <kbd className="mx-0.5 rounded border border-border bg-secondary px-1 py-px font-mono text-[10px] text-muted-foreground">
      {children}
    </kbd>
  );
}

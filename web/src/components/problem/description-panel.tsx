import { useState, type ReactNode } from "react";
import {
  LuCircleCheck,
  LuCircleX,
  LuFileText,
  LuFlaskConical,
  LuHistory,
  LuLightbulb,
  LuLock,
  LuMessageCircle,
} from "react-icons/lu";
import TutorPanel from "@/components/problem/tutor-panel.tsx";
import { fmtClock } from "@/lib/api.ts";
import { lcId } from "@/lib/text.ts";
import { solutionMarkdown } from "@/lib/problem.ts";
import Markdown from "@/components/markdown.tsx";
import Button from "@/components/common/button.tsx";
import { Diff } from "@/components/bits.tsx";
import { Pane, PaneHeader, Tab } from "@/components/problem/pane.tsx";
import type { ProblemView } from "@shared/types.ts";

type TabId = "statement" | "hints" | "tutor" | "solutions" | "submissions";

export default function DescriptionPanel({
  v,
  open,
  active,
  onAct,
  getCode,
}: {
  v: ProblemView;
  open: boolean;
  active: number;
  onAct: (path: "hint" | "solution") => void;
  getCode: () => string;
}) {
  const [tab, setTab] = useState<TabId>("statement");

  return (
    <Pane>
      <PaneHeader>
        <Tab
          icon={LuFileText}
          active={tab === "statement"}
          onClick={() => setTab("statement")}
        >
          Description
        </Tab>
        <Tab
          icon={LuLightbulb}
          active={tab === "hints"}
          onClick={() => setTab("hints")}
        >
          Hints
          <span className="text-muted-foreground tabular-nums">
            {v.hints.length}/{v.hintCount}
          </span>
        </Tab>
        <Tab
          icon={v.tutor.unlocked ? LuMessageCircle : LuLock}
          active={tab === "tutor"}
          onClick={() => setTab("tutor")}
        >
          Tutor
        </Tab>
        <Tab
          icon={v.solutions ? LuFlaskConical : LuLock}
          active={tab === "solutions"}
          onClick={() => setTab("solutions")}
        >
          Solutions
        </Tab>
        <Tab
          icon={LuHistory}
          active={tab === "submissions"}
          onClick={() => setTab("submissions")}
        >
          Submissions
        </Tab>
      </PaneHeader>

      <div className="min-h-0 flex-1 overflow-y-auto">
        {tab === "statement" && <Statement v={v} />}
        {tab === "hints" && (
          <Hints v={v} open={open} active={active} onAct={onAct} />
        )}
        {tab === "tutor" && (
          <TutorPanel key={v.attempt?.id} v={v} getCode={getCode} />
        )}
        {tab === "solutions" && (
          <Solutions v={v} open={open} active={active} onAct={onAct} />
        )}
        {tab === "submissions" && <Submissions v={v} />}
      </div>
    </Pane>
  );
}

function Statement({ v }: { v: ProblemView }) {
  return (
    <div className="flex flex-col gap-5 px-6 py-5">
      <div className="flex flex-col gap-3">
        <h1 className="text-xl font-semibold tracking-tight text-balance">
          {v.problem.lc && (
            <span className="text-muted-foreground">
              {lcId(v.problem.lc.id)}.{" "}
            </span>
          )}
          {v.problem.title}
        </h1>
        <div className="flex items-center gap-2">
          <Diff d={v.problem.difficulty} />
          {v.home?.role && v.home.role !== "core" && (
            <span className="rounded-full bg-secondary px-2 py-0.5 text-[11px] font-medium text-muted-foreground capitalize">
              {v.home.role}
            </span>
          )}
        </div>
      </div>
      <div
        className="prose max-w-none prose-invert prose-p:text-sm prose-p:leading-7 prose-p:text-foreground/80 prose-strong:font-semibold prose-strong:text-foreground prose-code:rounded prose-code:bg-secondary prose-code:px-1.5 prose-code:py-0.5 prose-code:text-[0.85em] prose-code:font-normal prose-code:text-foreground prose-code:before:content-none prose-code:after:content-none prose-pre:rounded-lg prose-pre:border prose-pre:border-border prose-pre:bg-background/60 prose-pre:px-4 prose-pre:py-3 prose-pre:text-[13px] prose-pre:leading-6 prose-pre:text-foreground/85 prose-ul:text-sm prose-ul:text-foreground/80 prose-li:my-1 prose-li:marker:text-muted-foreground/70 prose-img:rounded-lg [&_pre_code]:bg-transparent [&_pre_code]:p-0"
        dangerouslySetInnerHTML={{
          __html: v.statement.replace(/<p>(&nbsp;|\s)*<\/p>/g, ""),
        }}
      />
    </div>
  );
}

type Gated = {
  v: ProblemView;
  open: boolean;
  active: number;
  onAct: (path: "hint" | "solution") => void;
};

function Hints({ v, open, active, onAct }: Gated) {
  const next = v.hints.length + 1;
  const more = open && v.hints.length < v.hintCount;
  const ready =
    v.unlocks.hintsAvailable > v.hints.length ||
    (v.unlocks.nextHintAt !== null && active >= v.unlocks.nextHintAt);

  return (
    <div className="flex flex-col gap-3 px-6 py-5">
      {!v.boss && (
        <p className="text-sm leading-6 text-muted-foreground">
          Hints unlock with active time on this attempt. Each one you reveal
          costs 25% of the XP, so try first.
        </p>
      )}

      {v.hints.map((h, i) => (
        <div
          key={i}
          className="rounded-lg border border-border bg-background/40 px-4 py-3"
        >
          <div className="flex items-center gap-1.5 text-xs font-medium text-warning">
            <LuLightbulb className="size-3.5" />
            Hint {i + 1}
          </div>
          <p className="mt-1.5 text-sm leading-6 text-foreground/85">{h}</p>
        </div>
      ))}

      {more && (
        <div className="flex items-center justify-between gap-4 rounded-lg border border-dashed border-border px-4 py-3">
          <span className="flex items-center gap-2 text-sm text-muted-foreground">
            <LuLock className="size-3.5" />
            Hint {next}
            {!ready && (
              <span className="tabular-nums">
                · unlocks in{" "}
                {fmtClock(Math.max(0, (v.unlocks.nextHintAt ?? 0) - active))}
              </span>
            )}
          </span>
          {ready && (
            <Button size="sm" variant="secondary" onClick={() => onAct("hint")}>
              Reveal hint {next}
            </Button>
          )}
        </div>
      )}

      {!open && v.hints.length === 0 && (
        <Empty icon={<LuLightbulb className="size-4" />}>
          {v.boss
            ? "No hints in a boss fight. It's a mock interview."
            : "No hints used on this attempt."}
        </Empty>
      )}
    </div>
  );
}

function Solutions({ v, open, active, onAct }: Gated) {
  if (!v.solutions) {
    const ready = v.unlocks.solutionAvailable || active >= v.unlocks.solutionAt;
    return (
      <Empty icon={<LuLock className="size-4" />}>
        <span className="font-medium text-foreground">
          {v.solutionCount} solution{v.solutionCount === 1 ? "" : "s"}, brute
          force to optimal
        </span>
        <span>Unlocks when you solve it, or after 30 min of active work.</span>
        {open &&
          (ready ? (
            <Button
              size="sm"
              variant="secondary"
              className="mt-3"
              onClick={() => onAct("solution")}
            >
              Show solutions (XP drops to 20%)
            </Button>
          ) : (
            <span className="mt-2 rounded-full bg-secondary px-2.5 py-1 text-xs tabular-nums">
              Available in{" "}
              {fmtClock(Math.max(0, v.unlocks.solutionAt - active))}
            </span>
          ))}
      </Empty>
    );
  }

  return (
    <div className="flex flex-col divide-y divide-border">
      {v.solutions.map((s, i) => (
        <article key={s.id} className="flex flex-col gap-3 px-6 py-5">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-xs text-muted-foreground tabular-nums">
              {i + 1}.
            </span>
            <h3 className="font-semibold tracking-tight">{s.title}</h3>
            {s.reference && (
              <span className="rounded-full bg-success/10 px-2 py-0.5 text-[11px] font-medium text-success">
                Optimal
              </span>
            )}
            <span className="ml-auto flex gap-1.5 font-mono text-[11px] text-muted-foreground">
              <span className="rounded bg-secondary px-1.5 py-0.5">
                {s.time} time
              </span>
              <span className="rounded bg-secondary px-1.5 py-0.5">
                {s.space} space
              </span>
            </span>
          </div>
          <Markdown text={solutionMarkdown(s)} />
        </article>
      ))}
    </div>
  );
}

function Submissions({ v }: { v: ProblemView }) {
  if (!v.submissions.length)
    return (
      <Empty icon={<LuHistory className="size-4" />}>
        No runs yet. Your runs and submissions show up here.
      </Empty>
    );

  return (
    <ul className="divide-y divide-border">
      {v.submissions.map((s) => {
        const ok = s.verdict === "Accepted";
        return (
          <li key={s.id} className="flex items-center gap-3 px-6 py-3 text-sm">
            {ok ? (
              <LuCircleCheck className="size-4 shrink-0 text-success" />
            ) : (
              <LuCircleX className="size-4 shrink-0 text-destructive" />
            )}
            <span
              className={`font-medium ${ok ? "text-success" : "text-destructive"}`}
            >
              {s.verdict}
            </span>
            <span className="rounded bg-secondary px-1.5 py-0.5 text-[11px] text-muted-foreground capitalize">
              {s.kind}
            </span>
            <span className="text-xs text-muted-foreground tabular-nums">
              {s.passed}/{s.total} tests
            </span>
            <span className="ml-auto text-xs text-muted-foreground/70 tabular-nums">
              {new Date(s.ts).toLocaleString("en", {
                day: "numeric",
                month: "short",
                hour: "numeric",
                minute: "2-digit",
              })}
            </span>
          </li>
        );
      })}
    </ul>
  );
}

function Empty({ icon, children }: { icon: ReactNode; children: ReactNode }) {
  return (
    <div className="flex flex-col items-center gap-1 px-6 py-14 text-center text-sm text-muted-foreground">
      <span className="mb-2 grid size-9 place-items-center rounded-lg bg-secondary text-muted-foreground">
        {icon}
      </span>
      {children}
    </div>
  );
}

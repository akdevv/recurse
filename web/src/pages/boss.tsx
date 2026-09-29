import { useState, type ReactNode } from "react";
import { Link, useNavigate, useParams } from "react-router";
import {
  LuArrowRight,
  LuChevronLeft,
  LuCircleCheck,
  LuCircleX,
  LuLoaderCircle,
  LuMessageSquareQuote,
  LuSwords,
} from "react-icons/lu";
import { emitChest, fmtClock, post, useApi, xpToast } from "@/lib/api.ts";
import { appendSpeech, shortDate } from "@/lib/text.ts";
import Button from "@/components/common/button.tsx";
import MicButton from "@/components/common/mic-button.tsx";
import BossCountdown from "@/components/problem/boss-countdown.tsx";
import TrophyArt from "@/components/rewards/trophy-art.tsx";
import type { EarnedChest, Grade } from "@shared/types.ts";

type Run = {
  id: number;
  problemId: string;
  problemTitle: string;
  startedAt: string;
  deadline: string;
  solvedIn: number | null;
  finished: boolean;
  score: number | null;
  passed: boolean | null;
};
type State = {
  module: {
    id: string;
    number: number;
    title: string;
    limitMin: number;
    topicsLeft: number;
  };
  available: boolean;
  active: Run | null;
  last: Run | null;
  beaten: boolean;
  runs: Run[];
};
type Result = {
  run: Run;
  grade: Grade;
  inTime: boolean;
  xp: number;
  chest: EarnedChest | null;
};

export default function BossRoute() {
  const { moduleId } = useParams();
  return <Boss key={moduleId} moduleId={moduleId!} />;
}

function Boss({ moduleId }: { moduleId: string }) {
  const [s, reload] = useApi<State>(`/boss/${moduleId}`);
  const [result, setResult] = useState<Result | null>(null);
  const [err, setErr] = useState("");
  const nav = useNavigate();
  if (!s) return null;
  const m = s.module;

  const start = async () => {
    try {
      const r = await post<{ problemId: string }>(`/boss/${moduleId}/start`);
      nav(`/problems/${r.problemId}`);
    } catch (e: any) {
      setErr(e.message);
    }
  };
  const abandon = (id: number) => post(`/boss/runs/${id}/abandon`).then(reload);

  let body: ReactNode;
  if (result) body = <ResultCard r={result} onAgain={() => setResult(null)} />;
  else if (s.active?.solvedIn != null)
    body = (
      <ExplainStep
        run={s.active}
        onDone={(r) => {
          setResult(r);
          xpToast(r.xp);
          reload();
          emitChest(r.chest);
        }}
      />
    );
  else if (s.active)
    body = (
      <Card>
        <div className="flex items-center justify-between gap-4 px-6 py-5">
          <div>
            <div className="text-xs font-medium text-muted-foreground">
              In progress
            </div>
            <div className="mt-0.5 font-semibold">{s.active.problemTitle}</div>
          </div>
          <BossCountdown deadline={s.active.deadline} />
        </div>
        <Footer>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => abandon(s.active!.id)}
          >
            Give up
          </Button>
          <Link
            to={`/problems/${s.active.problemId}`}
            className="flex h-8 items-center gap-1.5 rounded-md bg-primary px-3 text-xs font-medium text-primary-foreground hover:bg-primary/90"
          >
            Back to the problem
            <LuArrowRight className="size-3.5" />
          </Link>
        </Footer>
      </Card>
    );
  else
    body = (
      <Card>
        <div className="relative flex flex-col items-center gap-3 overflow-hidden px-8 pt-10 pb-8 text-center">
          <div className="pointer-events-none absolute inset-x-0 top-0 h-56 bg-[radial-gradient(ellipse_50%_70%_at_50%_0%,color-mix(in_srgb,var(--warning)_16%,transparent),transparent)]" />
          <div className="relative">
            <TrophyArt
              art="swords"
              metal={s.beaten ? "jade" : "gold"}
              size={96}
            />
          </div>
          <span className="relative text-xs font-medium tracking-wider text-warning uppercase">
            Module {m.number} · Boss fight{s.beaten && " · beaten"}
          </span>
          <h1 className="relative text-3xl font-semibold tracking-tight">
            {m.title}
          </h1>
          <p className="relative max-w-md text-sm leading-6 text-muted-foreground">
            A mock interview to close the module. One problem, a clock, and an
            interviewer waiting at the end.
          </p>
        </div>

        <div className="grid grid-cols-2 divide-border border-t border-border sm:grid-cols-4 sm:divide-x">
          <Fact value="1" label="problem" hint="unseen ones first" />
          <Fact
            value={`${m.limitMin}:00`}
            label="on the clock"
            hint="no pausing"
          />
          <Fact value="0" label="hints" hint="no solutions either" />
          <Fact value="3/5" label="to pass" hint="solve it, then explain it" />
        </div>

        {(m.topicsLeft > 0 || err) && (
          <div className="border-t border-border px-6 py-3 text-xs">
            {err ? (
              <span className="text-destructive">{err}</span>
            ) : (
              <span className="text-warning">
                {m.topicsLeft} {m.topicsLeft === 1 ? "topic" : "topics"} left in
                this module. You can still try, but it's meant for the end.
              </span>
            )}
          </div>
        )}

        <Footer>
          <span className="mr-auto text-xs text-muted-foreground">
            {s.beaten ? (
              "Beaten before. Replays are for practice."
            ) : (
              <>
                <span className="font-medium text-warning">+100 XP</span> on
                your first win
              </>
            )}
          </span>
          <Button onClick={start} disabled={!s.available}>
            <LuSwords className="size-4" />
            {s.available ? "Start the fight" : "No problems yet"}
          </Button>
        </Footer>
      </Card>
    );

  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="flex h-12 shrink-0 items-center gap-2 border-b border-border px-2">
        <Link
          to={`/course#${m.id}`}
          aria-label="Back"
          className="grid size-8 place-items-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
        >
          <LuChevronLeft className="size-4" />
        </Link>
        <nav className="flex min-w-0 items-center gap-2 text-sm">
          <Link
            to={`/course#${m.id}`}
            className="truncate text-muted-foreground hover:text-foreground"
          >
            {m.title}
          </Link>
          <span className="text-muted-foreground/40">/</span>
          <span className="font-medium">Boss fight</span>
        </nav>
      </header>

      <main className="mx-auto flex w-full max-w-2xl flex-col gap-6 px-6 py-10">
        {(result || s.active) && (
          <div className="flex items-center gap-4">
            <span
              className={`grid size-12 shrink-0 place-items-center rounded-xl ring-1 ring-inset ${
                s.beaten
                  ? "bg-success/10 text-success ring-success/20"
                  : "bg-warning/10 text-warning ring-warning/20"
              }`}
            >
              <LuSwords className="size-5" />
            </span>
            <div>
              <div className="text-xs font-medium text-muted-foreground">
                Module {m.number} boss {s.beaten && "· beaten"}
              </div>
              <h1 className="text-xl font-semibold tracking-tight">
                {m.title}
              </h1>
            </div>
          </div>
        )}

        {body}

        {s.runs.some((r) => r.finished) && (
          <section className="flex flex-col gap-3">
            <h2 className="text-xs font-medium text-muted-foreground">
              Past attempts
            </h2>
            <ul className="divide-y divide-border overflow-hidden rounded-xl border border-border bg-card">
              {s.runs
                .filter((r) => r.finished)
                .map((r) => (
                  <li
                    key={r.id}
                    className="flex items-center gap-3 px-4 py-3 text-sm"
                  >
                    {r.passed ? (
                      <LuCircleCheck className="size-4 shrink-0 text-success" />
                    ) : (
                      <LuCircleX className="size-4 shrink-0 text-destructive" />
                    )}
                    <span className="min-w-0 flex-1 truncate">
                      {r.problemTitle}
                    </span>
                    <span className="text-xs text-muted-foreground tabular-nums">
                      {r.solvedIn != null ? fmtClock(r.solvedIn) : "unsolved"}
                      {r.score != null && ` · ${r.score}/5`}
                    </span>
                    <span className="w-16 text-right text-xs text-muted-foreground">
                      {shortDate(r.startedAt)}
                    </span>
                  </li>
                ))}
            </ul>
          </section>
        )}
      </main>
    </div>
  );
}

function ExplainStep({
  run,
  onDone,
}: {
  run: Run;
  onDone: (r: Result) => void;
}) {
  const [text, setText] = useState("");
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");
  const submit = async () => {
    setBusy(true);
    setErr("");
    try {
      onDone(await post<Result>(`/boss/runs/${run.id}/finish`, { text }));
    } catch (e: any) {
      setErr(e.message);
    }
    setBusy(false);
  };

  return (
    <Card>
      <div className="px-6 pt-5 pb-4">
        <div className="flex items-center justify-between gap-4 text-xs text-muted-foreground">
          <span className="flex items-center gap-1.5">
            <LuMessageSquareQuote className="size-3.5 text-primary" />
            Interviewer
          </span>
          <span className="tabular-nums">
            Solved {run.problemTitle} in {fmtClock(run.solvedIn ?? 0)}
          </span>
        </div>
        <p className="mt-1 text-[15px] leading-7 font-medium">
          Nice. Now walk me through it: your approach, why it's correct, and the
          time and space complexity.
        </p>
      </div>
      <textarea
        value={text}
        onChange={(e) => setText(e.target.value)}
        autoFocus
        placeholder="Talk it through like you would in the room."
        className="block min-h-44 w-full resize-y border-y border-border bg-background/40 px-6 py-4 text-sm leading-6 outline-none placeholder:text-muted-foreground/60"
      />
      <Footer>
        <span
          className={`mr-auto text-xs ${err ? "text-destructive" : "text-muted-foreground"}`}
        >
          {err ||
            (busy ? "The interviewer is thinking…" : "Graded honestly, 0–5.")}
        </span>
        <MicButton onText={(t) => setText((s) => appendSpeech(s, t))} />
        <Button disabled={busy || text.trim().length < 40} onClick={submit}>
          {busy && <LuLoaderCircle className="size-4 animate-spin" />}
          Submit to interviewer
        </Button>
      </Footer>
    </Card>
  );
}

function ResultCard({ r, onAgain }: { r: Result; onAgain: () => void }) {
  const passed = !!r.run.passed;
  return (
    <Card>
      <div className="flex flex-col items-center gap-2 px-6 pt-8 pb-6 text-center">
        <span
          className={`grid size-14 place-items-center rounded-full ring-1 ring-inset ${
            passed
              ? "bg-success/10 text-success ring-success/25"
              : "bg-destructive/10 text-destructive ring-destructive/25"
          }`}
        >
          {passed ? (
            <LuCircleCheck className="size-6" />
          ) : (
            <LuCircleX className="size-6" />
          )}
        </span>
        <h2 className="mt-1 text-lg font-semibold tracking-tight">
          {passed ? "Boss defeated" : "Not this time"}
        </h2>
        <p className="text-sm text-muted-foreground tabular-nums">
          Solved in {fmtClock(r.run.solvedIn ?? 0)}
          {!r.inTime && " (over time)"} · explanation {r.grade.score}/5
          {r.xp > 0 && ` · +${r.xp} XP`}
        </p>
      </div>
      <div className="flex flex-col gap-3 border-t border-border px-6 py-5">
        <p className="text-sm leading-6 text-foreground/85">
          {r.grade.feedback}
        </p>
        {r.grade.followUp && (
          <p className="text-sm leading-6">
            <span className="text-muted-foreground">Follow-up: </span>
            {r.grade.followUp}
          </p>
        )}
      </div>
      <Footer>
        <Button variant="ghost" size="sm" onClick={onAgain}>
          {passed ? "Done" : "Try again"}
        </Button>
        <Link
          to={`/problems/${r.run.problemId}`}
          className="flex h-8 items-center rounded-md border border-border bg-secondary px-3 text-xs font-medium hover:bg-accent"
        >
          Review the solution
        </Link>
      </Footer>
    </Card>
  );
}

function Fact({
  value,
  label,
  hint,
}: {
  value: string;
  label: string;
  hint: string;
}) {
  return (
    <div className="flex flex-col items-center gap-0.5 px-4 py-5 text-center">
      <span className="text-xl font-semibold tracking-tight tabular-nums">
        {value}
      </span>
      <span className="text-xs font-medium">{label}</span>
      <span className="text-[11px] text-muted-foreground">{hint}</span>
    </div>
  );
}

function Card({ children }: { children: ReactNode }) {
  return (
    <div className="overflow-hidden rounded-xl border border-border bg-card">
      {children}
    </div>
  );
}

function Footer({ children }: { children: ReactNode }) {
  return (
    <div className="flex items-center justify-end gap-2 border-t border-border bg-background/30 px-6 py-3.5">
      {children}
    </div>
  );
}

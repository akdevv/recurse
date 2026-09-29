import { useEffect, useRef, useState, useSyncExternalStore } from "react";
import { Link, useParams } from "react-router";
import CodeMirror, { EditorView } from "@uiw/react-codemirror";
import { python } from "@codemirror/lang-python";
import { Prec } from "@codemirror/state";
import { oneDark } from "@codemirror/theme-one-dark";
import {
  LuChevronLeft,
  LuCircleCheck,
  LuCode,
  LuRotateCcw,
  LuSwords,
  LuTimer,
} from "react-icons/lu";
import { post, xpToast, fmtClock, emitChest } from "@/lib/api.ts";
import {
  flushActivity,
  pendingSeconds,
  setActivityContext,
  subscribeActivity,
} from "@/lib/activity.ts";
import { OUTCOME_LABEL, type RunOutput } from "@/lib/problem.ts";
import Button from "@/components/common/button.tsx";
import { Pane, PaneHeader, Tab } from "@/components/problem/pane.tsx";
import DescriptionPanel from "@/components/problem/description-panel.tsx";
import ConsolePanel from "@/components/problem/console-panel.tsx";
import ExplainBack from "@/components/problem/explain-back.tsx";
import BossCountdown from "@/components/problem/boss-countdown.tsx";
import type {
  EarnedChest,
  JudgeResult,
  Outcome,
  ProblemView,
} from "@shared/types.ts";

const editorTheme = EditorView.theme(
  {
    "&": { backgroundColor: "transparent", height: "100%", fontSize: "13px" },
    ".cm-scroller": {
      fontFamily: '"JetBrains Mono Variable", ui-monospace, monospace',
      lineHeight: "1.65",
      paddingTop: "8px",
    },
    ".cm-gutters": {
      backgroundColor: "transparent",
      border: "none",
      color: "var(--muted-foreground)",
      opacity: "0.6",
    },
    ".cm-activeLine": { backgroundColor: "rgb(255 255 255 / 0.025)" },
    ".cm-activeLineGutter": { backgroundColor: "transparent" },
    "&.cm-focused": { outline: "none" },
  },
  { dark: true },
);
const extensions = [python(), Prec.highest(editorTheme)];

export default function ProblemRoute() {
  const { id } = useParams();
  return <ProblemPage key={id} id={id!} />;
}

function ProblemPage({ id }: { id: string }) {
  const [v, setV] = useState<ProblemView | null>(null);
  const [code, setCode] = useState("");
  const [custom, setCustom] = useState("");
  const [busy, setBusy] = useState<"" | "run" | "submit">("");
  const [out, setOut] = useState<RunOutput | null>(null);
  const [err, setErr] = useState("");
  const saveTimer = useRef<ReturnType<typeof setTimeout>>(undefined);

  const apply = (nv: ProblemView) => {
    setV(nv);
    setCode(nv.attempt?.code ?? nv.problem.starter);
    setOut(null);
  };

  useEffect(() => {
    post<ProblemView>(`/problems/${id}/start`).then(apply);
    setActivityContext(id);
    return () => setActivityContext(undefined);
  }, [id]);

  const pending = useSyncExternalStore(subscribeActivity, pendingSeconds);
  if (!v) return null;
  const a = v.attempt;
  const open = !!a && !a.finished;
  const active = (a?.activeSeconds ?? 0) + (open ? pending : 0);
  const params = v.problem.entry.params.map((p) => p.name);
  const back = v.boss
    ? `/boss/${v.boss.moduleId}`
    : v.home
      ? `/course/${v.home.moduleId}/${v.home.topicId}`
      : "/problems";

  const save = (body: object) => post(`/problems/${id}/save`, body);
  const onCode = (c: string) => {
    setCode(c);
    clearTimeout(saveTimer.current);
    saveTimer.current = setTimeout(() => save({ code: c }), 800);
  };
  const refresh = () => post<ProblemView>(`/problems/${id}/start`).then(setV); // keeps editor state

  const run = async (kind: "run" | "submit") => {
    if (busy) return;
    setBusy(kind);
    setErr("");
    try {
      const r = await post<{
        result: JudgeResult;
        outcome?: Outcome | null;
        xp?: number;
        chest?: EarnedChest | null;
      }>(
        `/problems/${id}/${kind}`,
        kind === "run"
          ? { code, custom: custom.trim() ? [custom.trim()] : [] }
          : { code },
      );
      setOut({ id: Date.now(), kind, res: r.result, outcome: r.outcome });
      if (r.outcome) {
        xpToast(r.xp);
        await refresh();
        emitChest(r.chest);
      }
    } catch (e: any) {
      setErr(e.message);
    }
    setBusy("");
  };
  const act = async (path: "hint" | "solution") => {
    await flushActivity(); // server decides unlocks from recorded time
    post<ProblemView>(`/problems/${id}/${path}`)
      .then(setV)
      .catch((e) => setErr(e.message));
  };

  const onKeys = (e: React.KeyboardEvent) => {
    if (!(e.metaKey || e.ctrlKey) || e.key !== "Enter") return;
    e.preventDefault();
    e.stopPropagation();
    run(e.shiftKey ? "submit" : "run");
  };

  return (
    <div className="flex h-screen flex-col bg-background">
      <header className="flex h-12 shrink-0 items-center gap-2 border-b border-border px-2">
        <Link
          to={back}
          title="Back"
          aria-label="Back"
          className="grid size-8 shrink-0 place-items-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
        >
          <LuChevronLeft className="size-4" />
        </Link>
        <nav className="flex min-w-0 items-center gap-2 text-sm">
          <Link
            to={back}
            className="truncate text-muted-foreground transition-colors hover:text-foreground"
          >
            {v.boss ? "Boss fight" : (v.home?.topicTitle ?? "Problems")}
          </Link>
          <span className="text-muted-foreground/40">/</span>
          <span className="truncate font-medium">{v.problem.title}</span>
        </nav>

        <div className="ml-auto flex shrink-0 items-center gap-2">
          {v.boss ? (
            a?.finished ? (
              <Link
                to={`/boss/${v.boss.moduleId}`}
                className="flex h-8 items-center gap-1.5 rounded-md bg-primary px-3 text-xs font-medium text-primary-foreground transition-colors hover:bg-primary/90"
              >
                <LuSwords className="size-3.5" />
                Finish the boss fight
              </Link>
            ) : (
              <BossCountdown deadline={v.boss.deadline} />
            )
          ) : a?.finished ? (
            <>
              <span className="flex h-7 items-center gap-1.5 rounded-full bg-success/10 px-2.5 text-xs font-medium text-success ring-1 ring-success/20 ring-inset">
                <LuCircleCheck className="size-3.5" />
                {a.outcome ? OUTCOME_LABEL[a.outcome] : "Solved"}
              </span>
              <Button
                size="sm"
                variant="ghost"
                onClick={() =>
                  post<ProblemView>(`/problems/${id}/start`, {
                    fresh: true,
                  }).then(apply)
                }
              >
                <LuRotateCcw className="size-3.5" />
                Solve again
              </Button>
            </>
          ) : (
            <span
              title="Active time on this attempt"
              className="flex h-7 items-center gap-1.5 rounded-full bg-secondary px-2.5 font-mono text-xs text-muted-foreground tabular-nums ring-1 ring-border ring-inset"
            >
              <LuTimer className="size-3.5" />
              {fmtClock(active)}
            </span>
          )}
        </div>
      </header>

      <main className="grid min-h-0 flex-1 grid-cols-2 gap-2 p-2">
        <DescriptionPanel
          v={v}
          open={open && !v.boss}
          active={active}
          onAct={act}
          getCode={() => code}
        />

        <div className="flex min-h-0 flex-col gap-2" onKeyDownCapture={onKeys}>
          <Pane className="flex-3">
            <PaneHeader>
              <Tab icon={LuCode}>Code</Tab>
              <span className="text-xs text-muted-foreground">Python</span>
            </PaneHeader>
            <CodeMirror
              value={code}
              height="100%"
              theme={oneDark}
              extensions={extensions}
              onChange={onCode}
              basicSetup={{ tabSize: 4 }}
              className="min-h-0 flex-1"
            />
          </Pane>

          <ConsolePanel
            params={params}
            custom={custom}
            onCustom={setCustom}
            busy={busy}
            onRun={run}
            out={out}
            err={err}
            footer={
              a?.finished &&
              !v.boss && (
                <ExplainBack
                  id={id}
                  initial={a.explain}
                  keyPoints={v.explainKeyPoints ?? []}
                />
              )
            }
          />
        </div>
      </main>
    </div>
  );
}

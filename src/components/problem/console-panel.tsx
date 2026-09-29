import { useState, type ReactNode } from "react";
import {
  LuCircleCheck,
  LuCloudUpload,
  LuKeyboard,
  LuLoaderCircle,
  LuPlay,
  LuSquareTerminal,
  LuTextCursorInput,
} from "react-icons/lu";
import Button from "@/components/common/button.tsx";
import { Pane, PaneHeader, Tab } from "@/components/problem/pane.tsx";
import { OUTCOME_LABEL, type RunOutput } from "@/lib/problem.ts";

const PASS = new Set(["Accepted", "Ran"]);

export default function ConsolePanel({
  params,
  custom,
  onCustom,
  busy,
  onRun,
  out,
  err,
  footer,
}: {
  params: string[];
  custom: string;
  onCustom: (s: string) => void;
  busy: "" | "run" | "submit";
  onRun: (kind: "run" | "submit") => void;
  out: RunOutput | null;
  err: string;
  footer?: ReactNode;
}) {
  const [tab, setTab] = useState<"result" | "input">("result");
  const run = (kind: "run" | "submit") => {
    setTab("result");
    onRun(kind);
  };

  return (
    <Pane className="flex-2">
      <PaneHeader>
        <Tab
          icon={LuSquareTerminal}
          active={tab === "result"}
          onClick={() => setTab("result")}
        >
          Result
        </Tab>
        <Tab
          icon={LuTextCursorInput}
          active={tab === "input"}
          onClick={() => setTab("input")}
        >
          Custom input
          {custom.trim() && (
            <span className="size-1.5 rounded-full bg-primary" />
          )}
        </Tab>
        <div className="ml-auto flex items-center gap-1.5 pr-0.5">
          <Button
            size="sm"
            variant="secondary"
            disabled={!!busy}
            onClick={() => run("run")}
            title="Run (⌘ Enter)"
          >
            {busy === "run" ? (
              <LuLoaderCircle className="size-3.5 animate-spin" />
            ) : (
              <LuPlay className="size-3.5" />
            )}
            Run
          </Button>
          <Button
            size="sm"
            disabled={!!busy}
            onClick={() => run("submit")}
            title="Submit (⌘ Shift Enter)"
          >
            {busy === "submit" ? (
              <LuLoaderCircle className="size-3.5 animate-spin" />
            ) : (
              <LuCloudUpload className="size-3.5" />
            )}
            Submit
          </Button>
        </div>
      </PaneHeader>

      <div className="min-h-0 flex-1 overflow-y-auto">
        {tab === "input" ? (
          <div className="flex h-full flex-col gap-2 p-4">
            <textarea
              value={custom}
              onChange={(e) => onCustom(e.target.value)}
              spellCheck={false}
              placeholder={params.map((p) => `${p} as JSON`).join("\n")}
              className="min-h-24 flex-1 resize-none rounded-lg border border-border bg-background/40 px-3 py-2.5 font-mono text-[13px] leading-6 outline-none placeholder:text-muted-foreground/50 focus:border-ring/60"
            />
            <p className="text-xs text-muted-foreground">
              One JSON value per line, in order: {params.join(", ")}. Run uses
              it alongside the examples; leave it empty to skip.
            </p>
          </div>
        ) : err ? (
          <div className="p-4">
            <ErrorBox>{err}</ErrorBox>
          </div>
        ) : out ? (
          <Results key={out.id} out={out} params={params} />
        ) : (
          <div className="flex h-full flex-col items-center justify-center gap-2 px-6 py-8 text-center text-sm text-muted-foreground">
            <span className="grid size-9 place-items-center rounded-lg bg-secondary">
              <LuSquareTerminal className="size-4" />
            </span>
            Run your code against the examples, then submit.
            <span className="flex items-center gap-1.5 text-xs text-muted-foreground/70">
              <LuKeyboard className="size-3.5" />
              <Kbd>⌘ ↵</Kbd> run <Kbd>⌘ ⇧ ↵</Kbd> submit
            </span>
          </div>
        )}
        {tab === "result" && footer}
      </div>
    </Pane>
  );
}

function Results({ out, params }: { out: RunOutput; params: string[] }) {
  const { res } = out;
  const [sel, setSel] = useState(0);
  const ok = res.verdict === "Accepted";
  const r = res.results[Math.min(sel, res.results.length - 1)];

  return (
    <div className="flex flex-col gap-4 p-4">
      <div className="flex items-baseline gap-3">
        <span
          className={`text-lg font-semibold tracking-tight ${ok ? "text-success" : "text-destructive"}`}
        >
          {res.verdict}
        </span>
        <span className="text-xs text-muted-foreground tabular-nums">
          {res.passed} / {res.total} tests passed
          {out.kind === "submit" && res.slowestMs != null
            ? ` · slowest ${res.slowestMs} ms`
            : ""}
        </span>
      </div>

      {out.outcome && (
        <div className="flex items-center gap-2 rounded-lg bg-success/10 px-3 py-2.5 text-sm text-success ring-1 ring-success/20 ring-inset">
          <LuCircleCheck className="size-4 shrink-0" />
          {OUTCOME_LABEL[out.outcome]}. Now explain your solution below.
        </div>
      )}

      {res.error && <ErrorBox>{res.error}</ErrorBox>}

      {r && (
        <>
          {res.results.length > 1 && (
            <div className="flex flex-wrap gap-1.5">
              {res.results.map((c, i) => (
                <button
                  key={c.i}
                  onClick={() => setSel(i)}
                  className={`flex h-7 items-center gap-1.5 rounded-md px-2.5 text-xs font-medium transition-colors ${
                    r === c
                      ? "bg-accent text-foreground"
                      : "text-muted-foreground hover:bg-accent/50 hover:text-foreground"
                  }`}
                >
                  <span
                    className={`size-1.5 rounded-full ${PASS.has(c.verdict) ? "bg-success" : "bg-destructive"}`}
                  />
                  {c.kind === "custom" ? "Custom" : `Case ${i + 1}`}
                </button>
              ))}
            </div>
          )}

          <div className="flex flex-col gap-3">
            {!PASS.has(r.verdict) && (
              <span className="text-xs font-medium text-destructive">
                {r.verdict} · {r.kind} test · {r.ms} ms
              </span>
            )}
            <Field label="Input">
              {r.input.map((x, i) => (
                <div key={i}>
                  {params[i] && r.input.length === params.length && (
                    <span className="text-muted-foreground">
                      {params[i]} ={" "}
                    </span>
                  )}
                  {x}
                </div>
              ))}
            </Field>
            {r.got !== null && (
              <Field label="Output">
                <span className={PASS.has(r.verdict) ? "" : "text-destructive"}>
                  {r.got}
                </span>
              </Field>
            )}
            {r.expected !== null && (
              <Field label="Expected">
                <span className="text-success">{r.expected}</span>
              </Field>
            )}
            {r.stdout && (
              <Field label="Stdout">
                <pre className="whitespace-pre-wrap">{r.stdout}</pre>
              </Field>
            )}
            {r.error && <ErrorBox>{r.error}</ErrorBox>}
          </div>
        </>
      )}
    </div>
  );
}

function Field({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="flex flex-col gap-1.5">
      <span className="text-xs font-medium text-muted-foreground">{label}</span>
      <div className="overflow-x-auto rounded-md bg-secondary/60 px-3 py-2 font-mono text-[13px] leading-6 break-all">
        {children}
      </div>
    </div>
  );
}

function ErrorBox({ children }: { children: ReactNode }) {
  return (
    <pre className="overflow-x-auto rounded-md bg-destructive/10 px-3 py-2.5 font-mono text-xs leading-5 whitespace-pre-wrap text-destructive ring-1 ring-destructive/20 ring-inset">
      {children}
    </pre>
  );
}

function Kbd({ children }: { children: ReactNode }) {
  return (
    <kbd className="rounded border border-border bg-secondary px-1 py-px font-mono text-[10px] text-muted-foreground">
      {children}
    </kbd>
  );
}

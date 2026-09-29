import { useEffect, useState } from "react";
import {
  LuChevronLeft,
  LuChevronRight,
  LuPause,
  LuPlay,
  LuRotateCcw,
} from "react-icons/lu";
import { holdActive } from "@/lib/activity.ts";
import type { VizTrace } from "@shared/types.ts";

type Step = Record<string, any>;

export default function Viz({ trace }: { trace: VizTrace }) {
  const [i, setI] = useState(0);
  const [playing, setPlaying] = useState(false);
  const n = trace.steps.length;
  const step = trace.steps[i];
  const atEnd = i === n - 1;

  useEffect(() => {
    if (!playing) return;
    const release = holdActive(); // watching counts as active time
    const t = setInterval(() => {
      if (document.hidden) return;
      setI((x) => {
        if (x + 1 >= n) {
          setPlaying(false);
          return x;
        }
        return x + 1;
      });
    }, 1100);
    const pause = () => setPlaying(false);
    window.addEventListener("blur", pause);
    return () => {
      clearInterval(t);
      release();
      window.removeEventListener("blur", pause);
    };
  }, [playing, n]);

  const go = (to: number) => {
    setPlaying(false);
    setI(Math.max(0, Math.min(n - 1, to)));
  };

  const toggle = () => {
    if (atEnd) setI(0);
    setPlaying(!playing);
  };
  const onKey = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowRight") go(i + 1);
    else if (e.key === "ArrowLeft") go(i - 1);
    else if (e.key === " ") {
      e.preventDefault();
      toggle();
    }
  };

  return (
    <figure
      tabIndex={0}
      onKeyDown={onKey}
      className="not-prose my-8 overflow-hidden rounded-xl border border-border bg-card outline-none focus-visible:ring-[3px] focus-visible:ring-ring/30"
    >
      <div
        className="flex min-h-48 flex-col items-center justify-center gap-6 overflow-x-auto border-b border-border bg-background/50 px-6 pt-4 pb-8"
        style={{
          backgroundImage:
            "radial-gradient(color-mix(in srgb, var(--foreground) 9%, transparent) 1px, transparent 1px)",
          backgroundSize: "16px 16px",
        }}
      >
        <figcaption className="self-start text-xs text-muted-foreground">
          {trace.title}
        </figcaption>
        {trace.view === "array" &&
          (step.stack ? (
            <div className="flex items-end gap-10">
              <ArrayView s={step} />
              <StackView
                frames={step.stack}
                label={step.stackLabel ?? "stack"}
                small
              />
            </div>
          ) : (
            <ArrayView s={step} />
          ))}
        {trace.view === "stack" && (
          <StackView frames={step.stack} label={step.stackLabel} />
        )}
        {trace.view === "grid" && <GridView s={step} />}
        {trace.view === "list" && <ListView s={step} />}
        {trace.view === "graph" && <GraphView s={step} />}
        {trace.view === "tree" && (
          <div className="flex items-start gap-8">
            <TreeView s={step} />
            {step.stack && <StackView frames={step.stack} small />}
          </div>
        )}
        {step.vars && (
          <div className="flex flex-wrap justify-center gap-1.5 font-mono text-xs">
            {Object.entries(step.vars).map(([k, v]) => (
              <span
                key={k}
                className="rounded-md border border-border bg-card px-2 py-1"
              >
                <span className="text-muted-foreground">{k} = </span>
                {JSON.stringify(v)}
              </span>
            ))}
          </div>
        )}
      </div>

      <div className="flex items-center gap-4 px-4 py-3">
        <p className="min-w-0 flex-1 text-sm leading-6 text-foreground/85">
          {step.caption}
        </p>
        <div className="flex shrink-0 items-center gap-1.5">
          <div className="flex items-center rounded-lg border border-border">
            <IconButton
              label="Previous step (←)"
              onClick={() => go(i - 1)}
              disabled={i === 0}
            >
              <LuChevronLeft className="size-4" />
            </IconButton>
            <span className="min-w-10 text-center font-mono text-[11px] text-muted-foreground tabular-nums">
              {i + 1}/{n}
            </span>
            <IconButton
              label="Next step (→)"
              onClick={() => go(i + 1)}
              disabled={atEnd}
            >
              <LuChevronRight className="size-4" />
            </IconButton>
          </div>
          <button
            onClick={toggle}
            aria-label={playing ? "Pause" : atEnd ? "Replay" : "Play"}
            title={
              playing ? "Pause (space)" : atEnd ? "Replay" : "Play (space)"
            }
            className="grid size-8 place-items-center rounded-lg bg-primary text-primary-foreground transition-colors hover:bg-primary/90"
          >
            {playing ? (
              <LuPause className="size-4" />
            ) : atEnd ? (
              <LuRotateCcw className="size-4" />
            ) : (
              <LuPlay className="size-4" />
            )}
          </button>
        </div>
      </div>
    </figure>
  );
}

function IconButton({
  label,
  children,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { label: string }) {
  return (
    <button
      {...props}
      aria-label={label}
      title={label}
      className="grid size-8 place-items-center text-muted-foreground transition-colors hover:text-foreground disabled:pointer-events-none disabled:opacity-30"
    >
      {children}
    </button>
  );
}

function ArrayView({ s }: { s: Step }) {
  const arr: unknown[] = s.array ?? [];
  const hi = new Set<number>(s.highlight ?? []);
  const dim = new Set<number>(s.dim ?? []);
  const ptrs = Object.entries((s.pointers ?? {}) as Record<string, number>);
  if (!arr.length)
    return <div className="text-sm text-muted-foreground">(empty)</div>;
  return (
    <div className="flex gap-1.5">
      {arr.map((v, k) => (
        <div key={k} className="flex flex-col items-center gap-1.5">
          <div
            className={`grid h-11 min-w-11 place-items-center rounded-lg border px-2 font-mono text-sm transition-all duration-300 ${
              hi.has(k)
                ? "border-primary bg-primary/15 text-primary"
                : "border-border bg-secondary text-foreground"
            } ${dim.has(k) ? "line-through opacity-25" : ""}`}
          >
            {String(v)}
          </div>
          <div className="font-mono text-[10px] text-muted-foreground/60">
            {k}
          </div>
          <PointerTags ptrs={ptrs} at={k} />
        </div>
      ))}
    </div>
  );
}

/** Names of the pointers sitting at index `at`, stacked under a cell. */
function PointerTags({ ptrs, at }: { ptrs: [string, number][]; at: number }) {
  return (
    <div className="flex min-h-4 flex-col items-center font-mono text-[11px] leading-tight font-medium text-warning">
      {ptrs
        .filter(([, idx]) => idx === at)
        .map(([name]) => (
          <span key={name}>↑ {name}</span>
        ))}
    </div>
  );
}

function GridView({ s }: { s: Step }) {
  const grid: unknown[][] = s.grid ?? [];
  const key = (c: [number, number]) => `${c[0]},${c[1]}`;
  const hi = new Set<string>((s.highlight ?? []).map(key));
  const dim = new Set<string>((s.dim ?? []).map(key));
  const ptrs = Object.entries(
    (s.pointers ?? {}) as Record<string, [number, number]>,
  );
  return (
    <div className={`flex flex-col ${s.compact ? "gap-0.5" : "gap-1.5"}`}>
      {grid.map((row, r) => (
        <div
          key={r}
          className={`flex items-center ${s.compact ? "gap-0.5" : "gap-1.5"}`}
        >
          <span className="w-4 text-right font-mono text-[10px] text-muted-foreground/60">
            {r}
          </span>
          {row.map((v, c) => {
            const here = ptrs.filter(([, p]) => p[0] === r && p[1] === c);
            return (
              <div
                key={c}
                title={here.map(([n]) => n).join(", ") || undefined}
                className={`relative grid place-items-center border font-mono transition-all duration-300 ${s.compact ? "size-6 rounded text-[10px]" : "size-11 rounded-lg text-sm"} ${
                  v === "█" // a filled cell (timelines, bars)
                    ? hi.has(`${r},${c}`)
                      ? "border-primary bg-primary/70"
                      : "border-foreground/30 bg-foreground/30"
                    : hi.has(`${r},${c}`)
                      ? "border-primary bg-primary/15 text-primary"
                      : "border-border bg-secondary text-foreground"
                } ${dim.has(`${r},${c}`) ? "opacity-25" : ""} ${
                  here.length ? "ring-2 ring-warning/70" : ""
                }`}
              >
                {v === "█" ? "" : String(v)}
              </div>
            );
          })}
        </div>
      ))}
      {ptrs.length > 0 && (
        <div className="flex justify-center gap-3 pt-1 font-mono text-[11px] font-medium text-warning">
          {ptrs.map(([n, p]) => (
            <span key={n}>
              {n} = ({p[0]}, {p[1]})
            </span>
          ))}
        </div>
      )}
    </div>
  );
}

function StackView({
  frames = [],
  small,
  label = "call stack",
}: {
  frames?: string[];
  small?: boolean;
  label?: string;
}) {
  return (
    <div className={`flex flex-col-reverse gap-1.5 ${small ? "w-40" : "w-60"}`}>
      <div className="border-t border-border pt-1.5 text-center text-[10px] tracking-wider text-muted-foreground uppercase">
        {label}
      </div>
      {frames.map((f, k) => (
        <div
          key={k}
          className={`rounded-md border px-3 py-1.5 font-mono text-xs transition-colors ${
            k === frames.length - 1
              ? "border-warning/40 bg-warning/10 text-warning"
              : "border-border bg-secondary text-foreground/80"
          }`}
        >
          {f}
        </div>
      ))}
    </div>
  );
}

// recursion call trees (fib(3)=2) read best with the value inline; other trees get a tag below the node
const inline = (label: string) => /^\w+\(/.test(label);

function TreeView({ s }: { s: Step }) {
  const nodes: {
    id: string;
    label: string;
    parent: string | null;
    hidden?: boolean; // keeps its slot (e.g. a missing left child) but isn't drawn
  }[] = s.nodes ?? [];
  const values: Record<string, unknown> = s.values ?? {};
  const marked = new Set<string>(s.highlight ?? []);
  // layout: leaves get consecutive x slots in DFS order, parents sit centered over their children
  const kids: Record<string, string[]> = {};
  nodes.forEach((n) => {
    if (n.parent) (kids[n.parent] ??= []).push(n.id);
  });
  const pos: Record<string, { x: number; y: number }> = {};
  let slot = 0;
  const place = (id: string, depth: number): number => {
    const c = kids[id] ?? [];
    const x = c.length
      ? c.map((k) => place(k, depth + 1)).reduce((a, b) => a + b) / c.length
      : slot++;
    pos[id] = { x, y: depth };
    return x;
  };
  nodes.filter((n) => !n.parent).forEach((r) => place(r.id, 0));
  const text = (n: (typeof nodes)[number]) =>
    n.id in values && inline(n.label)
      ? `${n.label.replace(/^fib/, "f")}=${values[n.id]}`
      : n.label;
  const boxW = (n: (typeof nodes)[number]) =>
    Math.max(60, text(n).length * 7 + 14);
  const W = Math.max(68, ...nodes.map((n) => boxW(n) + 8)),
    H = 58,
    maxX = Math.max(0, ...Object.values(pos).map((p) => p.x)),
    maxY = Math.max(0, ...Object.values(pos).map((p) => p.y));
  const px = (id: string) => pos[id].x * W + W / 2,
    py = (id: string) => pos[id].y * H + 20;
  return (
    <svg
      width={(maxX + 1) * W}
      height={(maxY + 1) * H + 22}
      className="font-mono"
    >
      {nodes
        .filter((n) => n.parent && !n.hidden)
        .map((n) => (
          <line
            key={n.id}
            x1={px(n.parent!)}
            y1={py(n.parent!)}
            x2={px(n.id)}
            y2={py(n.id)}
            className="stroke-border"
          />
        ))}
      {nodes
        .filter((n) => !n.hidden)
        .map((n) => {
          const active = s.active === n.id,
            done = s.highlight ? marked.has(n.id) : n.id in values;
          return (
            <g key={n.id}>
              <rect
                x={px(n.id) - boxW(n) / 2}
                y={py(n.id) - 13}
                width={boxW(n)}
                height={26}
                rx={7}
                className={
                  active
                    ? "fill-warning/15 stroke-warning"
                    : done
                      ? "fill-primary/10 stroke-primary/60"
                      : "fill-secondary stroke-border"
                }
              />
              <text
                x={px(n.id)}
                y={py(n.id) + 4}
                textAnchor="middle"
                fontSize="11"
                className={
                  active
                    ? "fill-warning"
                    : done
                      ? "fill-primary"
                      : "fill-foreground/80"
                }
              >
                {text(n)}
              </text>
              {n.id in values && !inline(n.label) && (
                <text
                  x={px(n.id)}
                  y={py(n.id) + 25}
                  textAnchor="middle"
                  fontSize="10"
                  className="fill-warning"
                >
                  {String(values[n.id])}
                </text>
              )}
            </g>
          );
        })}
    </svg>
  );
}

/** Linked list: nodes in a row. `links[i]` = index node i points to (null = None); default i + 1.
 * Arrows between neighbours flip or vanish as links change; a link elsewhere (a cycle) is listed below. */
function ListView({ s }: { s: Step }) {
  const vals: unknown[] = s.nodes ?? [];
  const n = vals.length;
  const links: (number | null)[] =
    s.links ?? vals.map((_, i) => (i + 1 < n ? i + 1 : null));
  const hi = new Set<number>(s.highlight ?? []);
  const dim = new Set<number>(s.dim ?? []);
  const ptrs = Object.entries((s.pointers ?? {}) as Record<string, number>);
  const far = links
    .map((t, i) => [i, t] as const)
    .filter(([i, t]) => t !== null && t !== i + 1 && t !== i - 1);
  if (!n) return <div className="text-sm text-muted-foreground">(empty)</div>;
  return (
    <div className="flex flex-col items-center gap-2">
      <div className="flex items-start">
        {vals.map((v, i) => (
          <div key={i} className="flex items-start">
            <div className="flex flex-col items-center gap-1.5">
              <div
                className={`grid h-11 min-w-11 place-items-center rounded-full border px-2 font-mono text-sm transition-all duration-300 ${
                  hi.has(i)
                    ? "border-primary bg-primary/15 text-primary"
                    : "border-border bg-secondary text-foreground"
                } ${dim.has(i) ? "opacity-25" : ""}`}
              >
                {String(v)}
              </div>
              {links[i] === null && i < n - 1 && (
                <div className="font-mono text-[10px] text-muted-foreground/70">
                  ↓ None
                </div>
              )}
              <PointerTags ptrs={ptrs} at={i} />
            </div>
            {i + 1 < n && (
              <div className="grid h-11 w-9 place-items-center font-mono text-base text-muted-foreground">
                {links[i] === i + 1 && links[i + 1] === i
                  ? "⇄"
                  : links[i] === i + 1
                    ? "→"
                    : links[i + 1] === i
                      ? "←"
                      : " "}
              </div>
            )}
          </div>
        ))}
        {links[n - 1] === null && (
          <div className="grid h-11 place-items-center pl-2 font-mono text-xs text-muted-foreground/60">
            → None
          </div>
        )}
      </div>
      {far.length > 0 && (
        <div className="flex gap-3 font-mono text-[11px] text-warning">
          {far.map(([i, t]) => (
            <span key={i}>
              {String(vals[i])} ↩ {String(vals[t!])} (index {t})
            </span>
          ))}
        </div>
      )}
    </div>
  );
}

/** Graph with fixed layout: nodes {id, label?, x, y} in grid units, edges {from, to, w?}.
 * `directed` draws arrowheads; `active`, `highlight` (node ids), `edgeHighlight` ([from, to]),
 * `dim` (node ids) and `values` (a tag at a node's top-right, e.g. a distance) style the step. */
function GraphView({ s }: { s: Step }) {
  const nodes: { id: string; label?: string; x: number; y: number }[] =
    s.nodes ?? [];
  const edges: { from: string; to: string; w?: number | string }[] =
    s.edges ?? [];
  const hi = new Set<string>(s.highlight ?? []);
  const dim = new Set<string>(s.dim ?? []);
  const values: Record<string, unknown> = s.values ?? {};
  const ek = (a: string, b: string) => `${a}>${b}`;
  const ehi = new Set<string>(
    (s.edgeHighlight ?? []).flatMap(([a, b]: [string, string]) =>
      s.directed ? [ek(a, b)] : [ek(a, b), ek(b, a)],
    ),
  );
  const S = 70,
    R = 17;
  const at = Object.fromEntries(
    nodes.map((n) => [n.id, { x: n.x * S + 30, y: n.y * S + 26 }]),
  );
  const W = Math.max(...nodes.map((n) => n.x)) * S + 100,
    H = Math.max(...nodes.map((n) => n.y)) * S + 64;
  return (
    <svg width={W} height={H} className="font-mono">
      <defs>
        <marker
          id="arrow"
          viewBox="0 0 10 10"
          refX="9"
          refY="5"
          markerWidth="6"
          markerHeight="6"
          orient="auto-start-reverse"
        >
          <path d="M0,0 L10,5 L0,10 z" className="fill-muted-foreground" />
        </marker>
      </defs>
      {edges.map((e) => {
        const a = at[e.from],
          b = at[e.to];
        const dx = b.x - a.x,
          dy = b.y - a.y,
          len = Math.hypot(dx, dy) || 1;
        const x1 = a.x + (dx / len) * R,
          y1 = a.y + (dy / len) * R,
          x2 = b.x - (dx / len) * (R + (s.directed ? 3 : 0)),
          y2 = b.y - (dy / len) * (R + (s.directed ? 3 : 0));
        const on = ehi.has(ek(e.from, e.to));
        return (
          <g key={ek(e.from, e.to)}>
            <line
              x1={x1}
              y1={y1}
              x2={x2}
              y2={y2}
              strokeWidth={on ? 2.5 : 1.2}
              markerEnd={s.directed ? "url(#arrow)" : undefined}
              className={on ? "stroke-primary" : "stroke-border"}
            />
            {e.w !== undefined && (
              <text
                x={(a.x + b.x) / 2 + (dy / len) * 9}
                y={(a.y + b.y) / 2 - (dx / len) * 9 + 4}
                textAnchor="middle"
                fontSize="10"
                paintOrder="stroke"
                strokeWidth={4}
                className={`stroke-card ${on ? "fill-primary" : "fill-muted-foreground"}`}
              >
                {String(e.w)}
              </text>
            )}
          </g>
        );
      })}
      {nodes.map((n) => {
        const p = at[n.id],
          active = s.active === n.id,
          on = hi.has(n.id);
        return (
          <g key={n.id} opacity={dim.has(n.id) ? 0.3 : 1}>
            <circle
              cx={p.x}
              cy={p.y}
              r={R}
              className={
                active
                  ? "fill-warning/15 stroke-warning"
                  : on
                    ? "fill-primary/15 stroke-primary"
                    : "fill-secondary stroke-border"
              }
            />
            <text
              x={p.x}
              y={p.y + 4}
              textAnchor="middle"
              fontSize="12"
              className={
                active
                  ? "fill-warning"
                  : on
                    ? "fill-primary"
                    : "fill-foreground"
              }
            >
              {n.label ?? n.id}
            </text>
            {n.id in values && (
              <text
                x={p.x + R - 2}
                y={p.y - R + 1}
                textAnchor="start"
                fontSize="10"
                paintOrder="stroke"
                strokeWidth={4}
                className="fill-warning stroke-card"
              >
                {String(values[n.id])}
              </text>
            )}
          </g>
        );
      })}
    </svg>
  );
}

import { useState, type ReactNode } from "react";
import { Link } from "react-router";
import { LuChevronDown, LuX } from "react-icons/lu";
import { useApi } from "@/lib/api.ts";
import { problemProgress, type Progress } from "@/lib/progress.ts";
import { lcId } from "@/lib/text.ts";
import { DIFFICULTIES, DIFF_TONE } from "@/lib/difficulty.ts";
import StatusIcon from "@/components/common/status-icon.tsx";
import Segmented from "@/components/common/segmented.tsx";
import SearchInput from "@/components/common/search-input.tsx";
import type {
  Course,
  Difficulty,
  ModuleView,
  TopicProblem,
} from "@shared/types.ts";

type Row = TopicProblem & {
  progress: Progress;
  moduleId: string;
  moduleNumber: number;
  moduleTitle: string;
  topicId: string;
  topicTitle: string;
};

const COLS =
  "grid grid-cols-[1.25rem_minmax(0,1fr)_minmax(0,14rem)_4.5rem_3.5rem] items-center gap-4 px-5";
const STATUSES: { id: Progress | "all"; label: string }[] = [
  { id: "all", label: "All" },
  { id: "new", label: "To do" },
  { id: "started", label: "In progress" },
  { id: "done", label: "Solved" },
];

export default function Problems() {
  const [data] = useApi<{ course: Course; modules: ModuleView[] }>("/course");
  const [q, setQ] = useState("");
  const [diff, setDiff] = useState<Difficulty | "all">("all");
  const [status, setStatus] = useState<Progress | "all">("all");
  const [mod, setMod] = useState("all");
  if (!data) return null;

  // a problem can sit in several topics; list it once, under its first topic
  const seen = new Set<string>();
  const rows: Row[] = data.modules.flatMap((m) =>
    m.topicViews.flatMap((t) =>
      t.problems
        .filter((p) => !seen.has(p.id) && seen.add(p.id))
        .map((p) => ({
          ...p,
          progress: problemProgress(p.status),
          moduleId: m.id,
          moduleNumber: m.number,
          moduleTitle: m.title,
          topicId: t.id,
          topicTitle: t.title,
        })),
    ),
  );

  const needle = q.trim().toLowerCase().replace(/^#/, "");
  const shown = rows.filter(
    (r) =>
      (diff === "all" || r.difficulty === diff) &&
      (status === "all" || r.progress === status) &&
      (mod === "all" || r.moduleId === mod) &&
      (!needle ||
        r.title.toLowerCase().includes(needle) ||
        (!!r.lc &&
          (lcId(r.lc).startsWith(needle) || String(r.lc).startsWith(needle))) ||
        r.topicTitle.toLowerCase().includes(needle)),
  );
  const filtered =
    !!needle || diff !== "all" || status !== "all" || mod !== "all";
  const clear = () => {
    setQ("");
    setDiff("all");
    setStatus("all");
    setMod("all");
  };

  return (
    <div className="mx-auto flex w-full max-w-5xl flex-col gap-6 px-8 py-8">
      <Summary rows={rows} />

      <div className="flex flex-col gap-3">
        <div className="flex flex-wrap items-center gap-2">
          <SearchInput
            value={q}
            onChange={setQ}
            placeholder="Search by title, topic or LeetCode #"
            className="min-w-56 flex-1"
          />
          <label className="relative">
            <select
              value={mod}
              onChange={(e) => setMod(e.target.value)}
              className="h-9 max-w-60 appearance-none rounded-md border border-border bg-card pr-9 pl-3 text-sm outline-none focus:border-ring/60"
            >
              <option value="all">All modules</option>
              {data.modules.map((m) => (
                <option key={m.id} value={m.id}>
                  {m.number}. {m.title}
                </option>
              ))}
            </select>
            <LuChevronDown className="pointer-events-none absolute top-1/2 right-3 size-4 -translate-y-1/2 text-muted-foreground" />
          </label>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <Segmented
            value={diff}
            onChange={setDiff}
            options={[
              { id: "all", label: "Any difficulty" },
              ...DIFFICULTIES.map((d) => ({ id: d, label: d })),
            ]}
          />
          <Segmented value={status} onChange={setStatus} options={STATUSES} />
          {filtered && (
            <button
              onClick={clear}
              className="ml-auto flex h-7 items-center gap-1 rounded-md px-2 text-xs text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            >
              <LuX className="size-3.5" />
              Clear
            </button>
          )}
        </div>
      </div>

      <div className="overflow-hidden rounded-xl border border-border bg-card">
        <div
          className={`${COLS} border-b border-border py-2.5 text-xs font-medium text-muted-foreground`}
        >
          <span />
          <span>Title</span>
          <span>Topic</span>
          <span>Difficulty</span>
          <span className="text-right">LC</span>
        </div>

        {shown.length ? (
          <ul className="divide-y divide-border">
            {shown.map((r) => (
              <ProblemRow key={r.id} r={r} />
            ))}
          </ul>
        ) : (
          <div className="flex flex-col items-center gap-2 px-6 py-14 text-center text-sm text-muted-foreground">
            No problems match these filters.
            <button
              onClick={clear}
              className="text-xs font-medium text-primary hover:underline"
            >
              Clear filters
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

function ProblemRow({ r }: { r: Row }) {
  const cells = (
    <>
      <StatusIcon status={r.progress} className="size-4" />
      <span className="flex min-w-0 items-center gap-2">
        <span
          className={`truncate text-sm ${r.available ? "font-medium" : "text-muted-foreground"}`}
        >
          {r.title}
        </span>
        {r.role === "optional" && (
          <span className="shrink-0 rounded-full bg-secondary px-1.5 py-px text-[10px] font-medium text-muted-foreground">
            Optional
          </span>
        )}
      </span>
      <span
        className="flex min-w-0 items-center gap-2"
        title={`Module ${r.moduleNumber} · ${r.moduleTitle}`}
      >
        <span className="truncate text-xs text-muted-foreground">
          {r.topicTitle}
        </span>
      </span>
      <span
        className={`text-xs font-medium ${r.difficulty ? DIFF_TONE[r.difficulty].text : "text-muted-foreground"}`}
      >
        {r.difficulty ?? "—"}
      </span>
      <span className="text-right font-mono text-xs text-muted-foreground tabular-nums">
        {r.lc ? `#${lcId(r.lc)}` : "—"}
      </span>
    </>
  );
  const cls = `${COLS} h-11`;

  return (
    <li>
      {r.available ? (
        <Link
          to={`/problems/${r.id}`}
          className={`${cls} transition-colors hover:bg-accent/40`}
        >
          {cells}
        </Link>
      ) : (
        <div className={cls} title="Not added yet">
          {cells}
        </div>
      )}
    </li>
  );
}

function Summary({ rows }: { rows: Row[] }) {
  const solved = rows.filter((r) => r.progress === "done").length;
  return (
    <div className="grid grid-cols-2 divide-border overflow-hidden rounded-xl border border-border bg-card sm:grid-cols-4 sm:divide-x">
      <Stat
        label="Solved"
        value={solved}
        total={rows.length}
        bar="bg-primary"
      />
      {DIFFICULTIES.map((d) => {
        const all = rows.filter((r) => r.difficulty === d);
        return (
          <Stat
            key={d}
            label={<span className={DIFF_TONE[d].text}>{d}</span>}
            value={all.filter((r) => r.progress === "done").length}
            total={all.length}
            bar={DIFF_TONE[d].bar}
          />
        );
      })}
    </div>
  );
}

function Stat({
  label,
  value,
  total,
  bar,
}: {
  label: ReactNode;
  value: number;
  total: number;
  bar: string;
}) {
  return (
    <div className="flex flex-col gap-2 px-5 py-4">
      <span className="text-xs font-medium text-muted-foreground">{label}</span>
      <span className="tabular-nums">
        <span className="text-2xl font-semibold tracking-tight">{value}</span>
        <span className="text-sm text-muted-foreground"> / {total}</span>
      </span>
      <div className="h-1 overflow-hidden rounded-full bg-secondary">
        <div
          className={`h-full rounded-full ${bar}`}
          style={{ width: `${total ? (value / total) * 100 : 0}%` }}
        />
      </div>
    </div>
  );
}

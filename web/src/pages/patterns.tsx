import { Fragment, useState } from "react";
import { Link } from "react-router";
import {
  LuArrowRight,
  LuCircleCheck,
  LuShapes,
  LuSparkles,
} from "react-icons/lu";
import { useApi } from "@/lib/api.ts";
import { pad2 } from "@/lib/text.ts";
import StatusIcon from "@/components/common/status-icon.tsx";
import StatCell from "@/components/common/stat-cell.tsx";
import Segmented from "@/components/common/segmented.tsx";
import SearchInput from "@/components/common/search-input.tsx";
import ProgressBar from "@/components/course/progress-bar.tsx";

type Pattern = {
  id: string;
  name: string;
  signals: string;
  complexity: string;
  topics: {
    id: string;
    title: string;
    moduleId: string;
    moduleNumber: number;
    moduleTitle: string;
    ready: boolean;
    complete: boolean;
  }[];
  problems: {
    id: string;
    title: string;
    available: boolean;
    solved: boolean;
  }[];
};

type Filter = "all" | "practiced" | "new";

const COLS =
  "grid grid-cols-[minmax(0,1fr)_15rem_6rem_3.5rem] items-center gap-6";

const solvedOf = (p: Pattern) => p.problems.filter((x) => x.solved).length;
const stateOf = (p: Pattern) => {
  const s = solvedOf(p);
  return s && s === p.problems.length ? "done" : s ? "started" : "new";
};

export default function Patterns() {
  const [data] = useApi<Pattern[]>("/patterns");
  const [q, setQ] = useState("");
  const [filter, setFilter] = useState<Filter>("all");
  if (!data) return null;

  const practiced = data.filter((p) => solvedOf(p) > 0).length;
  const mastered = data.filter((p) => stateOf(p) === "done").length;
  const upNext = data.find(
    (p) => p.topics.some((t) => t.ready) && stateOf(p) !== "done",
  );
  const upTopic = upNext?.topics.find((t) => t.ready);
  const needle = q.trim().toLowerCase();
  const shown = data.filter(
    (p) =>
      (filter === "all" ||
        (filter === "practiced" ? solvedOf(p) > 0 : solvedOf(p) === 0)) &&
      (!needle ||
        p.name.toLowerCase().includes(needle) ||
        p.signals.toLowerCase().includes(needle)),
  );

  // grouped by the module that first teaches each pattern
  const groups = new Map<
    string,
    { num: string; title: string; items: Pattern[] }
  >();
  for (const p of shown) {
    const t = p.topics[0];
    const key = t ? String(t.moduleNumber) : "later";
    if (!groups.has(key))
      groups.set(key, {
        num: t ? pad2(t.moduleNumber) : "··",
        title: t ? t.moduleTitle : "Later in the course",
        items: [],
      });
    groups.get(key)!.items.push(p);
  }
  const ordered = [...groups.entries()].sort(([a], [b]) =>
    a === "later" ? 1 : b === "later" ? -1 : Number(a) - Number(b),
  );

  return (
    <div className="mx-auto flex w-full max-w-5xl flex-col gap-6 px-8 py-8">
      <div className="grid grid-cols-1 divide-y divide-border overflow-hidden rounded-xl border border-border bg-card sm:grid-cols-3 sm:divide-x sm:divide-y-0">
        <StatCell icon={LuShapes} label="Practiced" tone="primary">
          <span className="text-2xl font-semibold tracking-tight tabular-nums">
            {practiced}
            <span className="text-sm font-normal text-muted-foreground">
              {" "}
              / {data.length}
            </span>
          </span>
          <ProgressBar pct={practiced / data.length} />
        </StatCell>
        <StatCell icon={LuCircleCheck} label="Mastered" tone="success">
          <span className="text-2xl font-semibold tracking-tight tabular-nums">
            {mastered}
            <span className="text-sm font-normal text-muted-foreground">
              {" "}
              every problem solved
            </span>
          </span>
        </StatCell>
        {upNext && upTopic ? (
          <Link
            to={`/course/${upTopic.moduleId}/${upTopic.id}`}
            className="group transition-colors hover:bg-accent/30"
          >
            <StatCell icon={LuSparkles} label="Up next" tone="warning">
              <span className="flex items-center gap-2 text-lg font-semibold tracking-tight">
                <span className="truncate">{upNext.name}</span>
                <LuArrowRight className="size-4 shrink-0 text-muted-foreground transition-transform group-hover:translate-x-0.5" />
              </span>
              <span className="truncate text-xs text-muted-foreground">
                {solvedOf(upNext)}/{upNext.problems.length} problems solved
              </span>
            </StatCell>
          </Link>
        ) : (
          <StatCell icon={LuSparkles} label="Up next" tone="warning">
            <span className="text-sm text-muted-foreground">
              Everything taught so far is mastered.
            </span>
          </StatCell>
        )}
      </div>

      <div className="flex flex-wrap items-center gap-3">
        <SearchInput
          value={q}
          onChange={setQ}
          placeholder="Search by name or signal"
          className="w-72"
        />
        <div className="ml-auto">
          <Segmented
            value={filter}
            onChange={setFilter}
            options={[
              { id: "all", label: "All" },
              { id: "practiced", label: "Practiced" },
              { id: "new", label: "Not started" },
            ]}
          />
        </div>
      </div>

      <div className="overflow-hidden rounded-xl border border-border bg-card">
        <div
          className={`${COLS} border-b border-border px-5 py-2.5 text-xs text-muted-foreground`}
        >
          <span>Pattern</span>
          <span>Complexity</span>
          <span>Solved</span>
          <span />
        </div>

        {ordered.map(([key, g]) => {
          const done = g.items.filter((p) => solvedOf(p) > 0).length;
          return (
            <Fragment key={key}>
              <div className="flex items-center gap-3 border-b border-border bg-background/50 px-5 py-2.5">
                <span className="grid h-6 min-w-7 place-items-center rounded-md border border-border bg-card px-1.5 font-mono text-[11px] text-muted-foreground tabular-nums">
                  {g.num}
                </span>
                <span className="text-sm font-medium">{g.title}</span>
                <span className="ml-auto text-xs text-muted-foreground tabular-nums">
                  {done}/{g.items.length} practiced
                </span>
              </div>
              {g.items.map((p) => (
                <Row key={p.id} p={p} />
              ))}
            </Fragment>
          );
        })}

        {!shown.length && (
          <p className="py-12 text-center text-sm text-muted-foreground">
            No patterns match.
          </p>
        )}
      </div>
    </div>
  );
}

function Row({ p }: { p: Pattern }) {
  const solved = solvedOf(p);
  const total = p.problems.length;
  const topic = p.topics.find((t) => t.ready);

  const cells = (
    <>
      <div className="flex min-w-0 gap-3">
        <StatusIcon status={stateOf(p)} className="mt-0.5 size-4" />
        <div className="min-w-0">
          <div className="text-sm font-medium">{p.name}</div>
          <div className="mt-0.5 text-[13px] leading-5 text-muted-foreground">
            {p.signals}
          </div>
        </div>
      </div>
      <span className="justify-self-start rounded-md bg-secondary/70 px-2 py-1 font-mono text-[11px] text-foreground/75">
        {p.complexity}
      </span>
      <span className="flex flex-col gap-1.5">
        {total ? (
          <>
            <span className="text-xs tabular-nums">
              {solved}
              <span className="text-muted-foreground"> / {total}</span>
            </span>
            <ProgressBar pct={solved / total} />
          </>
        ) : (
          <span className="text-xs text-muted-foreground/50">—</span>
        )}
      </span>
      <span
        className={`flex items-center justify-end gap-1 text-xs font-medium text-primary opacity-0 transition-opacity group-hover:opacity-100 ${topic ? "" : "hidden"}`}
      >
        Learn
        <LuArrowRight className="size-3.5" />
      </span>
    </>
  );
  const cls = `${COLS} border-b border-border px-5 py-3.5 last:border-b-0`;

  return topic ? (
    <Link
      to={`/course/${topic.moduleId}/${topic.id}`}
      title={`Taught in ${topic.title}`}
      className={`group ${cls} transition-colors hover:bg-accent/30`}
    >
      {cells}
    </Link>
  ) : (
    <div className={`${cls} opacity-70`}>{cells}</div>
  );
}

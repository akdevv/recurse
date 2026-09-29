import { LuArrowRight, LuBookOpen, LuCode, LuPlay } from "react-icons/lu";
import { problemProgress } from "@/lib/progress.ts";
import StatCell from "@/components/common/stat-cell.tsx";
import ProgressBar from "@/components/course/progress-bar.tsx";
import type { ModuleView } from "@shared/types.ts";

export default function CourseSummary({
  modules,
  current,
  onJump,
}: {
  modules: ModuleView[];
  current: ModuleView | undefined;
  onJump: (id: string) => void;
}) {
  const topics = modules.flatMap((m) => m.topicViews);
  const topicsDone = topics.filter((t) => t.complete).length;
  const problems = new Map(
    topics.flatMap((t) => t.problems).map((p) => [p.id, p]),
  );
  const solved = [...problems.values()].filter(
    (p) => problemProgress(p.status) === "done",
  ).length;
  const nextTopic = current?.topicViews.find((t) => !t.complete);

  return (
    <div className="grid grid-cols-1 divide-y divide-border overflow-hidden rounded-xl border border-border bg-card sm:grid-cols-3 sm:divide-x sm:divide-y-0">
      <StatCell icon={LuBookOpen} label="Topics complete" tone="primary">
        <Value value={topicsDone} total={topics.length} />
        <ProgressBar pct={topics.length ? topicsDone / topics.length : 0} />
      </StatCell>

      <StatCell icon={LuCode} label="Problems solved" tone="success">
        <Value value={solved} total={problems.size} />
        <ProgressBar pct={problems.size ? solved / problems.size : 0} />
      </StatCell>

      {current && (
        <button
          onClick={() => onJump(current.id)}
          className="group text-left transition-colors hover:bg-accent/40"
        >
          <StatCell icon={LuPlay} label="Continue" tone="primary">
            <span className="flex items-center gap-2">
              <span className="truncate text-lg leading-8 font-semibold tracking-tight">
                {current.title}
              </span>
              <LuArrowRight className="size-4 shrink-0 text-muted-foreground transition-transform group-hover:translate-x-0.5 group-hover:text-foreground" />
            </span>
            <span className="truncate text-xs text-muted-foreground">
              {nextTopic ? `Next up: ${nextTopic.title}` : "All topics done"}
            </span>
          </StatCell>
        </button>
      )}
    </div>
  );
}

function Value({ value, total }: { value: number; total: number }) {
  return (
    <span className="leading-8 tabular-nums">
      <span className="text-2xl font-semibold tracking-tight">{value}</span>
      <span className="text-sm text-muted-foreground"> / {total}</span>
    </span>
  );
}

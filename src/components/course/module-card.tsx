import { Link } from "react-router";
import { LuChevronDown, LuSwords } from "react-icons/lu";
import { pad2 } from "@/lib/text.ts";
import TopicSection from "@/components/course/topic-section.tsx";
import type { ModuleView } from "@shared/types.ts";

export default function ModuleCard({
  m,
  isOpen,
  onToggle,
}: {
  m: ModuleView;
  isOpen: boolean;
  onToggle: () => void;
}) {
  const done = m.topicViews.filter((t) => t.complete).length;
  const total = m.topicViews.length;
  const started = m.topicViews.some(
    (t) => t.complete || t.lessonDone || t.solved > 0,
  );

  return (
    <section
      id={m.id}
      className="scroll-mt-6 overflow-hidden rounded-xl border border-border bg-card"
    >
      <button
        onClick={onToggle}
        aria-expanded={isOpen}
        className="flex w-full items-center gap-4 px-5 py-4 text-left transition-colors hover:bg-accent/40"
      >
        <span
          className={`grid size-10 shrink-0 place-items-center rounded-lg font-mono text-sm font-semibold ring-1 ring-inset ${
            m.complete
              ? "bg-success/10 text-success ring-success/20"
              : started
                ? "bg-primary/10 text-primary ring-primary/20"
                : "bg-secondary text-muted-foreground ring-border"
          }`}
        >
          {pad2(m.number)}
        </span>

        <div className="min-w-0 flex-1">
          <h2 className="truncate text-[15px] font-semibold tracking-tight">
            {m.title}
          </h2>
          <p className="mt-0.5 truncate text-sm text-muted-foreground">
            {m.summary}
          </p>
        </div>

        <div
          className="hidden shrink-0 items-center gap-2.5 sm:flex"
          title={`${done} of ${total} topics complete`}
        >
          <span className="text-xs text-muted-foreground tabular-nums">
            {done}/{total}
          </span>
          <div className="flex w-20 gap-0.5">
            {m.topicViews.map((t) => (
              <span
                key={t.id}
                className={`h-1 flex-1 rounded-full ${t.complete ? "bg-success" : "bg-foreground/10"}`}
              />
            ))}
          </div>
        </div>

        <LuChevronDown
          className={`size-4 shrink-0 text-muted-foreground transition-transform duration-200 ${isOpen ? "rotate-180" : ""}`}
        />
      </button>

      <div
        className={`grid transition-[grid-template-rows] duration-200 ease-out motion-reduce:transition-none ${
          isOpen ? "grid-rows-[1fr]" : "grid-rows-[0fr]"
        }`}
      >
        <div className="overflow-hidden">
          <div className="divide-y divide-border border-t border-border">
            {m.topicViews.map((t) => (
              <TopicSection key={t.id} t={t} moduleId={m.id} />
            ))}
            <BossFight m={m} topicsLeft={total - done} />
          </div>
        </div>
      </div>
    </section>
  );
}

function BossFight({ m, topicsLeft }: { m: ModuleView; topicsLeft: number }) {
  const ready = topicsLeft === 0;
  return (
    <div className="flex items-center gap-4 bg-background/40 px-5 py-4">
      <span
        className={`grid size-10 shrink-0 place-items-center rounded-lg ring-1 ring-inset ${
          ready
            ? "bg-warning/10 text-warning ring-warning/20"
            : "bg-secondary text-muted-foreground ring-border"
        }`}
      >
        <LuSwords className="size-4" />
      </span>
      <div className="min-w-0 flex-1">
        <div className="text-sm font-medium">Boss fight</div>
        <div className="text-xs text-muted-foreground">
          Mock interview · {m.boss.timeLimitMin} min · one problem, explained
          out loud
        </div>
      </div>
      {ready ? (
        <Link
          to={`/boss/${m.id}`}
          className="flex h-8 items-center rounded-md bg-primary px-3 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
        >
          Start
        </Link>
      ) : (
        <Link
          to={`/boss/${m.id}`}
          className="text-xs text-muted-foreground tabular-nums transition-colors hover:text-foreground"
        >
          {topicsLeft} {topicsLeft === 1 ? "topic" : "topics"} to go
        </Link>
      )}
    </div>
  );
}

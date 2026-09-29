import { PROGRESS_BAR } from "@/lib/progress.ts";
import type { Step } from "@/lib/topic-steps.ts";

export default function TopicSteps({ steps }: { steps: Step[] }) {
  return (
    <ol
      className="grid gap-3"
      style={{ gridTemplateColumns: `repeat(${steps.length}, minmax(0, 1fr))` }}
    >
      {steps.map((s) => (
        <li key={s.id}>
          <a href={`#${s.id}`} className="group flex flex-col gap-2.5">
            <span className={`h-1 rounded-full ${PROGRESS_BAR[s.status]}`} />
            <span className="flex flex-col gap-0.5">
              <span
                className={`text-sm font-medium transition-colors group-hover:text-foreground ${
                  s.status === "new" ? "text-muted-foreground" : ""
                }`}
              >
                {s.label}
              </span>
              <span className="truncate text-xs text-muted-foreground">
                {s.detail}
              </span>
            </span>
          </a>
        </li>
      ))}
    </ol>
  );
}

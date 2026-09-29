import { Link } from "react-router";
import {
  LuChevronRight,
  LuCircle,
  LuCircleCheck,
  LuCircleDashed,
} from "react-icons/lu";
import StatusIcon from "@/components/common/status-icon.tsx";
import { problemProgress } from "@/lib/progress.ts";
import { DIFF_TONE } from "@/lib/difficulty.ts";
import { topicSteps } from "@/lib/topic-steps.ts";
import type { TopicProblem, TopicView } from "@shared/types.ts";

export default function TopicSection({
  t,
  moduleId,
}: {
  t: TopicView;
  moduleId: string;
}) {
  const ready = t.status === "ready";
  const steps = topicSteps(t).map((s) => s.status === "done");
  const started = steps.some(Boolean);
  const Icon = t.complete ? LuCircleCheck : started ? LuCircleDashed : LuCircle;

  const header = (
    <>
      <Icon
        className={`size-4 shrink-0 ${
          t.complete
            ? "text-success"
            : started
              ? "text-primary"
              : "text-muted-foreground/50"
        }`}
      />
      <span className="min-w-0 flex-1 truncate text-sm font-medium">
        {t.title}
      </span>
      {ready && (
        <div
          className="flex w-14 shrink-0 gap-0.5"
          title="Lesson · quiz · problems · explain"
        >
          {steps.map((done, i) => (
            <span
              key={i}
              className={`h-1 flex-1 rounded-full ${
                done
                  ? t.complete
                    ? "bg-success"
                    : "bg-primary"
                  : "bg-foreground/10"
              }`}
            />
          ))}
        </div>
      )}
      <LuChevronRight
        className={`size-4 shrink-0 text-muted-foreground/50 transition-transform group-hover:translate-x-0.5 group-hover:text-muted-foreground ${ready ? "" : "invisible"}`}
      />
    </>
  );

  return (
    <div className="flex flex-col gap-1 px-3 py-3">
      {ready ? (
        <Link
          to={`/course/${moduleId}/${t.id}`}
          className="group flex h-9 items-center gap-3 rounded-md px-2 transition-colors hover:bg-accent"
        >
          {header}
        </Link>
      ) : (
        <div className="flex h-9 items-center gap-3 px-2">{header}</div>
      )}

      {t.problems.length > 0 ? (
        <ul className="flex flex-col pr-2 pl-7">
          {t.problems.map((p) => (
            <ProblemRow key={p.id} p={p} />
          ))}
        </ul>
      ) : (
        <p className="py-0.5 pl-9 text-xs text-muted-foreground">
          Concepts and quiz, no problems
        </p>
      )}
    </div>
  );
}

function ProblemRow({ p }: { p: TopicProblem }) {
  const body = (
    <>
      <StatusIcon status={problemProgress(p.status)} />
      <span
        className={`min-w-0 flex-1 truncate text-[13px] ${
          p.available ? "text-foreground/85" : "text-muted-foreground"
        }`}
      >
        {p.title}
      </span>
      {p.difficulty && (
        <span
          className={`shrink-0 text-[11px] font-medium ${DIFF_TONE[p.difficulty].text}`}
        >
          {p.difficulty === "Medium" ? "Med" : p.difficulty}
        </span>
      )}
    </>
  );
  const cls = "flex h-7 items-center gap-2.5 rounded-md px-2";
  return (
    <li>
      {p.available ? (
        <Link
          to={`/problems/${p.id}`}
          className={`${cls} transition-colors hover:bg-accent`}
        >
          {body}
        </Link>
      ) : (
        <div className={cls}>{body}</div>
      )}
    </li>
  );
}

import { Link } from "react-router";
import { LuChevronRight } from "react-icons/lu";
import StatusIcon from "@/components/common/status-icon.tsx";
import { problemProgress } from "@/lib/progress.ts";
import { DIFF_TONE } from "@/lib/difficulty.ts";
import type { Difficulty } from "@shared/types.ts";

export type TopicProblemRow = {
  id: string;
  role: string;
  available: boolean;
  title: string;
  difficulty: Difficulty | null;
  lc: { id: number } | null;
  status: string;
};

export default function ProblemList({
  problems,
}: {
  problems: TopicProblemRow[];
}) {
  return (
    <ul className="divide-y divide-border overflow-hidden rounded-xl border border-border bg-card">
      {problems.map((p) => {
        const body = (
          <>
            <StatusIcon status={problemProgress(p.status)} className="size-4" />
            <span className="min-w-0 flex-1 truncate text-sm">{p.title}</span>
            {p.role === "guided" && (
              <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[11px] font-medium text-primary">
                Guided
              </span>
            )}
            {p.role === "optional" && (
              <span className="rounded-full bg-secondary px-2 py-0.5 text-[11px] text-muted-foreground">
                Optional
              </span>
            )}
            {p.difficulty && (
              <span
                className={`w-14 text-right text-xs font-medium ${DIFF_TONE[p.difficulty].text}`}
              >
                {p.difficulty}
              </span>
            )}
            <LuChevronRight
              className={`size-4 text-muted-foreground/50 transition-transform group-hover:translate-x-0.5 ${p.available ? "" : "invisible"}`}
            />
          </>
        );
        const cls = "flex h-12 items-center gap-3 px-4";
        return (
          <li key={p.id}>
            {p.available ? (
              <Link
                to={`/problems/${p.id}`}
                className={`group ${cls} transition-colors hover:bg-accent/40`}
              >
                {body}
              </Link>
            ) : (
              <div className={`${cls} text-muted-foreground`}>{body}</div>
            )}
          </li>
        );
      })}
    </ul>
  );
}

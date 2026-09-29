import { useEffect, useState } from "react";
import { useLocation } from "react-router";
import { useApi } from "@/lib/api.ts";
import CourseSummary from "@/components/course/course-summary.tsx";
import ModuleCard from "@/components/course/module-card.tsx";
import type { Course as CourseT, ModuleView } from "@shared/types.ts";

export default function Course() {
  const [data] = useApi<{ course: CourseT; modules: ModuleView[] }>("/course");
  const [open, setOpen] = useState<Set<string> | null>(null);
  const hash = decodeURIComponent(useLocation().hash.slice(1));
  const loaded = !!data;

  useEffect(() => {
    if (loaded && hash)
      document.getElementById(hash)?.scrollIntoView({ block: "start" });
  }, [loaded, hash]);

  if (!data) return null;

  const { modules } = data;
  const current = modules.find((m) => !m.complete);
  const target = modules.find((m) => m.id === hash) ?? current;
  const expanded = open ?? new Set(target ? [target.id] : []);

  const toggle = (id: string) => {
    const next = new Set(expanded);
    if (next.has(id)) next.delete(id);
    else next.add(id);
    setOpen(next);
  };
  const jumpTo = (id: string) => {
    setOpen(new Set([...expanded, id]));
    document
      .getElementById(id)
      ?.scrollIntoView({ behavior: "smooth", block: "start" });
  };

  return (
    <div className="mx-auto flex w-full max-w-4xl flex-col gap-6 px-8 py-8">
      <CourseSummary modules={modules} current={current} onJump={jumpTo} />

      <div className="flex flex-col gap-3">
        {modules.map((m) => (
          <ModuleCard
            key={m.id}
            m={m}
            isOpen={expanded.has(m.id)}
            onToggle={() => toggle(m.id)}
          />
        ))}
      </div>
    </div>
  );
}

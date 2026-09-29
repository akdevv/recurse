import { useEffect, useState } from "react";
import { PROGRESS_BAR, type Progress } from "@/lib/progress.ts";

export type TocItem = { id: string; label: string; sub?: boolean };

export default function OnThisPage({
  items,
  steps,
}: {
  items: TocItem[];
  steps: { label: string; status: Progress }[];
}) {
  const [active, setActive] = useState(items[0]?.id);
  const done = steps.filter((s) => s.status === "done").length;

  useEffect(() => {
    let frame = 0;
    const update = () => {
      frame = 0;
      // the last heading scrolled past the sticky header wins
      let current = items[0]?.id;
      for (const i of items) {
        const el = document.getElementById(i.id);
        if (el && el.getBoundingClientRect().top <= 120) current = i.id;
      }
      setActive(current);
    };
    const onScroll = () => {
      if (!frame) frame = requestAnimationFrame(update);
    };
    update();
    // scroll events don't bubble; capture catches the content pane scrolling
    document.addEventListener("scroll", onScroll, {
      passive: true,
      capture: true,
    });
    return () => {
      document.removeEventListener("scroll", onScroll, { capture: true });
      cancelAnimationFrame(frame);
    };
  }, [items]);

  return (
    <div className="sticky top-8 flex flex-col gap-6">
      <div className="flex flex-col gap-3 rounded-xl border border-border bg-card p-4">
        <div className="flex items-baseline justify-between">
          <span className="text-xs text-muted-foreground">Progress</span>
          <span className="text-xs tabular-nums">
            <span className="font-medium">{done}</span>
            <span className="text-muted-foreground"> / {steps.length}</span>
          </span>
        </div>
        <div className="flex gap-1">
          {steps.map((s) => (
            <span
              key={s.label}
              title={s.label}
              className={`h-1 flex-1 rounded-full ${PROGRESS_BAR[s.status]}`}
            />
          ))}
        </div>
      </div>

      <nav aria-label="On this page" className="flex flex-col gap-3">
        <div className="text-[11px] font-medium tracking-wider text-muted-foreground/70 uppercase">
          On this page
        </div>
        <ul className="flex flex-col border-l border-border text-[13px]">
          {items.map((i) => (
            <li key={i.id}>
              <a
                href={`#${i.id}`}
                className={`-ml-px block truncate border-l py-1 transition-colors ${
                  i.sub ? "pl-6 text-[12.5px]" : "pl-3"
                } ${
                  active === i.id
                    ? "border-primary font-medium text-foreground"
                    : "border-transparent text-muted-foreground hover:border-foreground/30 hover:text-foreground"
                }`}
              >
                {i.label}
              </a>
            </li>
          ))}
        </ul>
      </nav>
    </div>
  );
}

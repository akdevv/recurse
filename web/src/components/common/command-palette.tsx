import { useEffect, useMemo, useRef, useState } from "react";
import { useNavigate } from "react-router";
import type { IconType } from "react-icons";
import { LuBookOpen, LuCode, LuCornerDownLeft, LuSearch } from "react-icons/lu";
import { get } from "@/lib/api.ts";
import { DIFF_TONE } from "@/lib/difficulty.ts";
import { ALL_PAGES } from "@/lib/nav.ts";
import { paletteOpen, sidebarCollapsed } from "@/lib/ui-state.ts";
import type { Difficulty, ModuleView } from "@shared/types.ts";

type Entry = {
  group: "Pages" | "Topics" | "Problems";
  label: string;
  hint?: string;
  to: string;
  icon: IconType;
  difficulty?: Difficulty | null;
};

export default function CommandPalette() {
  const open = paletteOpen.use();

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (!(e.metaKey || e.ctrlKey)) return;
      if (e.key === "k") {
        e.preventDefault();
        paletteOpen.set(!paletteOpen.get());
      } else if (e.key === "b") {
        e.preventDefault();
        sidebarCollapsed.set(!sidebarCollapsed.get());
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  return open ? <Palette onClose={() => paletteOpen.set(false)} /> : null;
}

function Palette({ onClose }: { onClose: () => void }) {
  const navigate = useNavigate();
  const [query, setQuery] = useState("");
  const [active, setActive] = useState(0);
  const [modules, setModules] = useState<ModuleView[]>([]);
  const listRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    get<{ modules: ModuleView[] }>("/course").then((d) =>
      setModules(d.modules),
    );
  }, []);

  const entries = useMemo<Entry[]>(() => {
    const pages: Entry[] = ALL_PAGES.map((p) => ({
      group: "Pages",
      label: p.label,
      to: p.to,
      icon: p.icon,
    }));
    const topics: Entry[] = modules.flatMap((m) =>
      m.topicViews.map((t) => ({
        group: "Topics" as const,
        label: t.title,
        hint: m.title,
        to: `/course/${m.id}/${t.id}`,
        icon: LuBookOpen,
      })),
    );
    const seen = new Set<string>();
    const problems: Entry[] = modules.flatMap((m) =>
      m.topicViews.flatMap((t) =>
        t.problems
          .filter((p) => p.available && !seen.has(p.id) && seen.add(p.id))
          .map((p) => ({
            group: "Problems" as const,
            label: p.title,
            hint: t.title,
            to: `/problems/${p.id}`,
            icon: LuCode,
            difficulty: p.difficulty,
          })),
      ),
    );
    const words = query.toLowerCase().split(/\s+/).filter(Boolean);
    const all = [...pages, ...topics, ...problems];
    if (!words.length) return [...pages, ...topics.slice(0, 6)];
    return all
      .filter((e) => {
        const hay = `${e.label} ${e.hint ?? ""}`.toLowerCase();
        return words.every((w) => hay.includes(w));
      })
      .slice(0, 30);
  }, [modules, query]);

  const index = Math.min(active, Math.max(0, entries.length - 1));

  useEffect(() => {
    listRef.current
      ?.querySelector(`[data-index="${index}"]`)
      ?.scrollIntoView({ block: "nearest" });
  }, [index]);

  const go = (e: Entry | undefined) => {
    if (!e) return;
    onClose();
    navigate(e.to);
  };

  const onKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setActive((index + 1) % Math.max(1, entries.length));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setActive((index - 1 + entries.length) % Math.max(1, entries.length));
    } else if (e.key === "Enter") {
      e.preventDefault();
      go(entries[index]);
    } else if (e.key === "Escape") {
      onClose();
    }
  };

  let lastGroup = "";
  return (
    <div
      className="fixed inset-0 z-50 flex justify-center bg-black/50 px-4 pt-[14vh] backdrop-blur-[2px]"
      onMouseDown={onClose}
    >
      <div
        role="dialog"
        aria-label="Search"
        onMouseDown={(e) => e.stopPropagation()}
        className="flex h-fit max-h-[60vh] w-full max-w-xl flex-col overflow-hidden rounded-xl border border-border bg-popover shadow-2xl shadow-black/40"
      >
        <div className="flex items-center gap-3 border-b border-border px-4">
          <LuSearch className="size-4 shrink-0 text-muted-foreground" />
          <input
            id="command-search"
            autoFocus
            value={query}
            onChange={(e) => {
              setQuery(e.target.value);
              setActive(0);
            }}
            onKeyDown={onKeyDown}
            placeholder="Search pages, topics and problems…"
            className="h-12 flex-1 bg-transparent text-sm outline-none placeholder:text-muted-foreground"
          />
          <kbd className="rounded border border-border bg-secondary px-1.5 font-mono text-[10px] leading-4 text-muted-foreground">
            Esc
          </kbd>
        </div>

        <div ref={listRef} className="overflow-y-auto p-2">
          {entries.length === 0 && (
            <p className="px-3 py-8 text-center text-sm text-muted-foreground">
              Nothing matches “{query}”.
            </p>
          )}
          {entries.map((e, i) => {
            const heading = e.group !== lastGroup ? e.group : null;
            lastGroup = e.group;
            const Icon = e.icon;
            return (
              <div key={`${e.group}:${e.to}`}>
                {heading && (
                  <div className="px-3 pt-2 pb-1 text-[11px] font-medium tracking-wider text-muted-foreground/70 uppercase">
                    {heading}
                  </div>
                )}
                <button
                  data-index={i}
                  onMouseMove={() => setActive(i)}
                  onClick={() => go(e)}
                  className={`flex h-9 w-full items-center gap-3 rounded-md px-3 text-left text-sm ${
                    i === index
                      ? "bg-accent text-foreground"
                      : "text-foreground/85"
                  }`}
                >
                  <Icon className="size-4 shrink-0 text-muted-foreground" />
                  <span className="truncate">{e.label}</span>
                  {e.hint && (
                    <span className="truncate text-xs text-muted-foreground">
                      {e.hint}
                    </span>
                  )}
                  <span className="ml-auto flex shrink-0 items-center gap-2">
                    {e.difficulty && (
                      <span
                        className={`text-[11px] font-medium ${DIFF_TONE[e.difficulty].text}`}
                      >
                        {e.difficulty}
                      </span>
                    )}
                    {i === index && (
                      <LuCornerDownLeft className="size-3.5 text-muted-foreground" />
                    )}
                  </span>
                </button>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

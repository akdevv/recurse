import { Fragment } from "react";
import { Link, useLocation } from "react-router";
import { LuChevronRight, LuPanelLeft, LuSearch } from "react-icons/lu";
import { useCrumbs, type Crumb } from "@/lib/breadcrumbs.ts";
import { sectionOf } from "@/lib/nav.ts";
import { paletteOpen, sidebarCollapsed } from "@/lib/ui-state.ts";

const isMac =
  typeof navigator !== "undefined" && /Mac/.test(navigator.platform);

function fallback(pathname: string): Crumb[] {
  const section = sectionOf(pathname);
  if (!section) return [{ label: "Not found" }];
  if (section.to !== pathname)
    return [{ label: section.label, to: section.to }, { label: "…" }];
  return [{ label: section.label }];
}

export default function PageHeader() {
  const { pathname } = useLocation();
  const crumbs = useCrumbs() ?? fallback(pathname);
  const SectionIcon = sectionOf(pathname)?.icon;
  const collapsed = sidebarCollapsed.use();

  return (
    <header className="z-20 flex h-14 shrink-0 items-center gap-3 border-b border-border bg-background px-4">
      <button
        onClick={() => sidebarCollapsed.set(!collapsed)}
        aria-label={collapsed ? "Expand sidebar" : "Collapse sidebar"}
        title={`${collapsed ? "Expand" : "Collapse"} sidebar (${isMac ? "⌘" : "Ctrl"} B)`}
        className="grid size-8 shrink-0 place-items-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
      >
        <LuPanelLeft className="size-4" />
      </button>
      <div aria-hidden className="h-4 w-px bg-border" />

      <nav aria-label="Breadcrumb" className="min-w-0 flex-1">
        <ol className="flex items-center gap-1.5 text-sm">
          {crumbs.map((c, i) => {
            const last = i === crumbs.length - 1;
            const icon =
              i === 0 && SectionIcon ? (
                <SectionIcon className="size-4 shrink-0" />
              ) : null;
            return (
              <Fragment key={i}>
                {i > 0 && (
                  <li aria-hidden className="text-muted-foreground/50">
                    <LuChevronRight className="size-3.5" />
                  </li>
                )}
                <li className="min-w-0">
                  {last || !c.to ? (
                    <span
                      aria-current={last ? "page" : undefined}
                      className={`flex items-center gap-2 truncate ${last ? "font-medium text-foreground" : "text-muted-foreground"}`}
                    >
                      {icon}
                      {c.label}
                    </span>
                  ) : (
                    <Link
                      to={c.to}
                      className="flex items-center gap-2 truncate rounded-sm text-muted-foreground transition-colors hover:text-foreground"
                    >
                      {icon}
                      {c.label}
                    </Link>
                  )}
                </li>
              </Fragment>
            );
          })}
        </ol>
      </nav>

      <button
        onClick={() => paletteOpen.set(true)}
        className="flex h-8 w-56 shrink-0 items-center gap-2 rounded-md border border-border bg-card px-2.5 text-sm text-muted-foreground transition-colors hover:border-foreground/15 hover:text-foreground"
      >
        <LuSearch className="size-4 shrink-0" />
        <span className="flex-1 truncate text-left whitespace-nowrap">
          Search…
        </span>
        <kbd className="rounded border border-border bg-secondary px-1.5 font-mono text-[10px] leading-4 text-muted-foreground">
          {isMac ? "⌘" : "Ctrl"} K
        </kbd>
      </button>
    </header>
  );
}

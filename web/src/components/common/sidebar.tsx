import { useEffect, useState, useSyncExternalStore } from "react";
import { Link, NavLink, useLocation } from "react-router";
import { LuFlame, LuSettings } from "react-icons/lu";
import { get, onRefresh } from "@/lib/api.ts";
import { subscribeActivity, todaySeconds } from "@/lib/activity.ts";
import { NAV_GROUPS, type NavItem as Item } from "@/lib/nav.ts";
import { sidebarCollapsed } from "@/lib/ui-state.ts";
import Ring from "@/components/common/ring.tsx";
import Tooltip from "@/components/common/tooltip.tsx";
import type { Me } from "@shared/types.ts";

const WEEK_TARGET = 5;

// Every section: px-3 outer + px-2.5 inner, so all content shares one left edge.
// Collapsed (76px): every icon is centered on the same 38px line.
export default function Sidebar() {
  const [me, setMe] = useState<Me | null>(null);
  const { pathname } = useLocation();
  const collapsed = sidebarCollapsed.use();

  useEffect(() => {
    get<Me>("/me").then(setMe);
  }, [pathname]);
  useEffect(() => onRefresh(() => get<Me>("/me").then(setMe)), []);

  return (
    <aside
      className={`sticky top-0 flex h-screen shrink-0 flex-col overflow-hidden border-r border-sidebar-border bg-sidebar text-sidebar-foreground transition-[width] duration-200 motion-reduce:transition-none ${
        collapsed ? "w-19" : "w-60"
      }`}
    >
      <div className="flex h-14 shrink-0 items-center border-b border-sidebar-border px-3">
        <Link to="/" className="flex items-center gap-3 px-2.5">
          <img
            src="/icon-maskable-192.png"
            alt=""
            className="size-8 shrink-0 rounded-lg"
          />
          {!collapsed && (
            <span className="text-sm font-semibold tracking-tight whitespace-nowrap">
              Recurse
            </span>
          )}
        </Link>
      </div>

      {!collapsed && <TodayPanel me={me} />}

      <nav className="flex flex-1 flex-col gap-5 overflow-x-hidden overflow-y-auto px-3 py-4">
        {NAV_GROUPS.map((g, gi) => (
          <div key={g.label} className="flex flex-col gap-1">
            {collapsed ? (
              gi > 0 && (
                <div className="mx-auto mb-2 h-px w-6 bg-sidebar-border" />
              )
            ) : (
              <div className="px-2.5 pb-1.5 text-[11px] font-medium tracking-wider whitespace-nowrap text-muted-foreground/70 uppercase">
                {g.label}
              </div>
            )}
            {g.items.map((it) => (
              <NavItem
                key={it.to}
                {...it}
                collapsed={collapsed}
                count={
                  it.to === "/review"
                    ? me?.reviewsDue
                    : it.to === "/rewards"
                      ? me?.chests
                      : undefined
                }
              />
            ))}
          </div>
        ))}
      </nav>

      <ProfileRow me={me} collapsed={collapsed} />
    </aside>
  );
}

function TodayPanel({ me }: { me: Me | null }) {
  const secs = useSyncExternalStore(subscribeActivity, todaySeconds);
  const goal = me?.today.goal ?? 1800;
  const pct = Math.min(1, secs / goal);
  const weekDays = Math.min(
    WEEK_TARGET,
    me?.thisWeek.filter((d) => d.qualifies).length ?? 0,
  );
  // today joins the streak the moment the live ring fills, before the next /me refresh
  const streak =
    (me?.dayStreak ?? 0) + (me && !me.today.done && secs >= goal ? 1 : 0);
  const ring = (
    <Ring
      pct={pct}
      className={pct >= 1 ? "stroke-success" : "stroke-primary"}
    />
  );

  return (
    <div className="border-b border-sidebar-border px-3 py-4">
      <div className="flex flex-col gap-4 px-2.5">
        <div className="flex items-center gap-3">
          {ring}
          <div className="flex-1 text-sm whitespace-nowrap tabular-nums">
            <span className="font-semibold">{Math.floor(secs / 60)}</span>
            <span className="text-muted-foreground"> / {goal / 60} min</span>
          </div>
          <div
            title="Day streak"
            className={`flex h-6 items-center gap-1 rounded-full px-2 text-xs font-medium tabular-nums ring-1 ring-inset ${
              streak
                ? "bg-warning/10 text-warning ring-warning/20"
                : "bg-secondary text-muted-foreground ring-border"
            }`}
          >
            <LuFlame className="size-3.5" />
            {streak}
          </div>
        </div>

        <div className="flex flex-col gap-2">
          <div className="flex items-baseline justify-between text-xs whitespace-nowrap">
            <span className="text-muted-foreground">This week</span>
            <span className="tabular-nums">
              <span className="font-medium">{weekDays}</span>
              <span className="text-muted-foreground">
                {" "}
                / {WEEK_TARGET} days
              </span>
            </span>
          </div>
          <div className="flex gap-1">
            {Array.from({ length: WEEK_TARGET }, (_, i) => (
              <span
                key={i}
                className={`h-1 flex-1 rounded-full transition-colors ${i < weekDays ? "bg-success" : "bg-secondary"}`}
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function ProfileRow({ me, collapsed }: { me: Me | null; collapsed: boolean }) {
  const lv = me?.level;
  return (
    <div className="shrink-0 border-t border-sidebar-border p-3">
      <Tooltip label={`${me?.username ?? ""} · Settings`} enabled={collapsed}>
        <NavLink
          to="/settings"
          className={({ isActive }) =>
            `group flex items-center gap-3 rounded-lg transition-colors hover:bg-sidebar-accent ${
              collapsed ? "mx-auto size-11 justify-center" : "px-2.5 py-2"
            } ${isActive ? "bg-sidebar-accent" : ""}`
          }
        >
          <img
            src="/avatar.svg"
            alt=""
            className="size-8 shrink-0 rounded-full ring-1 ring-border"
          />
          {!collapsed && (
            <>
              <div className="min-w-0 flex-1 whitespace-nowrap">
                <div className="truncate text-sm leading-5 font-medium">
                  {me?.username}
                </div>
                <div className="truncate text-xs leading-4 text-muted-foreground">
                  {lv ? `Lv ${lv.level} · ${lv.title}` : " "}
                </div>
              </div>
              <LuSettings className="size-4 shrink-0 text-muted-foreground transition-colors group-hover:text-foreground" />
            </>
          )}
        </NavLink>
      </Tooltip>
    </div>
  );
}

function NavItem({
  to,
  label,
  icon: Icon,
  end,
  count,
  collapsed,
}: Item & { count?: number; collapsed: boolean }) {
  return (
    <Tooltip label={label} enabled={collapsed}>
      <NavLink
        to={to}
        end={end}
        aria-label={collapsed ? label : undefined}
        className={({ isActive }) =>
          `relative flex items-center gap-2.5 text-sm transition-colors ${
            collapsed
              ? "mx-auto size-9 justify-center rounded-lg"
              : "h-8 rounded-md px-2.5"
          } ${
            isActive
              ? "bg-sidebar-accent font-medium text-sidebar-accent-foreground"
              : "text-muted-foreground hover:bg-sidebar-accent/50 hover:text-foreground"
          }`
        }
      >
        {({ isActive }) => (
          <>
            <Icon
              className={`size-4 shrink-0 ${isActive ? "text-primary" : ""}`}
            />
            {!collapsed && (
              <span className="flex-1 whitespace-nowrap">{label}</span>
            )}
            {!!count &&
              (collapsed ? (
                <span className="absolute top-1.5 right-1.5 size-1.5 rounded-full bg-primary ring-2 ring-sidebar" />
              ) : (
                <span className="min-w-5 rounded-full bg-primary/15 px-1.5 text-center text-[11px] font-medium text-primary tabular-nums">
                  {count}
                </span>
              ))}
          </>
        )}
      </NavLink>
    </Tooltip>
  );
}

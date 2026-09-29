import { useSyncExternalStore, type ReactNode } from "react";
import { Link } from "react-router";
import type { IconType } from "react-icons";
import {
  LuArrowRight,
  LuCheck,
  LuBookOpen,
  LuCode,
  LuFlagTriangleRight,
  LuFlame,
  LuMap,
  LuRotateCcw,
  LuSnowflake,
  LuSparkles,
} from "react-icons/lu";
import { useApi } from "@/lib/api.ts";
import { subscribeActivity, todaySeconds } from "@/lib/activity.ts";
import Ring from "@/components/common/ring.tsx";
import StatCell from "@/components/common/stat-cell.tsx";
import ProgressBar from "@/components/course/progress-bar.tsx";
import type { Me, NextAction } from "@shared/types.ts";

const WEEK_TARGET = 5;
const WEEKS = 52;
const DAYS = ["M", "T", "W", "T", "F", "S", "S"];

const NEXT: Record<
  NextAction["kind"],
  { label: string; cta: string; icon: IconType }
> = {
  review: { label: "Review", cta: "Start review", icon: LuRotateCcw },
  learn: { label: "Learn", cta: "Start lesson", icon: LuBookOpen },
  solve: { label: "Solve", cta: "Open problem", icon: LuCode },
  finish: { label: "Finish topic", cta: "Continue", icon: LuFlagTriangleRight },
  browse: { label: "Explore", cta: "Open course", icon: LuMap },
};

const greeting = () => {
  const h = new Date().getHours();
  return h < 5
    ? "Late night"
    : h < 12
      ? "Good morning"
      : h < 18
        ? "Good afternoon"
        : "Good evening";
};

export default function Home() {
  const [data] = useApi<{
    me: Me;
    next: NextAction;
    activity: Record<string, number>;
  }>("/home");
  const secs = useSyncExternalStore(subscribeActivity, todaySeconds);
  if (!data) return null;

  const { me, next, activity } = data;
  const goalMin = me.today.goal / 60;
  const mins = Math.floor(secs / 60);
  const pct = Math.min(1, secs / me.today.goal);
  const todayKey = dateKey(new Date());

  return (
    <div className="mx-auto flex w-full max-w-4xl flex-col gap-6 px-8 py-8">
      <header className="flex items-center gap-4">
        <img
          src="/avatar.svg"
          alt=""
          className="size-12 shrink-0 rounded-full ring-1 ring-border"
        />
        <div>
          <p className="text-xs font-medium text-muted-foreground">
            {new Date().toLocaleDateString("en", {
              weekday: "long",
              day: "numeric",
              month: "long",
            })}
          </p>
          <h1 className="mt-1 text-2xl font-semibold tracking-tight">
            {greeting()}, {me.username}
          </h1>
        </div>
      </header>

      <div className="grid grid-cols-1 divide-y divide-border overflow-hidden rounded-xl border border-border bg-card sm:grid-cols-[15rem_1fr] sm:divide-x sm:divide-y-0">
        <div className="flex items-center gap-5 px-6 py-5">
          <Ring
            pct={pct}
            size={64}
            stroke={5}
            className={pct >= 1 ? "stroke-success" : "stroke-primary"}
          >
            {pct >= 1 ? (
              <LuCheck className="size-5 text-success" />
            ) : (
              <span className="text-sm font-semibold tabular-nums">
                {Math.round(pct * 100)}%
              </span>
            )}
          </Ring>
          <div className="flex flex-col">
            <span className="text-xs font-medium text-muted-foreground">
              Today
            </span>
            <span className="leading-8 tabular-nums">
              <span className="text-2xl font-semibold tracking-tight">
                {mins}
              </span>
              <span className="text-sm text-muted-foreground">
                {" "}
                / {goalMin} min
              </span>
            </span>
            <span className="text-xs text-muted-foreground">
              {pct >= 1 ? "Goal reached" : `${goalMin - mins} min to go`}
            </span>
          </div>
        </div>

        <UpNext next={next} />
      </div>

      <div className="grid grid-cols-1 divide-y divide-border overflow-hidden rounded-xl border border-border bg-card sm:grid-cols-3 sm:divide-x sm:divide-y-0">
        <StatCell icon={LuFlame} label="Weekly streak" tone="warning">
          <Value
            value={me.weekStreak}
            unit={me.weekStreak === 1 ? "week" : "weeks"}
          />
          <div className="flex gap-1">
            {me.thisWeek.map((d, i) => (
              <span
                key={d.date}
                title={`${d.date}: ${Math.floor(d.seconds / 60)} min`}
                className={`grid h-6 flex-1 place-items-center rounded text-[10px] font-medium ${
                  d.qualifies
                    ? "bg-success/20 text-success"
                    : d.seconds
                      ? "bg-primary/10 text-primary"
                      : "bg-secondary text-muted-foreground/60"
                } ${d.date === todayKey ? "ring-1 ring-foreground/40 ring-inset" : ""} ${
                  d.date > todayKey ? "opacity-40" : ""
                }`}
              >
                {DAYS[i]}
              </span>
            ))}
          </div>
          <Note>
            {Math.min(
              WEEK_TARGET,
              me.thisWeek.filter((d) => d.qualifies).length,
            )}{" "}
            / {WEEK_TARGET} days this week
            <span className="ml-auto flex items-center gap-1">
              <LuSnowflake className="size-3" />
              {me.freezes} freeze{me.freezes === 1 ? "" : "s"}
            </span>
          </Note>
        </StatCell>

        <StatCell icon={LuSparkles} label="Level" tone="primary">
          <Value value={me.level.level} unit={me.level.title} />
          <div className="flex h-6 items-center">
            <ProgressBar
              pct={me.level.into / me.level.need}
              className="flex-1"
            />
          </div>
          <Note>
            {me.level.need - me.level.into} XP to level {me.level.level + 1}
            <span className="ml-auto">{me.xp} XP total</span>
          </Note>
        </StatCell>

        <Link
          to="/review"
          className="group transition-colors hover:bg-accent/40"
        >
          <StatCell icon={LuRotateCcw} label="Reviews due" tone="success">
            <Value value={me.reviewsDue} unit="due today" />
            <p className="flex h-6 items-center text-xs text-muted-foreground">
              {me.reviewsDue
                ? "Clear these before starting new work."
                : "All caught up. Solved problems return here."}
            </p>
            <Note>
              Open review queue
              <LuArrowRight className="ml-auto size-3.5 transition-transform group-hover:translate-x-0.5 group-hover:text-foreground" />
            </Note>
          </StatCell>
        </Link>
      </div>

      <Heatmap activity={activity} goal={me.today.goal} />
    </div>
  );
}

function UpNext({ next }: { next: NextAction }) {
  const k = NEXT[next.kind];
  return (
    <Link
      to={next.href}
      className="group flex items-center gap-5 bg-linear-to-r from-primary/6 to-transparent px-6 py-5 transition-colors hover:from-primary/10"
    >
      <div className="flex min-w-0 flex-1 flex-col gap-1">
        <span className="flex items-center gap-1.5 text-xs font-medium text-primary">
          <k.icon className="size-3.5" />
          Up next · {k.label}
        </span>
        <span className="truncate text-lg font-semibold tracking-tight">
          {next.title}
        </span>
        {next.context && (
          <span className="truncate text-xs text-muted-foreground">
            {next.context}
          </span>
        )}
      </div>
      <span className="inline-flex h-9 shrink-0 items-center gap-2 rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground transition-colors group-hover:bg-primary/90">
        {k.cta}
        <LuArrowRight className="size-4 transition-transform group-hover:translate-x-0.5" />
      </span>
    </Link>
  );
}

function Value({ value, unit }: { value: number; unit: string }) {
  return (
    <span className="leading-8 tabular-nums">
      <span className="text-2xl font-semibold tracking-tight">{value}</span>
      <span className="text-sm text-muted-foreground"> {unit}</span>
    </span>
  );
}

function Note({ children }: { children: ReactNode }) {
  return (
    <span className="mt-auto flex items-center gap-1 text-xs text-muted-foreground tabular-nums">
      {children}
    </span>
  );
}

const dateKey = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;

function Heatmap({
  activity,
  goal,
}: {
  activity: Record<string, number>;
  goal: number;
}) {
  const today = new Date();
  const start = new Date(today);
  start.setDate(today.getDate() - ((today.getDay() + 6) % 7) - (WEEKS - 1) * 7);
  const cols = Array.from({ length: WEEKS }, (_, w) =>
    Array.from({ length: 7 }, (_, d) => {
      const dt = new Date(start);
      dt.setDate(start.getDate() + w * 7 + d);
      const key = dateKey(dt);
      return { key, dt, s: activity[key] ?? 0, future: dt > today };
    }),
  );
  const months = cols.map((c, i) =>
    i === 0 || c[0].dt.getMonth() !== cols[i - 1][0].dt.getMonth()
      ? c[0].dt.toLocaleString("en", { month: "short" })
      : "",
  );
  const todayKey = dateKey(today);
  const total = cols.flat().reduce((a, d) => a + d.s, 0);
  const days = cols.flat().filter((d) => d.s >= goal).length;

  // levels are relative to the daily goal: touched, goal, 2x, 4x
  const shade = (s: number) =>
    s >= goal * 4
      ? "bg-primary"
      : s >= goal * 2
        ? "bg-primary/65"
        : s >= goal
          ? "bg-primary/40"
          : s > 0
            ? "bg-primary/15"
            : "bg-secondary";

  return (
    <div className="flex flex-col gap-4 rounded-xl border border-border bg-card px-5 py-4">
      <div className="flex items-baseline justify-between gap-4">
        <span className="text-xs font-medium text-muted-foreground">
          Activity
        </span>
        <span className="text-xs text-muted-foreground tabular-nums">
          <span className="font-medium text-foreground">
            {Math.round(total / 3600)}h
          </span>{" "}
          in the last year ·{" "}
          <span className="font-medium text-foreground">{days}</span> goal days
        </span>
      </div>

      <div className="flex justify-center overflow-x-auto">
        <div
          className="grid grid-flow-col gap-0.75 text-[10px] leading-none text-muted-foreground/70"
          style={{
            gridTemplateColumns: `auto repeat(${WEEKS}, 11px)`,
            gridTemplateRows: "auto repeat(7, 11px)",
          }}
        >
          {["", "Mon", "", "Wed", "", "Fri", "", ""].map((l, i) => (
            <span key={i} className="flex items-center pr-2">
              {l}
            </span>
          ))}
          {cols.map((c, i) => [
            <span key={i} className="pb-1.5 whitespace-nowrap">
              {months[i]}
            </span>,
            ...c.map((d) => (
              <span
                key={d.key}
                title={
                  d.future
                    ? undefined
                    : `${d.dt.toLocaleDateString("en", { weekday: "short", day: "numeric", month: "short" })} · ${Math.floor(d.s / 60)} min`
                }
                className={`rounded-[2px] ${d.future ? "invisible" : shade(d.s)} ${
                  d.key === todayKey ? "ring-1 ring-foreground/50" : ""
                }`}
              />
            )),
          ])}
        </div>
      </div>

      <div className="flex items-center justify-between gap-4 text-[11px] text-muted-foreground/70">
        <span>Only focused, active time counts.</span>
        <span className="flex items-center gap-0.75">
          <span className="mr-1">Less</span>
          {[0, 1, goal, goal * 2, goal * 4].map((s) => (
            <span key={s} className={`size-2.75 rounded-[2px] ${shade(s)}`} />
          ))}
          <span className="ml-1">More</span>
        </span>
      </div>
    </div>
  );
}

import { useState, type ReactNode } from "react";
import type { IconType } from "react-icons";
import {
  LuCalendarCheck,
  LuClock,
  LuCode,
  LuMessageSquareQuote,
} from "react-icons/lu";
import { useApi } from "@/lib/api.ts";
import { pad2 } from "@/lib/text.ts";
import Segmented from "@/components/common/segmented.tsx";
import ProgressBar from "@/components/course/progress-bar.tsx";

type Stats = {
  totals: {
    activeSeconds: number;
    activeDays: number;
    goalDays: number;
    solved: number;
    hinted: number;
    assisted: number;
    quizAvg: number | null;
    explainAvg: number | null;
  };
  weeks: { start: string; minutes: number; xp: number }[];
  days: { start: string; minutes: number; xp: number }[];
  grades: {
    kind: string;
    ref: string;
    ts: string;
    score: number;
    title: string;
  }[];
  modules: {
    id: string;
    number: number;
    title: string;
    topics: number;
    topicsDone: number;
    problems: number;
    solved: number;
  }[];
};

const DAY_GOAL_MIN = 30;
const WEEK_GOAL_MIN = 5 * DAY_GOAL_MIN;

const hours = (s: number) =>
  s < 3600 ? `${Math.round(s / 60)}m` : `${(s / 3600).toFixed(1)}h`;

export default function Stats() {
  const [d] = useApi<Stats>("/stats");
  if (!d) return null;
  const t = d.totals;
  const solvedAll = t.solved + t.hinted + t.assisted;

  return (
    <div className="mx-auto flex w-full max-w-5xl flex-col gap-6 px-8 py-8">
      <div className="grid grid-cols-2 divide-border overflow-hidden rounded-xl border border-border bg-card lg:grid-cols-4 lg:divide-x">
        <Tile icon={LuClock} label="Active time" value={hours(t.activeSeconds)}>
          Focused, in-use time only
        </Tile>
        <Tile icon={LuCalendarCheck} label="Goal days" value={t.goalDays}>
          {t.activeDays} active days in total
        </Tile>
        <Tile icon={LuCode} label="Problems solved" value={solvedAll}>
          <OutcomeBar t={t} />
        </Tile>
        <Tile
          icon={LuMessageSquareQuote}
          label="Avg explain score"
          value={t.explainAvg === null ? "—" : `${t.explainAvg.toFixed(1)}/5`}
        >
          Quiz average{" "}
          {t.quizAvg === null ? "—" : `${Math.round(t.quizAvg * 100)}%`}
        </Tile>
      </div>

      <ActivityChart days={d.days} weeks={d.weeks} />

      <div className="grid items-start gap-6 lg:grid-cols-[3fr_2fr]">
        <Card title="Module progress">
          <ul className="flex flex-col divide-y divide-border">
            {d.modules.map((m) => (
              <li
                key={m.id}
                className="grid grid-cols-[1.75rem_minmax(0,1fr)_5.5rem_4rem] items-center gap-3 px-5 py-2.5"
              >
                <span className="font-mono text-[11px] text-muted-foreground tabular-nums">
                  {pad2(m.number)}
                </span>
                <span className="truncate text-sm">{m.title}</span>
                <ProgressBar pct={m.topics ? m.topicsDone / m.topics : 0} />
                <span className="text-right text-xs text-muted-foreground tabular-nums">
                  {m.solved}/{m.problems}
                </span>
              </li>
            ))}
          </ul>
        </Card>

        <Card title="Explain scores">
          {d.grades.length ? (
            <div className="flex flex-col">
              <div className="flex h-24 items-end gap-1 px-5 pt-4 pb-3">
                {d.grades.map((g, i) => (
                  <span
                    key={i}
                    title={`${g.title}: ${g.score}/5`}
                    className={`max-w-6 min-w-1 flex-1 rounded-t-sm ${scoreBg(g.score)}`}
                    style={{ height: `${Math.max(g.score, 0.3) * 20}%` }}
                  />
                ))}
              </div>
              <ul className="flex flex-col divide-y divide-border border-t border-border">
                {d.grades
                  .slice(-6)
                  .reverse()
                  .map((g, i) => (
                    <li key={i} className="flex items-center gap-3 px-5 py-2.5">
                      <span className="min-w-0 flex-1 truncate text-sm">
                        {g.title}
                      </span>
                      <span className="text-xs text-muted-foreground capitalize">
                        {g.kind}
                      </span>
                      <span
                        className={`w-9 rounded-full py-0.5 text-center text-[11px] font-semibold tabular-nums ${scoreText(g.score)}`}
                      >
                        {g.score}/5
                      </span>
                    </li>
                  ))}
              </ul>
            </div>
          ) : (
            <p className="px-5 py-10 text-center text-sm text-muted-foreground">
              Grade an explanation with AI and your scores show up here.
            </p>
          )}
        </Card>
      </div>
    </div>
  );
}

const scoreBg = (s: number) =>
  s >= 4 ? "bg-success/70" : s >= 3 ? "bg-warning/70" : "bg-destructive/60";
const scoreText = (s: number) =>
  s >= 4
    ? "bg-success/10 text-success"
    : s >= 3
      ? "bg-warning/10 text-warning"
      : "bg-destructive/10 text-destructive";

type Bucket = { start: string; minutes: number; xp: number };

const axisMin = (m: number) =>
  m >= 120 ? `${+(m / 60).toFixed(1)}h` : `${Math.round(m)}m`;

const niceMax = (v: number) => {
  const step = Math.pow(10, Math.floor(Math.log10(v)));
  return Math.ceil(v / step / 2) * step * 2 || 10;
};

function ActivityChart({ days, weeks }: { days: Bucket[]; weeks: Bucket[] }) {
  const [range, setRange] = useState<"day" | "week">("day");
  const [metric, setMetric] = useState<"minutes" | "xp">("minutes");
  const data = range === "day" ? days : weeks;
  const vals = data.map((b) => b[metric]);
  const goal =
    metric === "minutes"
      ? range === "day"
        ? DAY_GOAL_MIN
        : WEEK_GOAL_MIN
      : null;
  const top = niceMax(Math.max(...vals, goal ?? 0, 1));
  const total = vals.reduce((a, v) => a + v, 0);
  const active = vals.filter((v) => v > 0).length;
  const hits = goal ? vals.filter((v) => v >= goal).length : null;
  const unit = range === "day" ? "day" : "week";
  const fmtVal = (v: number) => (metric === "minutes" ? hours(v * 60) : `${v}`);
  const label = (b: Bucket) =>
    new Date(`${b.start}T00:00:00`).toLocaleDateString("en", {
      month: "short",
      day: "numeric",
    });
  const every = range === "day" ? 5 : 2;

  return (
    <Card
      title="Activity"
      action={
        <div className="flex items-center gap-2">
          <Segmented
            size="sm"
            value={range}
            onChange={setRange}
            options={[
              { id: "day", label: "Day" },
              { id: "week", label: "Week" },
            ]}
          />
          <Segmented
            size="sm"
            value={metric}
            onChange={setMetric}
            options={[
              { id: "minutes", label: "Time" },
              { id: "xp", label: "XP" },
            ]}
          />
        </div>
      }
    >
      <div className="grid grid-cols-3 divide-x divide-border border-b border-border">
        <Summary
          label={range === "day" ? "Last 30 days" : "Last 12 weeks"}
          value={fmtVal(total)}
        />
        <Summary
          label={`Average per active ${unit}`}
          value={fmtVal(active ? Math.round(total / active) : 0)}
        />
        <Summary
          label={hits === null ? `Active ${unit}s` : `Goal ${unit}s`}
          value={`${hits ?? active} / ${data.length}`}
        />
      </div>

      <div className="px-5 pt-6 pb-4">
        <div className="flex gap-3">
          <div className="relative h-44 w-10 shrink-0 text-right font-mono text-[10px] text-muted-foreground/60">
            {[1, 0.5, 0].map((f) => (
              <span
                key={f}
                className="absolute right-0 -translate-y-1/2"
                style={{ top: `${(1 - f) * 100}%` }}
              >
                {metric === "minutes" ? axisMin(top * f) : Math.round(top * f)}
              </span>
            ))}
          </div>
          <div className="relative h-44 flex-1">
            {[0, 0.5, 1].map((f) => (
              <span
                key={f}
                className="absolute inset-x-0 border-t border-border/60"
                style={{ top: `${f * 100}%` }}
              />
            ))}
            {goal && (
              <div
                className="pointer-events-none absolute inset-x-0 z-10 border-t border-dashed border-warning/60"
                style={{ bottom: `${(goal / top) * 100}%` }}
              >
                <span className="absolute right-0 -translate-y-full pb-0.5 text-[10px] text-warning/90">
                  goal {axisMin(goal)}
                </span>
              </div>
            )}
            <div
              className={`absolute inset-0 flex items-end ${range === "day" ? "gap-1" : "gap-2.5"}`}
            >
              {data.map((b, i) => {
                const v = vals[i];
                const hit = goal !== null && v >= goal;
                const current = i === data.length - 1;
                return (
                  <div
                    key={b.start}
                    className="group relative flex h-full flex-1 flex-col justify-end"
                  >
                    <span
                      className={`w-full rounded-t-[3px] transition-[height,background-color] duration-300 ${
                        v === 0
                          ? "bg-border/70"
                          : hit
                            ? "bg-success/75 group-hover:bg-success"
                            : "bg-primary/55 group-hover:bg-primary"
                      }`}
                      style={{ height: v ? `${(v / top) * 100}%` : "2px" }}
                    />
                    <span className="pointer-events-none absolute bottom-full left-1/2 z-20 mb-1.5 -translate-x-1/2 rounded-md border border-border bg-popover px-2 py-1 text-[11px] whitespace-nowrap text-popover-foreground opacity-0 shadow-lg transition-opacity group-hover:opacity-100">
                      <span className="text-muted-foreground">
                        {range === "week" ? "Week of " : ""}
                        {label(b)}
                        {current &&
                          (range === "day" ? " · today" : " · this week")}
                      </span>
                      <span className="ml-2 font-medium tabular-nums">
                        {metric === "minutes" ? `${v} min` : `${v} XP`}
                      </span>
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
        <div
          className={`mt-2 ml-13 flex text-[10px] text-muted-foreground/70 ${range === "day" ? "gap-1" : "gap-2.5"}`}
        >
          {data.map((b, i) => (
            <span
              key={b.start}
              className="flex-1 text-center whitespace-nowrap"
            >
              {i === data.length - 1
                ? range === "day"
                  ? "Today"
                  : "Now"
                : (data.length - 1 - i) % every === 0
                  ? label(b)
                  : ""}
            </span>
          ))}
        </div>
      </div>
    </Card>
  );
}

function Summary({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex flex-col gap-0.5 px-5 py-3.5">
      <span className="text-[11px] text-muted-foreground">{label}</span>
      <span className="text-lg font-semibold tracking-tight tabular-nums">
        {value}
      </span>
    </div>
  );
}

function OutcomeBar({ t }: { t: Stats["totals"] }) {
  const all = t.solved + t.hinted + t.assisted;
  if (!all) return <>No solves yet</>;
  const seg = [
    { n: t.solved, c: "bg-success", l: "clean" },
    { n: t.hinted, c: "bg-warning", l: "hinted" },
    { n: t.assisted, c: "bg-destructive/70", l: "assisted" },
  ];
  return (
    <span className="flex w-full flex-col gap-1.5">
      <span className="flex h-1 w-full gap-0.5 overflow-hidden rounded-full">
        {seg.map(
          (s) =>
            s.n > 0 && (
              <span
                key={s.l}
                className={s.c}
                style={{ width: `${(s.n / all) * 100}%` }}
              />
            ),
        )}
      </span>
      <span>
        {t.solved} clean · {t.hinted} hinted · {t.assisted} assisted
      </span>
    </span>
  );
}

function Tile({
  icon: Icon,
  label,
  value,
  children,
}: {
  icon: IconType;
  label: string;
  value: ReactNode;
  children: ReactNode;
}) {
  return (
    <div className="flex flex-col gap-2 px-5 py-4">
      <span className="flex items-center gap-2 text-xs font-medium text-muted-foreground">
        <Icon className="size-3.5" />
        {label}
      </span>
      <span className="text-2xl font-semibold tracking-tight tabular-nums">
        {value}
      </span>
      <span className="text-xs text-muted-foreground">{children}</span>
    </div>
  );
}

function Card({
  title,
  action,
  children,
}: {
  title: string;
  action?: ReactNode;
  children: ReactNode;
}) {
  return (
    <section className="overflow-hidden rounded-xl border border-border bg-card">
      <div className="flex h-11 items-center justify-between gap-4 border-b border-border px-5">
        <h2 className="text-sm font-medium">{title}</h2>
        {action}
      </div>
      {children}
    </section>
  );
}

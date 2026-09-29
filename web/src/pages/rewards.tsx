import { useState, type ReactNode } from "react";
import { LuCheck, LuLock, LuMountain } from "react-icons/lu";
import { emitRefresh, post, toast, useApi } from "@/lib/api.ts";
import Button from "@/components/common/button.tsx";
import RewardArt from "@/components/rewards/reward-art.tsx";
import TrophyArt, { type Metal } from "@/components/rewards/trophy-art.tsx";
import ChestsTab from "@/components/rewards/chests-tab.tsx";
import { shortDate } from "@/lib/text.ts";
import type { Me } from "@shared/types.ts";

type Badge = {
  id: string;
  name: string;
  desc: string;
  art: string;
  value: number;
  tiers: number[];
};
type Reward = {
  id: string;
  title: string;
  label: string;
  note: string;
  icon: string;
  size: "small" | "medium" | "big";
  requires: string[];
  progress: { done: number; total: number; boss: boolean | null };
  status: "locked" | "unlocked" | "availed";
  availedAt: string | null;
};
type Rewards = { path: Reward[]; badges: Badge[] };

const METAL_NAME = ["Locked", "Bronze", "Silver", "Gold"];
const PIP: Record<number, string> = {
  1: "bg-[#c98652]",
  2: "bg-[#cfd6dc]",
  3: "bg-[#f2c14e]",
};

const badgeState = (b: Badge) => {
  const tier = b.tiers.filter((t) => b.value >= t).length;
  const single = b.tiers.length === 1;
  const metal: Metal = single
    ? tier
      ? "jade"
      : "locked"
    : (["locked", "bronze", "silver", "gold"] as Metal[])[tier];
  return { tier, single, metal, next: b.tiers[tier] as number | undefined };
};

export default function RewardsPage() {
  const [r, reload] = useApi<Rewards>("/rewards");
  const [me, reloadMe] = useApi<Me>("/me");
  const [tab, setTab] = useState<"path" | "trophies" | "chests">("path");
  if (!r) return null;

  const setAvailed = async (x: Reward, availed: boolean) => {
    try {
      await post(`/rewards/${x.id}/availed`, { availed });
      if (availed) toast(`Enjoy it: ${x.title}`);
      emitRefresh();
      reload();
    } catch (e: any) {
      toast(e.message);
    }
  };

  const unlocked = r.path.filter((x) => x.status !== "locked").length;
  const states = r.badges.map((b) => ({ b, ...badgeState(b) }));
  const tiersEarned = states.reduce((a, s) => a + s.tier, 0);
  const tiersTotal = r.badges.reduce((a, b) => a + b.tiers.length, 0);

  return (
    <div className="mx-auto flex w-full max-w-5xl flex-col gap-8 px-8 py-8">
      <NextReward path={r.path} onAvail={(x) => setAvailed(x, true)} />

      <div className="flex items-center justify-between gap-4">
        <div className="inline-flex rounded-lg border border-border bg-card/60 p-1">
          {(
            [
              ["path", "Rewards", `${unlocked}/${r.path.length}`],
              ["trophies", "Trophies", `${tiersEarned}/${tiersTotal}`],
              ["chests", "Chests", me?.chests ? `${me.chests} new` : ""],
            ] as const
          ).map(([id, label, n]) => (
            <button
              key={id}
              onClick={() => setTab(id)}
              aria-pressed={tab === id}
              className={`flex h-8 items-center gap-2 rounded-md px-3.5 text-sm transition-all ${
                tab === id
                  ? "bg-accent font-medium text-foreground shadow-sm ring-1 ring-border"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              {label}
              <span
                className={`font-mono text-[11px] tabular-nums ${tab === id ? "text-muted-foreground" : "text-muted-foreground/60"}`}
              >
                {n}
              </span>
            </button>
          ))}
        </div>
        <span className="hidden text-xs text-muted-foreground sm:block">
          {tab === "path"
            ? "Real treats, unlocked by finishing the course"
            : tab === "chests"
              ? "Surprises for boss wins and clean solves"
              : "Earned by effort, never lost"}
        </span>
      </div>

      {tab === "path" ? (
        <Path path={r.path} onAvailed={setAvailed} />
      ) : tab === "chests" ? (
        <ChestsTab
          onChange={() => {
            reloadMe();
            reload();
          }}
        />
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {states.map((s) => (
            <TrophyCard key={s.b.id} {...s} />
          ))}
        </div>
      )}
    </div>
  );
}

function NextReward({
  path,
  onAvail,
}: {
  path: Reward[];
  onAvail: (x: Reward) => void;
}) {
  const next = path.find((x) => x.status === "locked");
  const waiting = path.filter((x) => x.status === "unlocked");
  const unlocked = path.filter((x) => x.status !== "locked").length;
  const pct = next?.progress.total
    ? next.progress.done / next.progress.total
    : 1;

  return (
    <div className="overflow-hidden rounded-2xl border border-border bg-card">
      <div className="flex items-center gap-6 px-7 py-6">
        <RewardArt art={next?.icon ?? "gift"} size={72} />
        <div className="flex min-w-0 flex-1 flex-col gap-1">
          <span className="text-xs text-muted-foreground">
            {next ? "Up next" : "Every reward unlocked"}
          </span>
          <span className="text-xl font-semibold tracking-tight">
            {next ? next.title : "You finished the course"}
          </span>
          {next && (
            <span className="text-sm text-muted-foreground">
              Finish {next.requires.join(" + ")}
              <span className="text-muted-foreground/50"> · </span>
              <span className="text-foreground/80 tabular-nums">
                {next.progress.total - next.progress.done} topic
                {next.progress.total - next.progress.done === 1 ? "" : "s"} to
                go
              </span>
            </span>
          )}
        </div>
        <div className="hidden text-right sm:block">
          <div className="text-2xl font-semibold tracking-tight tabular-nums">
            {unlocked}
            <span className="text-sm font-normal text-muted-foreground">
              /{path.length}
            </span>
          </div>
          <div className="text-xs text-muted-foreground">unlocked</div>
        </div>
      </div>

      {waiting.length > 0 ? (
        <div className="flex items-center gap-3 border-t border-border px-7 py-3">
          <span className="size-1.5 rounded-full bg-warning shadow-[0_0_8px_var(--warning)]" />
          <span className="flex-1 text-sm text-muted-foreground">
            <span className="font-medium text-foreground">
              {waiting[0].title}
            </span>{" "}
            is unlocked
            {waiting.length > 1 && ` (+${waiting.length - 1} more)`}. Enjoy it,
            then mark it as availed.
          </span>
          <Button size="sm" onClick={() => onAvail(waiting[0])}>
            Mark as availed
          </Button>
        </div>
      ) : (
        <div className="h-1 bg-secondary">
          <div
            className="h-full bg-warning transition-[width] duration-500"
            style={{ width: `${pct * 100}%` }}
          />
        </div>
      )}
    </div>
  );
}

function Path({
  path,
  onAvailed,
}: {
  path: Reward[];
  onAvailed: (x: Reward, availed: boolean) => void;
}) {
  const small = path.filter((x) => x.size === "small");
  const medium = path.filter((x) => x.size === "medium");
  const big = path.find((x) => x.size === "big");
  return (
    <div className="flex flex-col gap-9">
      <Phase
        title="Early wins"
        desc="Small treats, often, while the habit forms"
      >
        {small.map((x) => (
          <RewardCard key={x.id} x={x} onAvailed={onAvailed} />
        ))}
      </Phase>
      <Phase
        title="The climb"
        desc="Fewer, bigger rewards for the harder modules"
      >
        {medium.map((x) => (
          <RewardCard key={x.id} x={x} onAvailed={onAvailed} />
        ))}
        <li className="flex flex-col items-center justify-center gap-2 rounded-xl border border-dashed border-border px-3 py-4 text-center">
          <LuMountain className="size-6 text-muted-foreground/50" />
          <span className="text-xs font-medium text-muted-foreground">
            The long haul
          </span>
          <span className="text-[11px] leading-4 text-muted-foreground/70">
            Greedy, DP, Tries, Bits. No gifts on purpose.
          </span>
        </li>
      </Phase>
      {big && <Finale x={big} onAvailed={onAvailed} />}
    </div>
  );
}

function Phase({
  title,
  desc,
  children,
}: {
  title: string;
  desc: string;
  children: ReactNode;
}) {
  return (
    <section className="flex flex-col gap-3">
      <div className="flex items-baseline gap-2">
        <h2 className="text-sm font-semibold">{title}</h2>
        <span className="text-xs text-muted-foreground">{desc}</span>
      </div>
      <ol className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-6">
        {children}
      </ol>
    </section>
  );
}

function RewardCard({
  x,
  onAvailed,
}: {
  x: Reward;
  onAvailed: (x: Reward, availed: boolean) => void;
}) {
  const locked = x.status === "locked";
  return (
    <li
      title={x.note || undefined}
      className={`group flex flex-col overflow-hidden rounded-xl border transition-colors ${
        x.status === "unlocked"
          ? "border-warning/40 bg-card shadow-[0_0_0_3px_color-mix(in_srgb,var(--warning)_8%,transparent)]"
          : locked
            ? "border-border/70 bg-card/60 hover:border-border"
            : "border-border bg-card"
      }`}
    >
      <div
        className={`relative grid h-24 place-items-center ${
          x.status === "unlocked"
            ? "bg-[radial-gradient(circle_at_50%_60%,color-mix(in_srgb,var(--warning)_16%,transparent),transparent_70%)]"
            : "bg-[radial-gradient(circle_at_50%_60%,color-mix(in_srgb,var(--foreground)_5%,transparent),transparent_70%)]"
        }`}
      >
        <RewardArt art={x.icon} size={52} locked={locked} />
        {x.status === "availed" && (
          <span className="absolute top-2.5 right-2.5 grid size-5 place-items-center rounded-full bg-success text-background">
            <LuCheck className="size-3" strokeWidth={3} />
          </span>
        )}
        {locked && (
          <span className="absolute top-2.5 right-2.5 text-muted-foreground/50">
            <LuLock className="size-3.5" />
          </span>
        )}
      </div>

      <div className="flex flex-col items-center gap-0.5 px-3 text-center">
        <span
          className={`text-sm font-medium ${locked ? "text-foreground/75" : ""}`}
        >
          {x.title}
        </span>
        <span className="line-clamp-1 text-[11px] text-muted-foreground">
          {x.label}
        </span>
      </div>

      <div className="mt-auto px-3 pt-3 pb-3">
        {locked ? (
          <div className="flex flex-col gap-1.5">
            <div className="h-2 overflow-hidden rounded-full bg-secondary">
              <div
                className="h-full rounded-full bg-linear-to-r from-warning/60 to-warning transition-[width] duration-500"
                style={{
                  width: `${x.progress.total ? (x.progress.done / x.progress.total) * 100 : 0}%`,
                }}
              />
            </div>
            <span className="text-center text-[10px] text-muted-foreground tabular-nums">
              {x.progress.done} of {x.progress.total} topics
            </span>
          </div>
        ) : x.status === "unlocked" ? (
          <Button
            size="sm"
            className="h-7 w-full"
            onClick={() => onAvailed(x, true)}
          >
            Mark availed
          </Button>
        ) : (
          <div className="flex h-5 items-center justify-center text-[11px]">
            <span className="text-success group-hover:hidden">
              Availed {shortDate(x.availedAt!)}
            </span>
            <button
              onClick={() => onAvailed(x, false)}
              className="hidden text-muted-foreground group-hover:inline hover:text-foreground"
            >
              Mark as pending
            </button>
          </div>
        )}
      </div>
    </li>
  );
}

function Finale({
  x,
  onAvailed,
}: {
  x: Reward;
  onAvailed: (x: Reward, availed: boolean) => void;
}) {
  const locked = x.status === "locked";
  const pct = x.progress.total ? x.progress.done / x.progress.total : 0;
  return (
    <section className="flex flex-col gap-3">
      <div className="flex items-baseline gap-2">
        <h2 className="text-sm font-semibold">The summit</h2>
        <span className="text-xs text-muted-foreground">
          All of it, plus one mock interview
        </span>
      </div>
      <div className="flex flex-wrap items-center gap-6 rounded-xl border border-warning/25 bg-linear-to-r from-warning/5 to-card p-4 pr-6">
        <div className="relative grid size-28 shrink-0 place-items-center rounded-lg bg-[radial-gradient(circle_at_50%_60%,color-mix(in_srgb,var(--warning)_16%,transparent),transparent_70%)]">
          <RewardArt art={x.icon} size={80} />
          {locked ? (
            <span className="absolute top-2 right-2 text-muted-foreground/50">
              <LuLock className="size-3.5" />
            </span>
          ) : (
            x.status === "availed" && (
              <span className="absolute top-2 right-2 grid size-5 place-items-center rounded-full bg-success text-background">
                <LuCheck className="size-3" strokeWidth={3} />
              </span>
            )
          )}
        </div>

        <div className="flex min-w-0 flex-1 flex-col gap-1">
          <span className="text-xl font-semibold tracking-tight">
            {x.title}
          </span>
          <span className="text-sm text-muted-foreground">{x.note}</span>
        </div>

        <div className="text-right">
          {locked ? (
            <>
              <div className="text-2xl font-semibold tracking-tight tabular-nums">
                {Math.floor(pct * 100)}%
              </div>
              <div className="text-xs text-muted-foreground">
                {x.progress.done === x.progress.total
                  ? "Now beat the DP boss"
                  : "of the course done"}
              </div>
            </>
          ) : x.status === "unlocked" ? (
            <Button onClick={() => onAvailed(x, true)}>Mark as availed</Button>
          ) : (
            <span className="text-sm text-success">
              Availed {shortDate(x.availedAt!)}
            </span>
          )}
        </div>
      </div>
    </section>
  );
}

function TrophyCard({
  b,
  tier,
  single,
  metal,
  next,
}: {
  b: Badge;
} & ReturnType<typeof badgeState>) {
  const maxed = next === undefined;
  const status = !tier ? "Locked" : single ? "Earned" : METAL_NAME[tier];
  return (
    <div
      className={`flex items-center gap-4 rounded-xl border p-4 ${
        tier ? "border-border bg-card" : "border-border/60 bg-card/50"
      }`}
    >
      <TrophyArt art={b.art} metal={metal} size={64} />
      <div className="flex min-w-0 flex-1 flex-col gap-2">
        <div className="flex items-center justify-between gap-2">
          <span
            className={`truncate text-sm font-semibold ${tier ? "" : "text-foreground/60"}`}
          >
            {b.name}
          </span>
          {single ? (
            <span
              className={`text-[11px] ${tier ? "text-primary" : "text-muted-foreground/60"}`}
            >
              {status}
            </span>
          ) : (
            <span className="flex items-center gap-1" title={status}>
              {[1, 2, 3].map((t) => (
                <span
                  key={t}
                  className={`size-1.5 rounded-full ${t <= tier ? PIP[t] : "bg-secondary ring-1 ring-border"}`}
                />
              ))}
            </span>
          )}
        </div>
        <div className="h-1 overflow-hidden rounded-full bg-secondary">
          <div
            className={`h-full rounded-full transition-[width] duration-500 ${
              maxed && !single ? "bg-warning" : "bg-primary"
            }`}
            style={{
              width: `${maxed ? 100 : Math.min(100, (b.value / next) * 100)}%`,
            }}
          />
        </div>
        <div className="flex items-baseline justify-between gap-3 text-[11px] text-muted-foreground">
          <span className="min-w-0 truncate" title={b.desc}>
            <span className="text-foreground/85 tabular-nums">
              {maxed ? b.value : `${Math.min(b.value, next)}/${next}`}
            </span>{" "}
            {b.desc}
          </span>
          <span className="shrink-0">
            {single ? (
              ""
            ) : maxed ? (
              <span className="text-warning">Complete</span>
            ) : (
              `${METAL_NAME[tier + 1]} next`
            )}
          </span>
        </div>
      </div>
    </div>
  );
}

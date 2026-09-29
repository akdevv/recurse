import { useEffect, useState } from "react";
import { LuPackage, LuSnowflake, LuSparkles, LuX } from "react-icons/lu";
import { emitRefresh, onChest, post } from "@/lib/api.ts";
import Button from "@/components/common/button.tsx";
import { COLLECTIBLE_ICON, rewardText } from "@/lib/chest.ts";
import type { ChestReward } from "@shared/types.ts";

export function RewardIcon({
  r,
  className = "size-7",
}: {
  r: ChestReward;
  className?: string;
}) {
  const Icon =
    r.kind === "xp"
      ? LuSparkles
      : r.kind === "freeze"
        ? LuSnowflake
        : (COLLECTIBLE_ICON[r.id] ?? LuSparkles);
  return <Icon className={className} />;
}

const tone = (r: ChestReward) =>
  r.kind === "collectible"
    ? "bg-warning/15 text-warning ring-warning/30"
    : r.kind === "freeze"
      ? "bg-success/15 text-success ring-success/30"
      : "bg-primary/15 text-primary ring-primary/30";

/** The opening dialog: a closed chest, then the reward it held. */
export function ChestDialog({
  id,
  onClose,
}: {
  id: number;
  onClose: () => void;
}) {
  const [reward, setReward] = useState<ChestReward | null>(null);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");

  useEffect(() => {
    const h = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", h);
    return () => window.removeEventListener("keydown", h);
  }, [onClose]);

  const open = async () => {
    setBusy(true);
    try {
      const r = await post<{ reward: ChestReward }>(`/chests/${id}/open`);
      setReward(r.reward);
      emitRefresh();
    } catch (e: any) {
      setErr(e.message);
    }
    setBusy(false);
  };

  const t = reward && rewardText(reward);
  return (
    <div
      className="fixed inset-0 z-50 grid place-items-center bg-black/50 px-4 backdrop-blur-[2px]"
      onClick={onClose}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Mystery chest"
        onClick={(e) => e.stopPropagation()}
        className="relative flex w-full max-w-sm flex-col items-center gap-5 rounded-2xl border border-border bg-card px-8 pt-10 pb-7 text-center shadow-2xl"
      >
        <button
          onClick={onClose}
          aria-label="Close"
          className="absolute top-3 right-3 grid size-8 place-items-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
        >
          <LuX className="size-4" />
        </button>

        {reward && t ? (
          <>
            <span
              className={`grid size-20 place-items-center rounded-2xl ring-1 ring-inset motion-safe:animate-[pop_400ms_ease-out] ${tone(reward)}`}
            >
              <RewardIcon r={reward} className="size-9" />
            </span>
            <div className="flex flex-col gap-1">
              <span className="text-xs text-muted-foreground">
                {reward.kind === "collectible"
                  ? "Rare collectible"
                  : "You found"}
              </span>
              <span className="text-xl font-semibold tracking-tight">
                {t.title}
              </span>
              <span className="text-sm text-muted-foreground">{t.sub}</span>
            </div>
            <Button onClick={onClose} className="w-full">
              Nice
            </Button>
          </>
        ) : (
          <>
            <span className="grid size-20 place-items-center rounded-2xl bg-warning/10 text-warning ring-1 ring-warning/25 ring-inset motion-safe:animate-[wiggle_1.6s_ease-in-out_infinite]">
              <LuPackage className="size-9" />
            </span>
            <div className="flex flex-col gap-1">
              <span className="text-xl font-semibold tracking-tight">
                Mystery chest
              </span>
              <span className="text-sm text-muted-foreground">
                Earned by your effort. Bonus XP, a streak freeze, or a rare
                collectible.
              </span>
            </div>
            {err && <span className="text-sm text-destructive">{err}</span>}
            <div className="flex w-full gap-2">
              <Button variant="secondary" onClick={onClose} className="flex-1">
                Later
              </Button>
              <Button onClick={open} disabled={busy} className="flex-1">
                {busy ? "Opening…" : "Open it"}
              </Button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

/** Mounted once: shows the dialog whenever a chest is earned anywhere in the app. */
export function ChestHost() {
  const [queue, setQueue] = useState<number[]>([]);
  useEffect(() => onChest((id) => setQueue((q) => [...q, id])), []);
  if (!queue.length) return null;
  return (
    <ChestDialog
      key={queue[0]}
      id={queue[0]}
      onClose={() => setQueue((q) => q.slice(1))}
    />
  );
}

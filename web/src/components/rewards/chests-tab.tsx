import { useState } from "react";
import { LuPackage, LuSwords, LuCode } from "react-icons/lu";
import { useApi } from "@/lib/api.ts";
import Button from "@/components/common/button.tsx";
import { ChestDialog, RewardIcon } from "@/components/rewards/chest.tsx";
import { COLLECTIBLE_ICON, rewardText } from "@/lib/chest.ts";
import { shortDate } from "@/lib/text.ts";
import type { Chests } from "@shared/types.ts";

export default function ChestsTab({ onChange }: { onChange: () => void }) {
  const [c, reload] = useApi<Chests>("/chests");
  const [opening, setOpening] = useState<number | null>(null);
  if (!c) return null;
  const owned = c.collectibles.filter((x) => x.owned).length;

  return (
    <div className="flex flex-col gap-9">
      <section className="flex flex-col gap-3">
        <div className="flex items-baseline gap-2">
          <h2 className="text-sm font-semibold">Waiting to be opened</h2>
          <span className="text-xs text-muted-foreground">
            Every boss win drops one; a clean first solve has a 1 in 4 chance
          </span>
        </div>
        {c.unopened.length ? (
          <ul className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {c.unopened.map((x) => (
              <li
                key={x.id}
                className="flex items-center gap-4 rounded-xl border border-warning/25 bg-warning/5 px-4 py-3.5"
              >
                <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-warning/10 text-warning ring-1 ring-warning/25 ring-inset motion-safe:animate-[wiggle_2.4s_ease-in-out_infinite]">
                  <LuPackage className="size-5" />
                </span>
                <div className="min-w-0 flex-1">
                  <div className="text-sm font-medium">
                    {x.source === "boss" ? "Boss chest" : "Solve chest"}
                  </div>
                  <div className="text-xs text-muted-foreground">
                    Earned {shortDate(x.ts)}
                  </div>
                </div>
                <Button size="sm" onClick={() => setOpening(x.id)}>
                  Open
                </Button>
              </li>
            ))}
          </ul>
        ) : (
          <div className="flex items-center gap-3 rounded-xl border border-dashed border-border px-5 py-5 text-sm text-muted-foreground">
            <LuPackage className="size-4 shrink-0" />
            No chests right now. Win a boss fight or solve something without
            hints for a chance at one.
          </div>
        )}
      </section>

      <section className="flex flex-col gap-3">
        <div className="flex items-baseline gap-2">
          <h2 className="text-sm font-semibold">Collectibles</h2>
          <span className="text-xs text-muted-foreground tabular-nums">
            {owned}/{c.collectibles.length} found · only from chests
          </span>
        </div>
        <ul className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
          {c.collectibles.map((x) => {
            const Icon = COLLECTIBLE_ICON[x.id];
            return (
              <li
                key={x.id}
                className={`flex flex-col items-center gap-2 rounded-xl border px-3 py-4 text-center ${
                  x.owned
                    ? "border-warning/25 bg-warning/5"
                    : "border-border bg-card/40"
                }`}
              >
                <span
                  className={`grid size-12 place-items-center rounded-xl ring-1 ring-inset ${
                    x.owned
                      ? "bg-warning/10 text-warning ring-warning/25"
                      : "bg-secondary text-muted-foreground/30 ring-border"
                  }`}
                >
                  {x.owned && Icon ? (
                    <Icon className="size-6" />
                  ) : (
                    <span className="text-lg font-semibold">?</span>
                  )}
                </span>
                <span
                  className={`text-sm font-medium ${x.owned ? "" : "text-muted-foreground"}`}
                >
                  {x.owned ? x.name : "Undiscovered"}
                </span>
                <span className="text-[11px] leading-4 text-muted-foreground">
                  {x.owned ? x.desc : "Keep opening chests"}
                </span>
              </li>
            );
          })}
        </ul>
      </section>

      {c.opened.length > 0 && (
        <section className="flex flex-col gap-3">
          <h2 className="text-sm font-semibold">Recent finds</h2>
          <ul className="divide-y divide-border rounded-xl border border-border bg-card">
            {c.opened.map((x) => {
              const t = rewardText(x.reward);
              return (
                <li key={x.id} className="flex items-center gap-3 px-4 py-2.5">
                  <span className="grid size-8 place-items-center rounded-lg bg-secondary text-foreground/80">
                    <RewardIcon r={x.reward} className="size-4" />
                  </span>
                  <span className="flex-1 text-sm">{t.title}</span>
                  <span className="flex items-center gap-1.5 text-xs text-muted-foreground">
                    {x.source === "boss" ? (
                      <LuSwords className="size-3.5" />
                    ) : (
                      <LuCode className="size-3.5" />
                    )}
                    {shortDate(x.openedAt)}
                  </span>
                </li>
              );
            })}
          </ul>
        </section>
      )}

      {opening !== null && (
        <ChestDialog
          id={opening}
          onClose={() => {
            setOpening(null);
            reload();
            onChange();
          }}
        />
      )}
    </div>
  );
}

import { db, nowIso, addXp, fail } from "./db.ts";
import { activityMap } from "./progress.ts";
import { computeStreak, MAX_FREEZES } from "./engine/streak.ts";
import { localDate } from "./engine/dates.ts";
import type { ChestReward, ChestSource, EarnedChest } from "../shared/types.ts";

export const SOLVE_CHEST_CHANCE = 0.25;

export const COLLECTIBLES = [
  { id: "golden-pointer", name: "Golden Pointer", desc: "Never off by one." },
  {
    id: "rubber-duck",
    name: "Rubber Duck",
    desc: "Listens to every bug, judges none.",
  },
  {
    id: "lucky-pivot",
    name: "Lucky Pivot",
    desc: "Always splits the array in half.",
  },
  {
    id: "bottomless-stack",
    name: "Bottomless Stack",
    desc: "Has never overflowed.",
  },
  {
    id: "perfect-hash",
    name: "Perfect Hash",
    desc: "Zero collisions, every time.",
  },
  { id: "big-o-mug", name: "Big-O Mug", desc: "Holds exactly O(1) coffee." },
  {
    id: "memo-pad",
    name: "Memo Pad",
    desc: "Never solves the same thing twice.",
  },
  {
    id: "dijkstra-compass",
    name: "Dijkstra's Compass",
    desc: "Points to the closest node.",
  },
  {
    id: "balanced-bonsai",
    name: "Balanced Bonsai",
    desc: "Height O(log n), always.",
  },
  { id: "xor-coin", name: "XOR Coin", desc: "Flip it twice, it cancels out." },
  {
    id: "trie-leaf",
    name: "Trie Leaf",
    desc: "Shares its prefixes generously.",
  },
  {
    id: "tortoise-hare",
    name: "Tortoise & Hare",
    desc: "They always meet in the loop.",
  },
];

type Row = {
  id: number;
  ts: string;
  source: ChestSource;
  ref: string;
  opened_at: string | null;
  reward: string | null;
};

export function earnChest(source: ChestSource, ref: string): EarnedChest {
  const r = db
    .prepare("INSERT INTO chests (ts, source, ref) VALUES (?, ?, ?)")
    .run(nowIso(), source, ref);
  return { id: Number(r.lastInsertRowid), source };
}

export const maybeSolveChest = (pid: string, outcome: string | null) =>
  outcome === "solved" && Math.random() < SOLVE_CHEST_CHANCE
    ? earnChest("solve", pid)
    : null;

const owned = () =>
  new Set(
    (
      db
        .prepare("SELECT reward FROM chests WHERE reward IS NOT NULL")
        .all() as { reward: string }[]
    )
      .map((r) => JSON.parse(r.reward) as ChestReward)
      .flatMap((r) => (r.kind === "collectible" ? [r.id] : [])),
  );

/** Freezes from opened chests by local date, for computeStreak. */
export function bonusFreezes(): Record<string, number> {
  const out: Record<string, number> = {};
  for (const r of db
    .prepare(
      "SELECT opened_at FROM chests WHERE reward LIKE '%\"freeze\"%' AND opened_at IS NOT NULL",
    )
    .all() as { opened_at: string }[]) {
    const d = localDate(new Date(r.opened_at));
    out[d] = (out[d] ?? 0) + 1;
  }
  return out;
}

function roll(source: ChestSource): ChestReward {
  const boss = source === "boss";
  const x = Math.random();
  const xp = (): ChestReward => ({
    kind: "xp",
    amount: boss
      ? 50 + 10 * Math.floor(Math.random() * 8)
      : 15 + 5 * Math.floor(Math.random() * 6),
  });
  if (x < (boss ? 0.35 : 0.15)) {
    const have = owned();
    const left = COLLECTIBLES.filter((c) => !have.has(c.id));
    if (left.length) {
      const c = left[Math.floor(Math.random() * left.length)];
      return { kind: "collectible", ...c };
    }
  } else if (x < (boss ? 0.6 : 0.4)) {
    const s = computeStreak(activityMap(), localDate(), bonusFreezes());
    if (s.freezes < MAX_FREEZES) return { kind: "freeze" };
  }
  return xp();
}

export function openChest(id: number) {
  const c = db.prepare("SELECT * FROM chests WHERE id = ?").get(id) as
    Row | undefined;
  if (!c) throw fail("No such chest.", 404);
  if (c.opened_at) return JSON.parse(c.reward!) as ChestReward;
  const reward = roll(c.source);
  db.prepare("UPDATE chests SET opened_at = ?, reward = ? WHERE id = ?").run(
    nowIso(),
    JSON.stringify(reward),
    id,
  );
  if (reward.kind === "xp") addXp(reward.amount, "chest", String(id));
  return reward;
}

export const chestsWaiting = () =>
  (
    db
      .prepare("SELECT COUNT(*) AS n FROM chests WHERE opened_at IS NULL")
      .get() as { n: number }
  ).n;

export function chestsView() {
  const rows = db
    .prepare("SELECT * FROM chests ORDER BY id DESC")
    .all() as Row[];
  const have = owned();
  return {
    unopened: rows
      .filter((r) => !r.opened_at)
      .map((r) => ({ id: r.id, ts: r.ts, source: r.source })),
    opened: rows
      .filter((r) => r.opened_at)
      .slice(0, 20)
      .map((r) => ({
        id: r.id,
        openedAt: r.opened_at!,
        source: r.source,
        reward: JSON.parse(r.reward!) as ChestReward,
      })),
    collectibles: COLLECTIBLES.map((c) => ({ ...c, owned: have.has(c.id) })),
  };
}

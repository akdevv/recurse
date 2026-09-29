// When to nudge next. Pure (no DB, no clock) so it's testable; server/notify.ts feeds it.

export const MIN_GAP_MS = 20 * 60_000;
export const MAX_GAP_MS = 150 * 60_000;
export const CAP_PLANNED = 8;
export const CAP_CATCH_UP = 2; // unplanned day that can still save the weekly streak

/** Deterministic 0..1 from a seed, so a given day's schedule is reproducible. */
export function rand(seed: number) {
  let t = (seed + 0x6d2b79f5) | 0;
  t = Math.imul(t ^ (t >>> 15), t | 1);
  t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
}

const at = (day: Date, hhmm: string) => {
  const [h, m] = hhmm.split(":").map(Number);
  const d = new Date(day);
  d.setHours(h, m, 0, 0);
  return d;
};

export function nextReminderAt(o: {
  now: Date;
  window: { start: string; end: string };
  plannedDay: boolean;
  catchUp: boolean;
  todayDone: boolean;
  sentToday: number;
  lastSentAt: Date | null;
}): Date | null {
  const cap = o.plannedDay ? CAP_PLANNED : o.catchUp ? CAP_CATCH_UP : 0;
  if (o.todayDone || o.sentToday >= cap) return null;
  const start = at(o.now, o.window.start);
  const end = at(o.now, o.window.end);
  if (o.now >= end) return null;
  const seed =
    o.now.getFullYear() * 10000 +
    (o.now.getMonth() + 1) * 100 +
    o.now.getDate() +
    o.sentToday * 7919;
  const soonest = new Date(o.now.getTime() + 60_000);

  let t: Date;
  if (!o.sentToday || !o.lastSentAt) {
    const first = new Date(
      Math.max(start.getTime(), at(o.now, "11:00").getTime()) +
        rand(seed) * 30 * 60_000,
    );
    t = new Date(Math.max(first.getTime(), soonest.getTime()));
  } else {
    // gaps shrink as the window runs out
    const left = end.getTime() - o.lastSentAt.getTime();
    const gap =
      Math.min(MAX_GAP_MS, Math.max(MIN_GAP_MS, left / 4)) *
      (0.7 + 0.6 * rand(seed));
    t = new Date(Math.max(o.lastSentAt.getTime() + gap, soonest.getTime()));
  }
  return t < end ? t : null;
}

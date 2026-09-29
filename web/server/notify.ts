// One pending setTimeout, recomputed after every send or relevant change. No polling.
import webpush from "web-push";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { db, nowIso, ROOT } from "./db.ts";
import { me, nextAction } from "./progress.ts";
import { getSettings } from "./settings.ts";
import { DAYS_PER_WEEK } from "./engine/streak.ts";
import { nextReminderAt } from "./engine/reminders.ts";

const ACTIVE_GRACE_MS = 5 * 60_000; // no nudges while you're in the app
const STALE_MS = 10 * 60_000; // woke from sleep long after it was due: skip it

const vapidPath = join(ROOT, "data", "vapid.json");
const vapid: { publicKey: string; privateKey: string } = existsSync(vapidPath)
  ? JSON.parse(readFileSync(vapidPath, "utf8"))
  : webpush.generateVAPIDKeys();
if (!existsSync(vapidPath)) writeFileSync(vapidPath, JSON.stringify(vapid));
webpush.setVapidDetails(
  "mailto:rcx@example.com",
  vapid.publicKey,
  vapid.privateKey,
);

let timer: ReturnType<typeof setTimeout> | undefined;
let nextAt: Date | null = null;
let lastActiveAt = 0;
let snoozeUntil = 0;

export const noteActivity = () => {
  lastActiveAt = Date.now();
};
export const snooze = () => {
  snoozeUntil = Date.now() + 60 * 60_000;
  schedule();
};

const subscriptions = () =>
  (
    db.prepare("SELECT endpoint, json FROM push_subscriptions").all() as {
      endpoint: string;
      json: string;
    }[]
  ).map((r) => ({ endpoint: r.endpoint, sub: JSON.parse(r.json) }));

export function subscribe(sub: { endpoint: string }) {
  db.prepare(
    "INSERT INTO push_subscriptions (endpoint, json) VALUES (?, ?) ON CONFLICT(endpoint) DO UPDATE SET json = excluded.json",
  ).run(sub.endpoint, JSON.stringify(sub));
  schedule();
}
export function unsubscribe(endpoint: string) {
  db.prepare("DELETE FROM push_subscriptions WHERE endpoint = ?").run(endpoint);
}

function sentToday() {
  const start = new Date();
  start.setHours(0, 0, 0, 0);
  return db
    .prepare(
      "SELECT ts FROM notifications WHERE kind IN ('reminder', 'skipped') AND ts >= ? ORDER BY ts",
    )
    .all(start.toISOString()) as { ts: string }[];
}

// only the production server sends, so `npm run dev` alongside it never doubles reminders
const SENDS =
  process.env.NODE_ENV === "production" || process.env.REMINDERS === "1";

export function schedule() {
  clearTimeout(timer);
  nextAt = null;
  const s = getSettings();
  if (!SENDS || !s.reminders || !subscriptions().length) return;
  const now = new Date();
  const sent = sentToday();
  const m = me();
  const dow = (now.getDay() + 6) % 7; // Mon = 0
  const plannedDay = s.plannedDays.includes(dow);
  const short = DAYS_PER_WEEK - m.thisWeek.filter((d) => d.qualifies).length;
  let t = nextReminderAt({
    now,
    window: s.window,
    plannedDay,
    // an unplanned day still gets nudges while the week can reach its target
    catchUp: !plannedDay && short > 0 && short <= 7 - dow,
    todayDone: m.today.done,
    sentToday: sent.length,
    lastSentAt: sent.length ? new Date(sent[sent.length - 1].ts) : null,
  });
  if (t && t.getTime() < snoozeUntil) t = new Date(snoozeUntil);
  if (!t) {
    const tomorrow = new Date(now);
    tomorrow.setHours(24, 1, 0, 0);
    timer = setTimeout(schedule, tomorrow.getTime() - now.getTime());
    return;
  }
  nextAt = t;
  timer = setTimeout(() => fire(t), t.getTime() - now.getTime());
}

async function fire(due: Date) {
  const late = Date.now() - due.getTime() > STALE_MS;
  const busy = Date.now() - lastActiveAt < ACTIVE_GRACE_MS;
  if (!late && !busy) await send("reminder", copy());
  // being in the app counts as "reminded": wait a full gap before the next one
  if (busy)
    db.prepare(
      "INSERT INTO notifications (ts, kind, title, body) VALUES (?, 'skipped', '', '')",
    ).run(nowIso());
  schedule();
}

function copy() {
  const m = me();
  const done = Math.floor(m.today.seconds / 60);
  const goal = m.today.goal / 60;
  const s = getSettings();
  const [h, mm] = s.window.end.split(":").map(Number);
  const end = new Date();
  end.setHours(h, mm, 0, 0);
  const leftMin = (end.getTime() - Date.now()) / 60_000;
  const next = nextAction();
  if (leftMin < 75)
    return {
      title: "Last call",
      body: "A 10-minute review sprint still saves the day.",
      url: "/review",
    };
  if (leftMin < 150)
    return {
      title: `${Math.floor(leftMin / 60)} hrs left today`,
      body: `${done}/${goal} min so far. The weekly streak needs today.`,
      url: next.href,
    };
  if (done > 0)
    return {
      title: `${done}/${goal} min`,
      body: `${goal - done} to go. Next up: ${next.title}.`,
      url: next.href,
    };
  return {
    title: `${next.title} is waiting`,
    body: `${goal} focused minutes today?${m.reviewsDue ? ` ${m.reviewsDue} reviews are due.` : ""}`,
    url: next.href,
  };
}

export async function send(
  kind: string,
  msg: { title: string; body: string; url: string },
) {
  db.prepare(
    "INSERT INTO notifications (ts, kind, title, body) VALUES (?, ?, ?, ?)",
  ).run(nowIso(), kind, msg.title, msg.body);
  await Promise.all(
    subscriptions().map(({ endpoint, sub }) =>
      webpush.sendNotification(sub, JSON.stringify(msg)).catch((e) => {
        if (e.statusCode === 404 || e.statusCode === 410) unsubscribe(endpoint);
        else console.error("push failed:", e.statusCode ?? e.message);
      }),
    ),
  );
}

export const notifyStatus = () => ({
  publicKey: vapid.publicKey,
  subscriptions: subscriptions().length,
  nextAt: nextAt?.toISOString() ?? null,
});

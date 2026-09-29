import { db } from "./db.ts";
import type { Settings } from "../shared/types.ts";

const DEFAULTS: Settings = {
  username: "akdevv",
  plannedDays: [0, 1, 2, 3, 4],
  window: { start: "10:00", end: "23:00" },
  reminders: true,
};

export function getSettings(): Settings {
  const rows = db.prepare("SELECT key, value FROM settings").all() as {
    key: string;
    value: string;
  }[];
  const saved = Object.fromEntries(
    rows
      .filter((r) => r.key in DEFAULTS) // ignore keys of removed features
      .map((r) => [r.key, JSON.parse(r.value)]),
  );
  return { ...DEFAULTS, ...saved };
}

export function saveSettings(patch: Partial<Settings>) {
  const put = db.prepare(
    "INSERT INTO settings (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value",
  );
  for (const [k, v] of Object.entries(patch))
    if (k in DEFAULTS) put.run(k, JSON.stringify(v));
  return getSettings();
}

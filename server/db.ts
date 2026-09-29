import { DatabaseSync } from "node:sqlite";
import { mkdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

export const ROOT = join(import.meta.dirname, "..");
mkdirSync(join(ROOT, "data"), { recursive: true });

export const db = new DatabaseSync(
  process.env.DB_PATH ?? join(ROOT, "data", "learn.db"),
);
db.exec("PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;");
db.exec(readFileSync(join(import.meta.dirname, "schema.sql"), "utf8"));

export const nowIso = () => new Date().toISOString();

/** An error the API returns as `{ error: message }` with this status. */
export const fail = (message: string, status = 400) =>
  Object.assign(new Error(message), { status });

export function addXp(amount: number, reason: string, ref?: string) {
  if (amount > 0)
    db.prepare(
      "INSERT INTO xp_events (ts, amount, reason, ref) VALUES (?, ?, ?, ?)",
    ).run(nowIso(), amount, reason, ref ?? null);
  return amount;
}

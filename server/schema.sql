-- Progress keyed by content slugs (topic / problem ids), so content can be reordered or extended freely.

CREATE TABLE IF NOT EXISTS activity (
  date    TEXT PRIMARY KEY,          -- local YYYY-MM-DD
  seconds INTEGER NOT NULL DEFAULT 0 -- active (focused + in use) seconds
);

CREATE TABLE IF NOT EXISTS attempts (
  id              INTEGER PRIMARY KEY,
  problem_id      TEXT NOT NULL,
  started_at      TEXT NOT NULL,
  finished_at     TEXT,
  active_seconds  INTEGER NOT NULL DEFAULT 0,
  hints_used      INTEGER NOT NULL DEFAULT 0,
  solution_viewed INTEGER NOT NULL DEFAULT 0,
  approach        TEXT NOT NULL DEFAULT '',
  code            TEXT,
  outcome         TEXT,              -- solved | hinted | assisted
  explain         TEXT
);
CREATE INDEX IF NOT EXISTS attempts_problem ON attempts(problem_id);

CREATE TABLE IF NOT EXISTS submissions (
  id         INTEGER PRIMARY KEY,
  attempt_id INTEGER NOT NULL REFERENCES attempts(id),
  ts         TEXT NOT NULL,
  kind       TEXT NOT NULL,          -- run | submit
  verdict    TEXT NOT NULL,
  passed     INTEGER NOT NULL,
  total      INTEGER NOT NULL,
  code       TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS topic_progress (
  topic_id       TEXT PRIMARY KEY,
  lesson_done_at TEXT,
  quiz_best      REAL,               -- best score 0..1
  explain        TEXT,
  explain_at     TEXT
);

CREATE TABLE IF NOT EXISTS reviews (
  item_type    TEXT NOT NULL,        -- problem | topic
  item_id      TEXT NOT NULL,
  interval_idx INTEGER NOT NULL,
  due          TEXT NOT NULL,        -- local YYYY-MM-DD
  last_result  TEXT,
  PRIMARY KEY (item_type, item_id)
);

CREATE TABLE IF NOT EXISTS xp_events (
  id     INTEGER PRIMARY KEY,
  ts     TEXT NOT NULL,
  amount INTEGER NOT NULL,
  reason TEXT NOT NULL,
  ref    TEXT
);

CREATE TABLE IF NOT EXISTS settings (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL                -- JSON
);

CREATE TABLE IF NOT EXISTS grades (   -- AI explain-back grades
  id     INTEGER PRIMARY KEY,
  kind   TEXT NOT NULL,              -- topic | problem | boss
  ref    TEXT NOT NULL,              -- topic / problem / module id
  ts     TEXT NOT NULL,
  score  INTEGER NOT NULL,           -- 0..5
  json   TEXT NOT NULL               -- full Grade
);
CREATE INDEX IF NOT EXISTS grades_ref ON grades(kind, ref);

CREATE TABLE IF NOT EXISTS reward_claims (  -- real-world rewards marked as availed
  id         TEXT PRIMARY KEY,         -- reward id from REWARD_PATH in rewards.ts
  claimed_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS boss_runs (
  id          INTEGER PRIMARY KEY,
  module_id   TEXT NOT NULL,
  problem_id  TEXT NOT NULL,
  attempt_id  INTEGER NOT NULL REFERENCES attempts(id),
  started_at  TEXT NOT NULL,
  limit_s     INTEGER NOT NULL,
  solved_at   TEXT,                  -- first Accepted submit
  finished_at TEXT,                  -- explained (or abandoned)
  score       INTEGER,
  passed      INTEGER
);

CREATE TABLE IF NOT EXISTS push_subscriptions (
  endpoint TEXT PRIMARY KEY,
  json     TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS notifications (  -- sent reminders, for the daily cap and tuning
  id    INTEGER PRIMARY KEY,
  ts    TEXT NOT NULL,
  kind  TEXT NOT NULL,
  title TEXT NOT NULL,
  body  TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS tutor_messages (  -- Socratic tutor chat, per attempt
  id         INTEGER PRIMARY KEY,
  attempt_id INTEGER NOT NULL REFERENCES attempts(id),
  ts         TEXT NOT NULL,
  role       TEXT NOT NULL,          -- user | tutor
  text       TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS tutor_attempt ON tutor_messages(attempt_id);

CREATE TABLE IF NOT EXISTS chests (   -- mystery chests, earned by boss wins and clean solves
  id        INTEGER PRIMARY KEY,
  ts        TEXT NOT NULL,
  source    TEXT NOT NULL,           -- boss | solve
  ref       TEXT NOT NULL,           -- module / problem id
  opened_at TEXT,
  reward    TEXT                     -- JSON {kind: xp | freeze | collectible, ...}
);

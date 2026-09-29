// Counts time only on a learning page (topic, problem, boss, review) while the window is visible, focused and in use.

const IDLE_MS = 90_000;
const TICK_MS = 1_000;
const FLUSH_S = 60;

let lastInput = Date.now();
let pending = 0;
let tracked = false;
let holds = 0; // e.g. a playing viz keeps the session active without input
let timer: ReturnType<typeof setInterval> | null = null;
let context: string | undefined;
let serverToday = 0;
const listeners = new Set<() => void>();

const isActive = () =>
  tracked &&
  document.visibilityState === "visible" &&
  document.hasFocus() &&
  (holds > 0 || Date.now() - lastInput < IDLE_MS);

function notify() {
  listeners.forEach((f) => f());
}

async function flush() {
  if (!pending) return;
  const seconds = pending,
    problemId = context;
  pending = 0;
  try {
    const r = await fetch("/api/activity", {
      method: "POST",
      keepalive: true,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ seconds, problemId }),
    });
    serverToday = (await r.json()).seconds;
  } catch {
    pending += seconds; // retry next flush
  }
  notify();
}

function tick() {
  if (!isActive()) {
    stop();
    return;
  }
  pending += TICK_MS / 1000;
  notify();
  if (pending >= FLUSH_S) flush();
}

function start() {
  if (!timer && isActive()) timer = setInterval(tick, TICK_MS);
}
function stop() {
  if (timer) {
    clearInterval(timer);
    timer = null;
  }
  flush();
}

function onInput() {
  lastInput = Date.now();
  if (!timer) start();
}

export function initActivity(todaySeconds: number) {
  serverToday = todaySeconds;
  notify();
  for (const ev of [
    "keydown",
    "mousedown",
    "mousemove",
    "wheel",
    "touchstart",
    "scroll",
  ])
    window.addEventListener(ev, onInput, { passive: true, capture: true });
  window.addEventListener("focus", start);
  window.addEventListener("blur", stop);
  document.addEventListener("visibilitychange", () =>
    document.visibilityState === "visible" ? start() : stop(),
  );
  window.addEventListener("pagehide", stop);
  start();
}

/** Only learning pages count; browsing home, stats, rewards etc. doesn't. */
export function setTracked(on: boolean) {
  if (tracked === on) return;
  tracked = on;
  if (on) start();
  else stop();
}

/** Attribute time to a problem (its attempt's active seconds drive hint unlocks). */
export function setActivityContext(problemId?: string) {
  if (context === problemId) return;
  flush();
  context = problemId;
}

export const flushActivity = flush;
export const holdActive = () => {
  holds++;
  onInput();
  return () => {
    holds--;
  };
};
export const todaySeconds = () => serverToday + pending;
export const pendingSeconds = () => pending;
export const subscribeActivity = (f: () => void) => {
  listeners.add(f);
  return () => {
    listeners.delete(f);
  };
};

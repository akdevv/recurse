import { useCallback, useEffect, useState } from "react";

export async function get<T>(path: string): Promise<T> {
  const r = await fetch(`/api${path}`);
  if (!r.ok) throw new Error(`${r.status} ${path}`);
  return r.json();
}

export const post = <T = any>(path: string, body: unknown = {}) =>
  send<T>("POST", path, body);
export const put = <T = any>(path: string, body: unknown) =>
  send<T>("PUT", path, body);

async function send<T>(
  method: string,
  path: string,
  body: unknown,
): Promise<T> {
  const r = await fetch(`/api${path}`, {
    method,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const data = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(data.error ?? `${r.status} ${path}`);
  return data;
}

export function useApi<T>(path: string | null) {
  const [state, setState] = useState<{ path: string | null; data: T | null }>({
    path: null,
    data: null,
  });
  const reload = useCallback(
    () =>
      path
        ? get<T>(path).then((data) => setState({ path, data }))
        : Promise.resolve(),
    [path],
  );
  useEffect(() => {
    reload();
  }, [reload]);
  // stale data from the previous path is never shown
  const data = state.path === path ? state.data : null;
  return [data, reload] as const;
}

const bus = new EventTarget();
export const emitRefresh = () => bus.dispatchEvent(new Event("refresh"));
export const onRefresh = (fn: () => void) => {
  bus.addEventListener("refresh", fn);
  return () => bus.removeEventListener("refresh", fn);
};
export const toast = (msg: string) =>
  bus.dispatchEvent(new CustomEvent("toast", { detail: msg }));
export const onToast = (fn: (msg: string) => void) => {
  const h = (e: Event) => fn((e as CustomEvent).detail);
  bus.addEventListener("toast", h);
  return () => bus.removeEventListener("toast", h);
};
/** After any action that can earn XP: toast the gain, refresh XP/streak displays. */
export const xpToast = (xp: number | undefined) => {
  if (xp) toast(`+${xp} XP`);
  emitRefresh();
};

// a mystery chest was just earned: the root layout shows the opening dialog
export const emitChest = (chest: { id: number } | null | undefined) => {
  if (chest) bus.dispatchEvent(new CustomEvent("chest", { detail: chest.id }));
};
export const onChest = (fn: (id: number) => void) => {
  const h = (e: Event) => fn((e as CustomEvent).detail);
  bus.addEventListener("chest", h);
  return () => bus.removeEventListener("chest", h);
};

export const fmtClock = (s: number) =>
  `${Math.floor(s / 60)}:${String(Math.floor(s % 60)).padStart(2, "0")}`;

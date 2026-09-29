import { useSyncExternalStore } from "react";

/** A tiny global value with a hook; `persistKey` keeps it in localStorage. */
export function store<T>(initial: T, persistKey?: string) {
  let value = initial;
  if (persistKey) {
    try {
      const saved = localStorage.getItem(persistKey);
      if (saved !== null) value = JSON.parse(saved);
    } catch {
      /* storage unavailable: keep default */
    }
  }
  const listeners = new Set<() => void>();
  const subscribe = (f: () => void) => {
    listeners.add(f);
    return () => listeners.delete(f);
  };
  const set = (next: T) => {
    value = next;
    if (persistKey) {
      try {
        localStorage.setItem(persistKey, JSON.stringify(next));
      } catch {
        /* ignore */
      }
    }
    listeners.forEach((f) => f());
  };
  const use = () => useSyncExternalStore(subscribe, () => value);
  return { get: () => value, set, use };
}

export const sidebarCollapsed = store(false, "sidebar-collapsed");
export const paletteOpen = store(false);

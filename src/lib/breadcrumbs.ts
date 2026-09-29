import { useEffect } from "react";
import { store } from "@/lib/ui-state.ts";

export type Crumb = { label: string; to?: string };

const crumbs = store<Crumb[] | null>(null);
export const useCrumbs = crumbs.use;

/** Pages with dynamic titles (topic, module) set their own trail; others fall back to the route name. */
export function useBreadcrumbs(trail: Crumb[] | null) {
  const key = trail ? JSON.stringify(trail) : null;
  useEffect(() => {
    crumbs.set(key ? JSON.parse(key) : null);
    return () => crumbs.set(null);
  }, [key]);
}

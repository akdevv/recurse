import type { IconType } from "react-icons";
import {
  LuChartNoAxesColumn,
  LuGift,
  LuHouse,
  LuListChecks,
  LuMap,
  LuRotateCcw,
  LuSettings,
  LuShapes,
} from "react-icons/lu";

export type NavItem = {
  to: string;
  label: string;
  icon: IconType;
  end?: boolean;
};

export const NAV_GROUPS: { label: string; items: NavItem[] }[] = [
  {
    label: "Learn",
    items: [
      { to: "/", label: "Home", icon: LuHouse, end: true },
      { to: "/course", label: "Course", icon: LuMap },
      { to: "/review", label: "Review", icon: LuRotateCcw },
    ],
  },
  {
    label: "Practice",
    items: [
      { to: "/problems", label: "Problems", icon: LuListChecks },
      { to: "/patterns", label: "Patterns", icon: LuShapes },
    ],
  },
  {
    label: "Progress",
    items: [
      { to: "/stats", label: "Stats", icon: LuChartNoAxesColumn },
      { to: "/rewards", label: "Rewards", icon: LuGift },
    ],
  },
];

export const SETTINGS: NavItem = {
  to: "/settings",
  label: "Settings",
  icon: LuSettings,
};

export const ALL_PAGES = [...NAV_GROUPS.flatMap((g) => g.items), SETTINGS];

/** The top-level page a path belongs to (/course/<module>/<topic> belongs to Course). */
export function sectionOf(pathname: string): NavItem | undefined {
  const first = "/" + (pathname.split("/")[1] ?? "");
  return ALL_PAGES.find((p) => p.to === first);
}

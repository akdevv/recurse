import { useEffect, useState } from "react";
import { Outlet, useLocation } from "react-router";
import { get, onToast } from "@/lib/api.ts";
import { initActivity, setTracked } from "@/lib/activity.ts";
import CommandPalette from "@/components/common/command-palette.tsx";
import { ChestHost } from "@/components/rewards/chest.tsx";
import type { Me } from "@shared/types.ts";

let activityStarted = false;
const LEARNING =
  /^\/(course\/[^/]+\/[^/]+|problems\/[^/]+|boss\/[^/]+|review)\/?$/;

export default function RootLayout() {
  const [toasts, setToasts] = useState<{ id: number; msg: string }[]>([]);
  const { pathname } = useLocation();

  useEffect(() => setTracked(LEARNING.test(pathname)), [pathname]);

  useEffect(() => {
    if (activityStarted) return;
    activityStarted = true;
    get<Me>("/me").then((m) => initActivity(m.today.seconds));
  }, []);

  useEffect(
    () =>
      onToast((msg) => {
        const id = Date.now() + Math.random();
        setToasts((t) => [...t, { id, msg }]);
        setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 2500);
      }),
    [],
  );

  return (
    <>
      <Outlet />
      <CommandPalette />
      <ChestHost />
      <div className="fixed right-4 bottom-4 z-50 flex flex-col gap-2">
        {toasts.map((t) => (
          <div
            key={t.id}
            className="rounded-lg border border-border bg-popover px-4 py-2.5 text-sm font-medium text-popover-foreground shadow-lg"
          >
            {t.msg}
          </div>
        ))}
      </div>
    </>
  );
}

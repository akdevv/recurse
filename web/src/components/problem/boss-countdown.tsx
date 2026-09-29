import { useEffect, useState } from "react";
import { LuSwords } from "react-icons/lu";
import { fmtClock } from "@/lib/api.ts";

/** Wall-clock countdown: an interview doesn't pause when you look away. */
export default function BossCountdown({ deadline }: { deadline: string }) {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(t);
  }, []);
  const left = Math.max(0, (Date.parse(deadline) - now) / 1000);
  const tone =
    left === 0
      ? "bg-destructive/15 text-destructive ring-destructive/30"
      : left < 300
        ? "bg-destructive/10 text-destructive ring-destructive/20"
        : "bg-warning/10 text-warning ring-warning/20";
  return (
    <span
      title="Boss fight: time left"
      className={`flex h-7 items-center gap-1.5 rounded-full px-2.5 text-xs font-medium ring-1 ring-inset ${tone}`}
    >
      <LuSwords className="size-3.5" />
      <span className="font-mono tabular-nums">
        {left === 0 ? "Time's up" : fmtClock(left)}
      </span>
    </span>
  );
}

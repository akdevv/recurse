import { LuCircle, LuCircleCheck, LuCircleDashed } from "react-icons/lu";

import type { Progress } from "@/lib/progress.ts";

export default function StatusIcon({
  status,
  className = "size-3.5",
}: {
  status: Progress;
  className?: string;
}) {
  if (status === "done")
    return <LuCircleCheck className={`shrink-0 text-success ${className}`} />;
  if (status === "started")
    return <LuCircleDashed className={`shrink-0 text-primary ${className}`} />;
  return (
    <LuCircle className={`shrink-0 text-muted-foreground/40 ${className}`} />
  );
}

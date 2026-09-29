import type { ReactNode } from "react";
import type { IconType } from "react-icons";

const TONES = {
  primary: "bg-primary/10 text-primary ring-primary/20",
  success: "bg-success/10 text-success ring-success/20",
  warning: "bg-warning/10 text-warning ring-warning/20",
};

export default function StatCell({
  icon: Icon,
  label,
  tone,
  children,
}: {
  icon: IconType;
  label: string;
  tone: keyof typeof TONES;
  children: ReactNode;
}) {
  return (
    <div className="flex h-full flex-col gap-3 px-5 py-4">
      <div className="flex items-center gap-2.5">
        <span
          className={`grid size-7 place-items-center rounded-md ring-1 ring-inset ${TONES[tone]}`}
        >
          <Icon className="size-3.5" />
        </span>
        <span className="text-xs font-medium text-muted-foreground">
          {label}
        </span>
      </div>
      {children}
    </div>
  );
}

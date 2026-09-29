import type { ReactNode } from "react";
import type { IconType } from "react-icons";

export function Pane({
  className = "",
  children,
}: {
  className?: string;
  children: ReactNode;
}) {
  return (
    <section
      className={`flex min-h-0 flex-col overflow-hidden rounded-lg border border-border bg-card ${className}`}
    >
      {children}
    </section>
  );
}

export function PaneHeader({ children }: { children: ReactNode }) {
  return (
    <div className="flex h-10 shrink-0 items-center gap-1 border-b border-border px-1.5">
      {children}
    </div>
  );
}

export function Tab({
  icon: Icon,
  active = true,
  onClick,
  children,
}: {
  icon: IconType;
  active?: boolean;
  onClick?: () => void;
  children: ReactNode;
}) {
  const cls = `flex h-7 items-center gap-1.5 rounded-md px-2.5 text-xs font-medium transition-colors ${
    active
      ? "bg-accent text-foreground"
      : "text-muted-foreground hover:bg-accent/50 hover:text-foreground"
  }`;
  const body = (
    <>
      <Icon className={`size-3.5 ${active ? "text-primary" : ""}`} />
      {children}
    </>
  );
  return onClick ? (
    <button onClick={onClick} className={cls}>
      {body}
    </button>
  ) : (
    <span className={cls}>{body}</span>
  );
}

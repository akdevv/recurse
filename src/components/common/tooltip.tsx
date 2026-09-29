import { useState, type ReactElement, type ReactNode } from "react";
import { createPortal } from "react-dom";

/** Right-side tooltip rendered in a portal, so overflow-hidden parents (the collapsed sidebar) can't clip it. */
export default function Tooltip({
  label,
  enabled = true,
  children,
}: {
  label: ReactNode;
  enabled?: boolean;
  children: ReactElement;
}) {
  const [pos, setPos] = useState<{ x: number; y: number } | null>(null);
  if (!enabled) return children;

  const show = (el: HTMLElement) => {
    const r = el.getBoundingClientRect();
    const edge = el.closest("aside")?.getBoundingClientRect().right ?? r.right;
    setPos({ x: edge + 8, y: r.top + r.height / 2 });
  };

  return (
    <div
      onMouseEnter={(e) => show(e.currentTarget)}
      onMouseLeave={() => setPos(null)}
      onFocus={(e) => show(e.currentTarget)}
      onBlur={() => setPos(null)}
    >
      {children}
      {pos &&
        createPortal(
          <div
            role="tooltip"
            style={{ left: pos.x, top: pos.y }}
            className="pointer-events-none fixed z-50 -translate-y-1/2 rounded-md border border-border bg-popover px-2 py-1 text-xs font-medium whitespace-nowrap text-popover-foreground shadow-lg shadow-black/30"
          >
            {label}
          </div>,
          document.body,
        )}
    </div>
  );
}

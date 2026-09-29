export default function ProgressBar({
  pct,
  className = "",
}: {
  pct: number;
  className?: string;
}) {
  return (
    <div
      className={`h-1 overflow-hidden rounded-full bg-secondary ${className}`}
    >
      <div
        className={`h-full rounded-full ${pct >= 1 ? "bg-success" : "bg-primary"}`}
        style={{ width: `${Math.min(1, pct) * 100}%` }}
      />
    </div>
  );
}

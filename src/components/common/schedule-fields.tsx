const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const input =
  "h-9 rounded-md border border-border bg-background/40 px-3 text-sm outline-none focus:border-ring/60";

export function DayPicker({
  value,
  onChange,
}: {
  value: number[];
  onChange: (v: number[]) => void;
}) {
  return (
    <div className="flex gap-1">
      {DAYS.map((d, i) => {
        const on = value.includes(i);
        return (
          <button
            key={d}
            onClick={() =>
              onChange(on ? value.filter((x) => x !== i) : [...value, i].sort())
            }
            aria-pressed={on}
            className={`h-8 w-11 rounded-md text-xs font-medium transition-colors ${
              on
                ? "bg-primary/15 text-primary ring-1 ring-primary/30 ring-inset"
                : "bg-secondary text-muted-foreground hover:text-foreground"
            }`}
          >
            {d}
          </button>
        );
      })}
    </div>
  );
}

export function WindowPicker({
  value,
  onChange,
}: {
  value: { start: string; end: string };
  onChange: (v: { start: string; end: string }) => void;
}) {
  return (
    <div className="flex items-center gap-2 text-sm text-muted-foreground">
      <input
        type="time"
        value={value.start}
        onChange={(e) => onChange({ ...value, start: e.target.value })}
        className={input}
      />
      to
      <input
        type="time"
        value={value.end}
        onChange={(e) => onChange({ ...value, end: e.target.value })}
        className={input}
      />
    </div>
  );
}

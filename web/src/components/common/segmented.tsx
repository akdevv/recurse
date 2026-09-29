const SIZES = {
  sm: { box: "h-7", item: "text-[11px]" },
  md: { box: "h-8 bg-card", item: "text-xs" },
};

export default function Segmented<T extends string>({
  value,
  onChange,
  options,
  size = "md",
}: {
  value: T;
  onChange: (v: T) => void;
  options: { id: T; label: string }[];
  size?: keyof typeof SIZES;
}) {
  return (
    <div
      className={`flex items-center rounded-md border border-border p-0.5 ${SIZES[size].box}`}
    >
      {options.map((o) => (
        <button
          key={o.id}
          onClick={() => onChange(o.id)}
          aria-pressed={value === o.id}
          className={`h-full rounded px-2.5 font-medium transition-colors ${SIZES[size].item} ${
            value === o.id
              ? "bg-accent text-foreground"
              : "text-muted-foreground hover:text-foreground"
          }`}
        >
          {o.label}
        </button>
      ))}
    </div>
  );
}

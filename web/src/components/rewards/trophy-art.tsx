import { useId } from "react";

export type Metal = "bronze" | "silver" | "gold" | "jade" | "locked";

// rim light → rim dark, face light → face dark, ribbon
const METALS: Record<Metal, [string, string, string, string, string]> = {
  bronze: ["#f0b98a", "#7a3f1c", "#c98652", "#6b3818", "#8a4b2a"],
  silver: ["#f6f8fa", "#7b858c", "#d3d9dd", "#6d767d", "#5b6a74"],
  gold: ["#ffe7a3", "#9a5f10", "#f5c451", "#a86c14", "#b0741a"],
  jade: ["#a6f5e7", "#15685c", "#4fcab8", "#17695d", "#1f7a6d"],
  locked: ["#3b4449", "#1a1f22", "#293034", "#181d20", "#22292d"],
};

const star = (cx: number, cy: number, R: number, r: number) =>
  Array.from({ length: 10 }, (_, i) => {
    const a = (Math.PI / 5) * i - Math.PI / 2;
    const d = i % 2 ? r : R;
    return `${i ? "L" : "M"}${(cx + d * Math.cos(a)).toFixed(1)} ${(cy + d * Math.sin(a)).toFixed(1)}`;
  }).join(" ") + " Z";

// emblems drawn on a 96×96 canvas, centred on the medal face at (48, 44)
const GLYPHS: Record<string, string> = {
  check: "M37 44.5 L44.5 52 L59 36.5",
  code: "M40 36 L32 44 L40 52 M56 36 L64 44 L56 52 M51.5 33 L44.5 55",
  bulb: "M48 30.5 A9.5 9.5 0 0 1 53.5 47.8 V51 H42.5 V47.8 A9.5 9.5 0 0 1 48 30.5 Z M44 55.5 H52",
  bolt: "M51.5 30 L39 46.5 H48.5 L45 58.5 L58 41.5 H48.5 Z",
  speech:
    "M35 37 A4 4 0 0 1 39 33 H57 A4 4 0 0 1 61 37 V47 A4 4 0 0 1 57 51 H46 L39.5 56 V51 H39 A4 4 0 0 1 35 47 Z M41 39 H55 M41 45 H50",
  star: star(48, 44, 13.5, 5.8),
  target:
    "M48 31 A13 13 0 1 1 47.9 31 Z M48 37 A7 7 0 1 1 47.9 37 Z M48 42.5 A1.5 1.5 0 1 1 47.9 42.5 Z",
  cards:
    "M40 34 H57 A2 2 0 0 1 59 36 V55 A2 2 0 0 1 57 57 H40 A2 2 0 0 1 38 55 V36 A2 2 0 0 1 40 34 Z M34 51 V32 A2 2 0 0 1 36 30 H52 M43 41 H54 M43 46 H51",
  calendar:
    "M36 34 H60 A2 2 0 0 1 62 36 V56 A2 2 0 0 1 60 58 H36 A2 2 0 0 1 34 56 V36 A2 2 0 0 1 36 34 Z M34 40.5 H62 M41 30.5 V35 M55 30.5 V35 M39.5 46 H40.5 M45.5 46 H46.5 M51.5 46 H52.5 M57.5 46 H56.5 M39.5 52 H40.5",
  hourglass:
    "M38 31 H58 M38 57 H58 M40.5 31 C40.5 40 55.5 40 55.5 44 C55.5 48 40.5 48 40.5 57 M55.5 31 C55.5 40 40.5 40 40.5 44 C40.5 48 55.5 48 55.5 57 M44 54 H52",
  rebound: "M58.5 45 A10.5 10.5 0 1 1 54.5 36 M56 29.5 V37 H48.5",
  swords:
    "M36 32 L58 54 M60 32 L38 54 M53 57 L60 50 M36 50 L43 57 M34 30 L38 30 L38 34 M62 30 L58 30 L58 34",
  mountain: "M33 55 L44 37 L50 46 L54 40 L63 55 Z M41.5 41 L44 43.5 L46.5 41",
  book: "M48 36 C44 33 39 33 35 34.5 V55 C39 53.5 44 53.5 48 56 C52 53.5 57 53.5 61 55 V34.5 C57 33 52 33 48 36 Z M48 36 V56",
  laurel:
    "M40 32 H56 V38 A8 8 0 0 1 40 38 Z M40 34.5 H36.5 A3.5 3.5 0 0 0 40 41 M56 34.5 H59.5 A3.5 3.5 0 0 1 56 41 M48 46 V51 M43 57 H53 M45 51 H51 V57 H45 Z",
};

export default function TrophyArt({
  art,
  metal,
  size = 80,
}: {
  art: string;
  metal: Metal;
  size?: number;
}) {
  const id = useId().replace(/:/g, "");
  const [rimA, rimB, faceA, faceB, ribbon] = METALS[metal];
  const locked = metal === "locked";
  const glyph = GLYPHS[art] ?? GLYPHS.check;
  const filled = art === "bolt" || art === "star";

  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 96 96"
      aria-hidden
      className={locked ? "" : "drop-shadow-[0_6px_14px_rgba(0,0,0,0.45)]"}
    >
      <defs>
        <linearGradient id={`rim${id}`} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor={rimA} />
          <stop offset="1" stopColor={rimB} />
        </linearGradient>
        <linearGradient id={`face${id}`} x1="0.2" y1="0" x2="0.8" y2="1">
          <stop offset="0" stopColor={faceA} />
          <stop offset="1" stopColor={faceB} />
        </linearGradient>
        <linearGradient id={`shine${id}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#fff" stopOpacity="0.35" />
          <stop offset="0.5" stopColor="#fff" stopOpacity="0" />
        </linearGradient>
      </defs>

      {/* ribbon tails */}
      <path d="M36 62 L30 88 L37.5 83 L42 90 L46 66 Z" fill={ribbon} />
      <path d="M60 62 L66 88 L58.5 83 L54 90 L50 66 Z" fill={ribbon} />
      <path
        d="M36 62 L30 88 L37.5 83 L42 90 L46 66 Z M60 62 L66 88 L58.5 83 L54 90 L50 66 Z"
        fill="#000"
        opacity="0.18"
      />

      {/* medal */}
      <circle cx="48" cy="44" r="30" fill={`url(#rim${id})`} />
      <circle
        cx="48"
        cy="44"
        r="27"
        fill="none"
        stroke="#000"
        strokeOpacity="0.25"
        strokeWidth="1"
        strokeDasharray="1.2 2.6"
      />
      <circle cx="48" cy="44" r="24" fill={`url(#face${id})`} />
      <circle
        cx="48"
        cy="44"
        r="24"
        fill="none"
        stroke="#000"
        strokeOpacity="0.28"
        strokeWidth="1.5"
      />
      <ellipse cx="48" cy="32" rx="20" ry="11" fill={`url(#shine${id})`} />

      {/* engraved emblem: light edge below, dark cut on top */}
      <g
        fill={filled ? "currentColor" : "none"}
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth="3.4"
      >
        <path
          d={glyph}
          transform="translate(0 1)"
          stroke="#fff"
          strokeOpacity={locked ? 0.04 : 0.35}
          fill={filled ? "#fff" : "none"}
          fillOpacity={locked ? 0.04 : 0.3}
        />
        <path
          d={glyph}
          stroke={locked ? "#11161a" : "#000"}
          strokeOpacity={locked ? 0.9 : 0.5}
          fill={filled ? (locked ? "#11161a" : "#000") : "none"}
          fillOpacity={filled ? (locked ? 0.9 : 0.42) : 0}
        />
      </g>
    </svg>
  );
}

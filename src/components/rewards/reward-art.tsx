// Flat illustrations for real-world rewards, drawn on a 64×64 canvas.
const CREAM = "#f3ece0";
const CREAM_D = "#d9cdb8";
const TEAL = "#3fbfae";
const TEAL_D = "#2a8c7f";
const CORAL = "#e07a5f";
const CORAL_D = "#b85d45";
const GOLD = "#f2c14e";
const GOLD_D = "#c9951f";
const INK = "#2b3a4a";

const ART: Record<string, React.ReactNode> = {
  coffee: (
    <>
      <path
        d="M24 19 c-2.5 -3 2.5 -5 0 -8.5 M31 18 c-2.5 -3 2.5 -5 0 -8.5 M38 19 c-2.5 -3 2.5 -5 0 -8.5"
        stroke="#cfd6dc"
        strokeOpacity="0.55"
        strokeWidth="2"
        strokeLinecap="round"
        fill="none"
      />
      <ellipse cx="31" cy="52" rx="21" ry="4.5" fill={CREAM_D} />
      <ellipse cx="31" cy="51.5" rx="13" ry="2.4" fill="#c4b69d" />
      <path
        d="M46 29 h1.5 a6 6 0 0 1 0 12 H45"
        stroke={CREAM}
        strokeWidth="3.5"
        fill="none"
        strokeLinecap="round"
      />
      <path
        d="M15 25 H47 V37 A12.5 12.5 0 0 1 34.5 49.5 H27.5 A12.5 12.5 0 0 1 15 37 Z"
        fill={CREAM}
      />
      <path
        d="M39 25 H47 V37 A12.5 12.5 0 0 1 36 49.4 C40 45 39 34 39 25 Z"
        fill={CREAM_D}
        opacity="0.6"
      />
      <ellipse cx="31" cy="25.5" rx="16" ry="3.2" fill="#6b3f24" />
      <ellipse cx="28" cy="25" rx="7" ry="1.1" fill="#9a6440" />
    </>
  ),
  meal: (
    <>
      <path
        d="M42 6 L27 33 M49 9 L32 33"
        stroke="#c98652"
        strokeWidth="2.6"
        strokeLinecap="round"
      />
      <path d="M13 32 C17 23 47 23 51 32 Z" fill="#f2d38a" />
      <path
        d="M19 30 c3 -3 5 1 8 -2 s5 1 8 -2 s5 1 8 -2"
        stroke="#d9ac4c"
        strokeWidth="1.6"
        fill="none"
        strokeLinecap="round"
      />
      <circle cx="24" cy="27" r="2" fill="#7fc8a9" />
      <circle cx="41" cy="28" r="1.7" fill="#7fc8a9" />
      <path
        d="M9 32 H55 C55 44.5 44.7 52 32 52 C19.3 52 9 44.5 9 32 Z"
        fill={CORAL}
      />
      <path
        d="M41 32 H55 C55 44.5 44.7 52 32 52 C42 48 44 38 41 32 Z"
        fill={CORAL_D}
        opacity="0.55"
      />
      <path d="M12.5 38 H51.5" stroke="#f4a58a" strokeWidth="2" />
      <path d="M24 51 H40 L38 56 H26 Z" fill={CORAL_D} />
    </>
  ),
  shirt: (
    <>
      <path
        d="M22 11 L13 15.5 L5 26 L13.5 32 L18 28.5 V55 H46 V28.5 L50.5 32 L59 26 L51 15.5 L42 11 C40 16.5 36.5 19 32 19 C27.5 19 24 16.5 22 11 Z"
        fill={TEAL}
      />
      <path
        d="M40 18 C44 24 46 40 46 55 H38 C41 45 42 30 40 18 Z"
        fill={TEAL_D}
        opacity="0.45"
      />
      <path
        d="M22 11 C24 16.5 27.5 19 32 19 C36.5 19 40 16.5 42 11"
        stroke={TEAL_D}
        strokeWidth="2.6"
        fill="none"
        strokeLinecap="round"
      />
      <path
        d="M29.5 29 c-1.3 0 -1.3 .8 -1.3 2 v1 c0 .7 -.5 1 -1.1 1 c.6 0 1.1 .3 1.1 1 v1 c0 1.2 0 2 1.3 2 M34.5 29 c1.3 0 1.3 .8 1.3 2 v1 c0 .7 .5 1 1.1 1 c-.6 0 -1.1 .3 -1.1 1 v1 c0 1.2 0 2 -1.3 2"
        stroke="#e9fffb"
        strokeWidth="1.5"
        fill="none"
        strokeLinecap="round"
        opacity="0.9"
      />
    </>
  ),
  movie: (
    <>
      <circle cx="20" cy="24" r="6" fill="#fff6de" />
      <circle cx="28" cy="19" r="7" fill="#fff6de" />
      <circle cx="37" cy="20" r="6.5" fill="#fff6de" />
      <circle cx="44.5" cy="24.5" r="5.5" fill="#fff6de" />
      <circle cx="31.5" cy="25" r="5" fill="#fbe7b3" />
      <circle cx="24" cy="18" r="2" fill="#f2d38a" opacity="0.8" />
      <circle cx="40" cy="16.5" r="1.8" fill="#f2d38a" opacity="0.8" />
      <path d="M15 27 H49 L44.5 57 H19.5 Z" fill={CREAM} />
      <path
        d="M19 27 H24.5 L25.5 57 H21.8 Z M29.5 27 H34.5 L34 57 H30 Z M39.5 27 H45 L42.2 57 H38.5 Z"
        fill="#e05a4f"
      />
      <rect x="13.5" y="25" width="37" height="4" rx="1.5" fill="#c9433a" />
    </>
  ),
  shoes: (
    <>
      <path
        d="M5.5 43 H57 C59 43 59 50 57 50 H8 C5.5 50 4.5 46 5.5 43 Z"
        fill={CREAM}
      />
      <path d="M8 47 H57" stroke={CREAM_D} strokeWidth="1.5" />
      <path
        d="M7 43 C7 34 11 29 17 27.5 L27.5 22.5 C30.5 28.5 37.5 31 44 33 C52 35.5 57 38.5 57 43 Z"
        fill={CORAL}
      />
      <path
        d="M7 43 C7 38 8.5 34 11 31.5 C13 36 13 40 12 43 Z"
        fill={CORAL_D}
      />
      <path
        d="M19 39.5 C28 35 40 36.5 51 40"
        stroke="#fff6de"
        strokeWidth="3"
        fill="none"
        strokeLinecap="round"
      />
      <path
        d="M25 27 l3 3 M29 25.5 l3 3 M33 27.5 l3 3"
        stroke="#fff6de"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </>
  ),
  book: (
    <>
      <path d="M20 50 H49 V56 H20 Z" fill={CREAM} />
      <path d="M20 52 H49 M20 54 H49" stroke={CREAM_D} strokeWidth="0.8" />
      <rect x="14" y="8" width="35" height="44" rx="3" fill="#8e3b46" />
      <rect x="14" y="8" width="7" height="44" rx="2.5" fill="#6e2a34" />
      <rect x="27" y="18" width="16" height="3" rx="1.5" fill={GOLD} />
      <rect
        x="29.5"
        y="24"
        width="11"
        height="2"
        rx="1"
        fill={GOLD}
        opacity="0.6"
      />
      <path d="M41 52 V61 L43.5 59 L46 61 V52 Z" fill={GOLD} />
    </>
  ),
  headphones: (
    <>
      <path
        d="M13 38 V31 A19 19 0 0 1 51 31 V38"
        stroke={INK}
        strokeWidth="5"
        fill="none"
        strokeLinecap="round"
      />
      <path
        d="M16 30 A16 16 0 0 1 30 15.5"
        stroke="#4a5d70"
        strokeWidth="1.6"
        fill="none"
        strokeLinecap="round"
      />
      <rect x="6" y="33" width="13" height="21" rx="5.5" fill={INK} />
      <rect x="45" y="33" width="13" height="21" rx="5.5" fill={INK} />
      <rect x="16" y="35" width="5" height="17" rx="2.5" fill={TEAL} />
      <rect x="43" y="35" width="5" height="17" rx="2.5" fill={TEAL} />
      <circle cx="12.5" cy="43.5" r="2" fill={TEAL} opacity="0.7" />
      <circle cx="51.5" cy="43.5" r="2" fill={TEAL} opacity="0.7" />
    </>
  ),
  gift: (
    <>
      <path
        d="M9 10 l1.2 3 l3 1.2 l-3 1.2 l-1.2 3 l-1.2 -3 l-3 -1.2 l3 -1.2 Z M55 6 l1 2.4 l2.4 1 l-2.4 1 l-1 2.4 l-1 -2.4 l-2.4 -1 l2.4 -1 Z"
        fill={GOLD}
      />
      <rect x="10" y="29" width="44" height="28" rx="3" fill={TEAL} />
      <path
        d="M40 29 H54 V54 A3 3 0 0 1 51 57 H40 Z"
        fill={TEAL_D}
        opacity="0.45"
      />
      <rect x="7" y="21" width="50" height="10" rx="3" fill="#4fcab8" />
      <rect x="29" y="21" width="6" height="36" fill={GOLD} />
      <path
        d="M32 21 C24 9 12 13 21 21 Z M32 21 C40 9 52 13 43 21 Z"
        fill={GOLD}
        stroke={GOLD_D}
        strokeWidth="1.2"
      />
      <circle cx="32" cy="21" r="3.2" fill={GOLD_D} />
    </>
  ),
};

export default function RewardArt({
  art,
  size = 64,
  locked = false,
}: {
  art: string;
  size?: number;
  locked?: boolean;
}) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 64 64"
      aria-hidden
      className={`transition-[filter,opacity] duration-300 ${
        locked
          ? "opacity-50 grayscale"
          : "drop-shadow-[0_8px_16px_rgba(0,0,0,0.35)]"
      }`}
    >
      {ART[art] ?? ART.gift}
    </svg>
  );
}

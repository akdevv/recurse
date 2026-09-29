import { useState, type ReactNode } from "react";
import { emitRefresh, put, toast, useApi } from "@/lib/api.ts";
import Button from "@/components/common/button.tsx";
import NotifyControls from "@/components/common/notify-controls.tsx";
import {
  DayPicker,
  WindowPicker,
} from "@/components/common/schedule-fields.tsx";
import type { Me, Settings } from "@shared/types.ts";

export default function SettingsRoute() {
  const [s] = useApi<Settings>("/settings");
  const [me] = useApi<Me>("/me");
  if (!s || !me) return null;
  return <SettingsForm initial={s} me={me} />;
}

const hoursBetween = (a: string, b: string) => {
  const m = (t: string) => {
    const [h, mm] = t.split(":").map(Number);
    return h * 60 + mm;
  };
  const d = Math.max(0, m(b) - m(a)) / 60;
  return `${+d.toFixed(1)} ${d === 1 ? "hour" : "hours"}`;
};

function SettingsForm({ initial, me }: { initial: Settings; me: Me }) {
  const [s, setS] = useState(initial);
  const [saved, setSaved] = useState(initial);
  const dirty = JSON.stringify(s) !== JSON.stringify(saved);
  const set = <K extends keyof Settings>(k: K, v: Settings[K]) =>
    setS({ ...s, [k]: v });

  const save = async () => {
    const next = await put<Settings>("/settings", {
      ...s,
      username: s.username.trim() || saved.username,
    });
    setS(next);
    setSaved(next);
    emitRefresh();
    toast("Settings saved");
  };

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-10 px-8 py-8">
      <Section title="Profile">
        <div className="flex items-center gap-4 px-5 py-4">
          <span className="grid size-12 shrink-0 place-items-center rounded-full bg-primary/15 text-base font-semibold text-primary uppercase ring-1 ring-primary/25">
            {(s.username.trim() || "?").slice(0, 2)}
          </span>
          <div className="flex min-w-0 flex-1 flex-col">
            <span className="truncate font-medium">
              {s.username.trim() || "Your name"}
            </span>
            <span className="text-xs text-muted-foreground">
              Level {me.level.level} · {me.level.title}
            </span>
          </div>
        </div>
        <Row label="Username" hint="Shown in the sidebar and greetings.">
          <input
            value={s.username}
            onChange={(e) => set("username", e.target.value)}
            spellCheck={false}
            className="h-9 w-56 rounded-md border border-border bg-background/40 px-3 text-sm outline-none focus:border-ring/60"
          />
        </Row>
      </Section>

      <Section
        title="Study week"
        desc="The daily goal is 30 focused minutes. Any 5 days a week keep the streak."
      >
        <Row
          label="Study days"
          hint={`${s.plannedDays.length} ${s.plannedDays.length === 1 ? "day" : "days"} planned${
            s.plannedDays.length < 5 ? ", the streak needs 5" : ""
          }`}
          warn={s.plannedDays.length < 5}
        >
          <DayPicker
            value={s.plannedDays}
            onChange={(v) => set("plannedDays", v)}
          />
        </Row>
        <Row
          label="Reminder window"
          hint={`Nudges only inside these ${hoursBetween(s.window.start, s.window.end)}.`}
        >
          <WindowPicker value={s.window} onChange={(v) => set("window", v)} />
        </Row>
      </Section>

      <Section
        title="Reminders"
        desc="Nudges stop as soon as today's 30 minutes are done, and never while you're in the app."
      >
        <Row
          label="Daily reminders"
          hint="Up to 8 a day on study days, closer together as the day runs out."
        >
          <Switch on={s.reminders} onChange={(v) => set("reminders", v)} />
        </Row>
        <div
          className={`px-5 py-4 transition-opacity ${s.reminders ? "" : "pointer-events-none opacity-40"}`}
        >
          <NotifyControls />
        </div>
      </Section>

      {/* floats up only when there's something to save */}
      <div
        className={`sticky bottom-6 z-20 mx-auto flex items-center gap-4 rounded-full border border-border bg-popover/95 py-2 pr-2 pl-5 shadow-2xl shadow-black/40 backdrop-blur transition-all duration-300 ${
          dirty
            ? "translate-y-0 opacity-100"
            : "pointer-events-none translate-y-4 opacity-0"
        }`}
      >
        <span className="text-sm text-muted-foreground">Unsaved changes</span>
        <div className="flex gap-1.5">
          <Button variant="ghost" size="sm" onClick={() => setS(saved)}>
            Discard
          </Button>
          <Button size="sm" onClick={save}>
            Save
          </Button>
        </div>
      </div>
    </div>
  );
}

function Section({
  title,
  desc,
  children,
}: {
  title: string;
  desc?: string;
  children: ReactNode;
}) {
  return (
    <section className="flex flex-col gap-3">
      <div>
        <h2 className="text-sm font-semibold">{title}</h2>
        {desc && <p className="mt-0.5 text-xs text-muted-foreground">{desc}</p>}
      </div>
      <div className="divide-y divide-border overflow-hidden rounded-xl border border-border bg-card">
        {children}
      </div>
    </section>
  );
}

function Row({
  label,
  hint,
  warn = false,
  children,
}: {
  label: string;
  hint?: string;
  warn?: boolean;
  children: ReactNode;
}) {
  return (
    <div className="flex flex-wrap items-center justify-between gap-4 px-5 py-4">
      <div className="flex min-w-0 flex-col gap-0.5">
        <span className="text-sm font-medium">{label}</span>
        {hint && (
          <span
            className={`text-xs ${warn ? "text-warning" : "text-muted-foreground"}`}
          >
            {hint}
          </span>
        )}
      </div>
      {children}
    </div>
  );
}

function Switch({
  on,
  onChange,
}: {
  on: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <button
      role="switch"
      aria-checked={on}
      aria-label={on ? "On" : "Off"}
      onClick={() => onChange(!on)}
      className={`relative h-6 w-11 shrink-0 rounded-full transition-colors ${
        on ? "bg-primary" : "bg-secondary ring-1 ring-border ring-inset"
      }`}
    >
      <span
        className={`absolute top-1 left-1 size-4 rounded-full shadow transition-transform duration-200 ${
          on ? "translate-x-5 bg-primary-foreground" : "bg-foreground/70"
        }`}
      />
    </button>
  );
}

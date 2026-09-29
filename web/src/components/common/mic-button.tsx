import { useEffect, useRef, useState } from "react";
import { LuMic, LuMicOff } from "react-icons/lu";
import { holdActive } from "@/lib/activity.ts";

// Web Speech API: Chrome/Safari only, not in the TS DOM lib
const Recognition: any =
  (window as any).SpeechRecognition ?? (window as any).webkitSpeechRecognition;

/** Dictation: appends each finished phrase via onText. Hidden where unsupported. */
export default function MicButton({ onText }: { onText: (s: string) => void }) {
  const [on, setOn] = useState(false);
  const rec = useRef<any>(null);
  const cb = useRef(onText);
  useEffect(() => {
    cb.current = onText;
  });
  useEffect(() => () => rec.current?.stop(), []);
  if (!Recognition) return null;

  const toggle = () => {
    if (on) return rec.current?.stop();
    const r = new Recognition();
    r.continuous = true;
    r.lang = "en-US";
    r.onresult = (e: any) => {
      for (let i = e.resultIndex; i < e.results.length; i++)
        if (e.results[i].isFinal) cb.current(e.results[i][0].transcript.trim());
    };
    const release = holdActive(); // speaking counts as active time
    r.onend = () => {
      release();
      setOn(false);
    };
    r.start();
    rec.current = r;
    setOn(true);
  };

  return (
    <button
      type="button"
      onClick={toggle}
      aria-pressed={on}
      title={on ? "Stop dictation" : "Dictate your answer"}
      className={`flex h-8 items-center gap-1.5 rounded-md px-2.5 text-xs font-medium transition-colors ${
        on
          ? "bg-destructive/10 text-destructive ring-1 ring-destructive/20 ring-inset"
          : "text-muted-foreground hover:bg-accent hover:text-foreground"
      }`}
    >
      {on ? (
        <>
          <LuMicOff className="size-3.5" />
          <span className="relative flex size-1.5">
            <span className="absolute inline-flex size-full animate-ping rounded-full bg-destructive opacity-75 motion-reduce:animate-none" />
            <span className="relative inline-flex size-1.5 rounded-full bg-destructive" />
          </span>
          Listening
        </>
      ) : (
        <>
          <LuMic className="size-3.5" />
          Speak
        </>
      )}
    </button>
  );
}

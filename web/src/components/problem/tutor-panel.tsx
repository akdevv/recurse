import { useEffect, useRef, useState } from "react";
import { LuBot, LuLock, LuSend } from "react-icons/lu";
import { post } from "@/lib/api.ts";
import { appendSpeech } from "@/lib/text.ts";
import Button from "@/components/common/button.tsx";
import MicButton from "@/components/common/mic-button.tsx";
import type { ProblemView, TutorMessage } from "@shared/types.ts";

const INTRO =
  "I won't give you the answer, but I'll ask questions that get you there. What's your idea so far, and where does it break?";

/** Socratic tutor: unlocks after hint 1, asks one guiding question at a time. */
export default function TutorPanel({
  v,
  getCode,
}: {
  v: ProblemView;
  getCode: () => string;
}) {
  const [messages, setMessages] = useState<TutorMessage[]>(v.tutor.messages);
  const [draft, setDraft] = useState("");
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");
  const end = useRef<HTMLDivElement>(null);

  useEffect(() => {
    end.current?.scrollIntoView({ block: "end" });
  }, [messages, busy]);

  if (!v.tutor.unlocked)
    return (
      <div className="flex flex-col items-center gap-1 px-6 py-14 text-center text-sm text-muted-foreground">
        <span className="mb-2 grid size-9 place-items-center rounded-lg bg-secondary">
          <LuLock className="size-4" />
        </span>
        <span className="font-medium text-foreground">Socratic tutor</span>
        <span className="max-w-xs leading-6">
          {v.boss
            ? "No tutor in a boss fight. It's a mock interview."
            : "Opens after you reveal hint 1. Struggle first: that's where the learning happens."}
        </span>
      </div>
    );

  const send = async () => {
    const text = draft.trim();
    if (!text || busy) return;
    setBusy(true);
    setErr("");
    setMessages((m) => [...m, { role: "user", text }]);
    setDraft("");
    try {
      const r = await post<{ messages: TutorMessage[] }>(
        `/problems/${v.problem.id}/tutor`,
        { message: text, code: getCode() },
      );
      setMessages(r.messages);
    } catch (e: any) {
      setErr(e.message);
      setMessages((m) => m.slice(0, -1));
      setDraft(text);
    }
    setBusy(false);
  };

  return (
    <div className="flex min-h-full flex-col">
      <div className="flex flex-1 flex-col gap-3 px-5 py-5">
        <Bubble role="tutor" text={INTRO} />
        {messages.map((m, i) => (
          <Bubble key={i} {...m} />
        ))}
        {busy && (
          <div className="flex items-center gap-2 pl-10 text-xs text-muted-foreground">
            <span className="size-1.5 animate-pulse rounded-full bg-primary motion-reduce:animate-none" />
            Thinking of a good question…
          </div>
        )}
        <div ref={end} />
      </div>

      {v.tutor.open ? (
        <div className="sticky bottom-0 border-t border-border bg-card px-4 py-3">
          <textarea
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            onKeyDown={(e) => {
              if ((e.metaKey || e.ctrlKey) && e.key === "Enter") {
                e.preventDefault();
                send();
              }
            }}
            rows={2}
            placeholder="Where are you stuck? Describe your idea, not just “help”."
            aria-label="Message the tutor"
            className="w-full resize-none rounded-md border border-input bg-background/60 px-3 py-2 text-sm leading-6 outline-none placeholder:text-muted-foreground/60 focus-visible:ring-[3px] focus-visible:ring-ring/40"
          />
          <div className="mt-2 flex items-center gap-2">
            <MicButton onText={(s) => setDraft((d) => appendSpeech(d, s))} />
            {err ? (
              <span className="flex-1 truncate text-xs text-destructive">
                {err}
              </span>
            ) : (
              <span className="flex-1 text-xs text-muted-foreground/70">
                ⌘ Enter to send · sees your current code
              </span>
            )}
            <Button size="sm" onClick={send} disabled={busy || !draft.trim()}>
              <LuSend className="size-3.5" />
              Ask
            </Button>
          </div>
        </div>
      ) : (
        <div className="border-t border-border px-5 py-3 text-xs text-muted-foreground">
          This attempt is finished. The conversation is kept for reference.
        </div>
      )}
    </div>
  );
}

function Bubble({ role, text }: TutorMessage) {
  if (role === "user")
    return (
      <div className="ml-10 self-end rounded-xl rounded-br-sm bg-primary/10 px-3.5 py-2.5 text-sm leading-6 text-foreground ring-1 ring-primary/20 ring-inset">
        {text}
      </div>
    );
  return (
    <div className="mr-6 flex items-start gap-2.5">
      <span className="mt-0.5 grid size-7 shrink-0 place-items-center rounded-full bg-secondary text-primary ring-1 ring-border ring-inset">
        <LuBot className="size-3.5" />
      </span>
      <div className="rounded-xl rounded-tl-sm bg-secondary px-3.5 py-2.5 text-sm leading-6 whitespace-pre-wrap text-foreground/90">
        {text}
      </div>
    </div>
  );
}

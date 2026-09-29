import { useState } from "react";
import { LuMessageSquareQuote } from "react-icons/lu";
import { post, xpToast } from "@/lib/api.ts";
import { appendSpeech } from "@/lib/text.ts";
import Button from "@/components/common/button.tsx";
import ExplainFeedback from "@/components/common/explain-feedback.tsx";
import MicButton from "@/components/common/mic-button.tsx";
import type { Topic } from "@shared/types.ts";

const MIN_CHARS = 40;

export default function ExplainCard({
  topic,
  saved,
  onSaved,
}: {
  topic: Topic;
  saved: string;
  onSaved: () => void;
}) {
  const [text, setText] = useState(saved);
  const [err, setErr] = useState("");
  const submitted = !!saved;
  const remaining = MIN_CHARS - text.trim().length;
  const changed = text.trim() !== saved.trim();

  const submit = async () => {
    try {
      const r = await post<{ xp: number }>(`/topics/${topic.id}/explain`, {
        text,
      });
      xpToast(r.xp);
      setErr("");
      onSaved();
    } catch (e: any) {
      setErr(e.message);
    }
  };

  return (
    <div className="overflow-hidden rounded-xl border border-border bg-card">
      <div className="px-6 py-5">
        <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
          <LuMessageSquareQuote className="size-3.5 text-primary" />
          Interviewer
        </div>
        <p className="mt-1 text-[15px] leading-7 font-medium">
          {topic.explain.prompt}
        </p>
      </div>

      <textarea
        id="explain-text"
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="Say it out loud first, then write it down: the idea, why it works, and its complexity."
        className="block min-h-44 w-full resize-y border-y border-border bg-background/40 px-6 py-4 text-sm leading-6 outline-none placeholder:text-muted-foreground/60 focus:bg-background/70"
      />

      <div className="flex items-center justify-between gap-4 px-6 py-3.5">
        <span
          className={`text-xs tabular-nums ${err ? "text-destructive" : "text-muted-foreground"}`}
        >
          {err ||
            (remaining > 0
              ? `${remaining} more characters`
              : submitted && !changed
                ? "Saved"
                : `${text.trim().length} characters`)}
        </span>
        <div className="flex items-center gap-2">
          <MicButton onText={(t) => setText((s) => appendSpeech(s, t))} />
          <Button
            size="sm"
            disabled={remaining > 0 || (submitted && !changed)}
            onClick={submit}
          >
            {submitted ? "Update" : "Submit"}
          </Button>
        </div>
      </div>

      {submitted && (
        <div className="border-t border-border">
          <ExplainFeedback
            kind="topic"
            refId={topic.id}
            answer={saved}
            keyPoints={topic.explain.keyPoints}
          />
        </div>
      )}
    </div>
  );
}

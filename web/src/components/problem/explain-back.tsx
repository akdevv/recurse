import { useState } from "react";
import { LuMessageSquareQuote } from "react-icons/lu";
import { post } from "@/lib/api.ts";
import { appendSpeech } from "@/lib/text.ts";
import Button from "@/components/common/button.tsx";
import ExplainFeedback from "@/components/common/explain-feedback.tsx";
import MicButton from "@/components/common/mic-button.tsx";

const MIN_CHARS = 20;

export default function ExplainBack({
  id,
  initial,
  keyPoints,
}: {
  id: string;
  initial: string;
  keyPoints: string[];
}) {
  const [text, setText] = useState(initial);
  const [saved, setSaved] = useState(initial);
  const remaining = MIN_CHARS - text.trim().length;
  const changed = text.trim() !== saved.trim();

  return (
    <div className="mx-4 mb-4 overflow-hidden rounded-lg border border-border bg-background/40">
      <div className="px-4 pt-3.5 pb-3">
        <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
          <LuMessageSquareQuote className="size-3.5 text-primary" />
          Interviewer
        </div>
        <p className="mt-1 text-sm leading-6 font-medium">
          Walk me through your solution: the approach, why it works, and its
          time and space complexity.
        </p>
      </div>
      <textarea
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="Say it out loud first, then write it down."
        className="block min-h-28 w-full resize-y border-y border-border bg-card/60 px-4 py-3 text-sm leading-6 outline-none placeholder:text-muted-foreground/60"
      />
      <div className="flex items-center justify-between gap-4 px-4 py-2.5">
        <span className="text-xs text-muted-foreground tabular-nums">
          {remaining > 0
            ? `${remaining} more characters`
            : saved && !changed
              ? "Saved"
              : `${text.trim().length} characters`}
        </span>
        <div className="flex items-center gap-2">
          <MicButton onText={(t) => setText((s) => appendSpeech(s, t))} />
          <Button
            size="sm"
            disabled={remaining > 0 || !changed}
            onClick={() =>
              post(`/problems/${id}/save`, { explain: text }).then(() =>
                setSaved(text),
              )
            }
          >
            {saved ? "Update" : "Save"}
          </Button>
        </div>
      </div>

      {saved && (
        <div className="border-t border-border">
          <ExplainFeedback
            kind="problem"
            refId={id}
            answer={saved}
            keyPoints={keyPoints}
            className="px-4 py-4"
          />
        </div>
      )}
    </div>
  );
}

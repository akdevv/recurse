import { useState } from "react";
import { LuCheck, LuCopy } from "react-icons/lu";
import { highlight, useHighlighterReady } from "@/lib/highlight.ts";

export default function CodeBlock({
  code,
  lang = "python",
  className = "",
}: {
  code: string;
  lang?: string;
  className?: string;
}) {
  useHighlighterReady();
  const [copied, setCopied] = useState(false);
  const html = highlight(code.replace(/\n$/, ""), lang);

  const copy = () =>
    navigator.clipboard.writeText(code).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 1500);
    });

  return (
    <div
      className={`not-prose group relative rounded-lg border border-border bg-background/60 ${className}`}
    >
      <span
        className={`pointer-events-none absolute top-3 right-4 font-mono text-[10px] tracking-wider text-muted-foreground/60 uppercase transition-opacity group-hover:opacity-0 ${copied ? "opacity-0" : ""}`}
      >
        {lang}
      </span>
      <button
        onClick={copy}
        aria-label={copied ? "Copied" : "Copy code"}
        title={copied ? "Copied" : "Copy"}
        className={`absolute top-2 right-2 grid size-7 place-items-center rounded-md border border-border bg-card text-muted-foreground transition-all hover:bg-accent hover:text-foreground focus-visible:opacity-100 ${
          copied ? "opacity-100" : "opacity-0 group-hover:opacity-100"
        }`}
      >
        {copied ? (
          <LuCheck className="size-3.5 text-success" />
        ) : (
          <LuCopy className="size-3.5" />
        )}
      </button>
      {html ? (
        <div
          className="overflow-x-auto px-4 py-3.5 font-mono text-[13px] leading-6 [&_pre]:bg-transparent!"
          dangerouslySetInnerHTML={{ __html: html }}
        />
      ) : (
        <pre className="overflow-x-auto px-4 py-3.5 font-mono text-[13px] leading-6 text-foreground/85">
          {code}
        </pre>
      )}
    </div>
  );
}

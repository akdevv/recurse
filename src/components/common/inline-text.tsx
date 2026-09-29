/** Renders `code` and *emphasis* inside short plain-text strings (quiz questions, options, explanations). */
export default function InlineText({ text }: { text: string }) {
  return (
    <>
      {text.split(/(`[^`]+`|\*[^*\s][^*]*\*)/g).map((part, i) =>
        part.startsWith("`") && part.endsWith("`") && part.length > 1 ? (
          <code
            key={i}
            className="rounded bg-secondary px-1 py-px font-mono text-[0.85em] text-foreground"
          >
            {part.slice(1, -1)}
          </code>
        ) : part.startsWith("*") && part.endsWith("*") && part.length > 2 ? (
          <em key={i}>{part.slice(1, -1)}</em>
        ) : (
          part
        ),
      )}
    </>
  );
}

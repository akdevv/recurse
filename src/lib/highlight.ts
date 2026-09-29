import type { HighlighterCore } from "shiki/core";
import { store } from "@/lib/ui-state.ts";

const highlighter = store<HighlighterCore | null>(null);

// loaded lazily so shiki stays out of the main bundle; code renders as plain text until then
Promise.all([import("shiki/core"), import("shiki/engine/javascript")])
  .then(([{ createHighlighterCore }, { createJavaScriptRegexEngine }]) =>
    createHighlighterCore({
      themes: [import("@shikijs/themes/vitesse-dark")],
      langs: [import("@shikijs/langs/python")],
      engine: createJavaScriptRegexEngine(),
    }),
  )
  .then(highlighter.set);

/** Re-renders the caller once the highlighter has loaded. */
export const useHighlighterReady = () => highlighter.use() !== null;

/** Highlighted HTML, or null until the highlighter is ready (callers render plain text meanwhile). */
export function highlight(code: string, lang = "python"): string | null {
  const h = highlighter.get();
  if (!h) return null;
  return h.codeToHtml(code, {
    lang: h.getLoadedLanguages().includes(lang) ? lang : "text",
    theme: "vitesse-dark",
    colorReplacements: { "#121212": "transparent" },
  });
}

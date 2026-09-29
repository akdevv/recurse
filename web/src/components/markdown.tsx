import { marked, type Token, type Tokens } from "marked";
import Viz from "@/components/viz.tsx";
import CodeBlock from "@/components/common/code-block.tsx";
import { slugify } from "@/lib/text.ts";
import type { VizTrace } from "@shared/types.ts";

type Part =
  | { kind: "html"; html: string }
  | { kind: "code"; code: string; lang: string }
  | { kind: "viz"; id: string };

function toParts(text: string): Part[] {
  const tokens = marked.lexer(text);
  const parts: Part[] = [];
  let run: Token[] = [];
  const flush = () => {
    if (!run.length) return;
    const html = marked.parser(Object.assign(run, { links: tokens.links }));
    // h2 ids so the page's table of contents can link to them
    parts.push({
      kind: "html",
      html: html.replace(
        /<h2>(.*?)<\/h2>/g,
        (_, inner) =>
          `<h2 id="${slugify(inner)}" class="group">${inner}<a href="#${slugify(inner)}" aria-label="Link to this section" class="ml-2 font-normal no-underline opacity-0 transition-opacity group-hover:opacity-60">#</a></h2>`,
      ),
    });
    run = [];
  };
  for (const t of tokens) {
    if (t.type !== "code") {
      run.push(t);
      continue;
    }
    flush();
    const { text: code, lang = "" } = t as Tokens.Code;
    parts.push(
      lang === "viz"
        ? { kind: "viz", id: code.trim() }
        : { kind: "code", code, lang: lang || "text" },
    );
  }
  flush();
  return parts;
}

export default function Markdown({
  text,
  viz = {},
}: {
  text: string;
  viz?: Record<string, VizTrace>;
}) {
  return (
    <div className="prose max-w-none prose-invert prose-headings:scroll-mt-6 prose-headings:font-semibold prose-headings:tracking-tight prose-h2:mt-14 prose-h2:mb-3 prose-h2:text-[17px] prose-h3:text-[15px] prose-p:text-[15px] prose-p:leading-7 prose-p:text-foreground/80 prose-a:text-primary prose-strong:font-semibold prose-strong:text-foreground prose-code:rounded prose-code:bg-secondary prose-code:px-1.5 prose-code:py-0.5 prose-code:text-[0.82em] prose-code:font-normal prose-code:text-foreground prose-code:before:content-none prose-code:after:content-none prose-ol:text-[15px] prose-ol:text-foreground/80 prose-ul:text-[15px] prose-ul:text-foreground/80 prose-li:my-1 prose-li:marker:text-muted-foreground/70 prose-table:my-6 prose-table:text-[13px] prose-thead:border-border prose-tr:border-border prose-th:bg-card prose-th:px-3 prose-th:py-2 prose-th:font-medium prose-th:text-foreground prose-td:px-3 prose-td:py-2 prose-td:text-foreground/80 [&>div:first-child>h2:first-child]:mt-0">
      {toParts(text).map((p, i) =>
        p.kind === "html" ? (
          <div key={i} dangerouslySetInnerHTML={{ __html: p.html }} />
        ) : p.kind === "code" ? (
          <CodeBlock key={i} code={p.code} lang={p.lang} className="my-5" />
        ) : viz[p.id] ? (
          <Viz key={i} trace={viz[p.id]} />
        ) : (
          <p key={i} className="text-destructive">
            Missing visualization: {p.id}
          </p>
        ),
      )}
    </div>
  );
}

import { existsSync, readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { marked } from "marked";
import { ROOT } from "./db.ts";
import type {
  Course,
  Module,
  Problem,
  QuizQ,
  Topic,
  VizTrace,
} from "../shared/types.ts";

// ponytail: re-reads files on every call so content edits show up live; add an mtime cache if it gets slow.

export const COURSE_ID = "dsa";
export const COURSE_DIR = join(ROOT, "courses", COURSE_ID);

const json = <T>(p: string): T => JSON.parse(readFileSync(p, "utf8"));
const text = (p: string) => (existsSync(p) ? readFileSync(p, "utf8") : "");

export const course = () => json<Course>(join(COURSE_DIR, "course.json"));
export const module_ = (id: string) =>
  json<Module>(join(COURSE_DIR, "modules", id, "module.json"));
export const modules = () => course().modules.map(module_);

export function topicDir(topicId: string): string | null {
  for (const m of course().modules) {
    const d = join(COURSE_DIR, "modules", m, "topics", topicId);
    if (existsSync(join(d, "topic.json"))) return d;
  }
  return null;
}

export function topic(topicId: string): Topic | null {
  const d = topicDir(topicId);
  return d ? json<Topic>(join(d, "topic.json")) : null;
}

export function quiz(topicId: string): QuizQ[] {
  const p = join(topicDir(topicId)!, "quiz.json");
  return existsSync(p) ? json(p) : [];
}

export function topicContent(topicId: string) {
  const d = topicDir(topicId)!;
  const viz: Record<string, VizTrace> = {};
  const vdir = join(d, "viz");
  if (existsSync(vdir))
    for (const f of readdirSync(vdir))
      if (f.endsWith(".json")) viz[f.slice(0, -5)] = json(join(vdir, f));
  return { lesson: text(join(d, "lesson.md")), quiz: quiz(topicId), viz };
}

const PROBLEMS_DIR = join(COURSE_DIR, "problems");
export const problemDir = (id: string) =>
  join(
    PROBLEMS_DIR,
    readdirSync(PROBLEMS_DIR).find((f) => f.replace(/^\d+-/, "") === id) ?? id,
  );
/** Playable: authored (tests generated), not just imported from LeetCode. */
export const hasProblem = (id: string) =>
  existsSync(join(problemDir(id), "tests.json"));

/** Split markdown on top-level "# " headings, ignoring code fences. First entry (head "") is the intro. */
function sections(body: string) {
  const out = [{ head: "", text: "" }];
  let fence = false;
  for (const line of body.split("\n")) {
    if (line.startsWith("```")) fence = !fence;
    if (!fence && line.startsWith("# "))
      out.push({ head: line.slice(2).trim(), text: "" });
    else out[out.length - 1].text += line + "\n";
  }
  return out.map((s) => ({ head: s.head, text: s.text.trim() }));
}

const pyBlocks = (s: string) =>
  [...s.matchAll(/```python\n([\s\S]*?)```/g)].map((m) => m[1]);

/** problem.md → problem + statement + per-solution code/notes. Keep in sync with pyjudge.load_problem. */
export function loadProblem(id: string) {
  const src = readFileSync(join(problemDir(id), "problem.md"), "utf8");
  const [, fm, body] = src.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/)!;
  const meta: Record<string, any> = {};
  for (const line of fm.split("\n")) {
    const i = line.indexOf(": ");
    meta[line.slice(0, i)] = JSON.parse(line.slice(i + 2));
  }
  const [intro, ...rest] = sections(body);
  const p: Problem = {
    id,
    lc: meta.lc ? { id: meta.lc, slug: id } : null,
    title: meta.title,
    difficulty: meta.difficulty,
    patterns: meta.patterns ?? [],
    starter: "",
    entry: meta.entry,
    examples: meta.examples,
    judge: {
      compare: meta.compare ?? "exact",
      timeLimitMs: meta.timeLimitMs ?? 2000,
    },
    solutions: [],
    hints: [],
    lcHints: meta.lcHints ?? [],
    explain: { keyPoints: [] },
  };
  const code: Record<string, string> = {};
  const notes: Record<string, string> = {};
  for (const { head, text: t } of rest) {
    const blocks = pyBlocks(t);
    if (head === "Starter") p.starter = blocks[0].slice(0, -1);
    else if (head === "Hints")
      p.hints = t
        .split("\n")
        .filter((l) => /^\d+\. /.test(l))
        .map((l) => l.replace(/^\d+\.\s*/, ""));
    else if (head === "Key points")
      p.explain.keyPoints = t
        .split("\n")
        .filter((l) => l.startsWith("- "))
        .map((l) => l.slice(2));
    else if (head.startsWith("Solution:")) {
      const [sid, title, time, space, ...flags] = head
        .slice("Solution:".length)
        .split(" · ")
        .map((x) => x.trim());
      p.solutions.push({
        id: sid,
        title,
        time,
        space,
        ...Object.fromEntries(flags.map((f) => [f, true])),
      });
      code[sid] = blocks[blocks.length - 1];
      notes[sid] = t.slice(0, t.lastIndexOf("```python\n" + code[sid])).trim();
    }
  }
  return {
    problem: p,
    statement: marked.parse(intro.text, { async: false }),
    files: (sid: string) => ({ code: code[sid] ?? "", md: notes[sid] ?? "" }),
  };
}

export const problem = (id: string) => loadProblem(id).problem;
export const statement = (id: string) => loadProblem(id).statement;

/** Which topic (and role) a problem belongs to, first match in course order. */
export function problemHome(problemId: string) {
  for (const m of modules())
    for (const tid of m.topics) {
      const t = topic(tid);
      const ref = t?.problems.find((r) => r.id === problemId);
      if (t && ref) return { module: m, topic: t, role: ref.role };
    }
  return null;
}

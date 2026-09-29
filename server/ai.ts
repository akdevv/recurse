// Every AI call goes through here, so switching model/provider means editing this file only.
import { execFile } from "node:child_process";
import { tmpdir } from "node:os";
import type { Grade } from "../shared/types.ts";

const MODEL = process.env.AI_MODEL ?? "opus"; // grading: careful, infrequent
const TUTOR_MODEL = process.env.AI_TUTOR_MODEL ?? "sonnet"; // chat: frequent, needs speed
const TIMEOUT_MS = 120_000;

function ask(prompt: string, model = MODEL): Promise<string> {
  return new Promise((resolve, reject) =>
    execFile(
      "claude",
      ["-p", prompt, "--model", model, "--output-format", "json"],
      // tmp cwd so the CLI doesn't load this repo's CLAUDE.md into every call
      { cwd: tmpdir(), timeout: TIMEOUT_MS, maxBuffer: 4 << 20 },
      (err, stdout) => {
        if (err) return reject(err);
        try {
          const out = JSON.parse(stdout);
          if (out.is_error) return reject(new Error(out.result));
          resolve(String(out.result));
        } catch (e) {
          reject(e);
        }
      },
    ),
  );
}

const json = (text: string) =>
  JSON.parse(text.slice(text.indexOf("{"), text.lastIndexOf("}") + 1));

export async function tutorReply(q: {
  title: string;
  statement: string; // plain text
  hints: string[]; // hints the learner has already revealed
  code: string;
  history: { role: "user" | "tutor"; text: string }[];
}): Promise<string> {
  const convo = q.history
    .map((m) => `${m.role === "user" ? "Learner" : "Tutor"}: ${m.text}`)
    .join("\n\n");
  const prompt = `You are a Socratic DSA tutor helping a learner who is stuck on a coding problem (Python). Your job is to make THEM find the idea.

Rules:
- Never give the solution, the algorithm name if they haven't reached it, or any code (not even pseudocode or a line of it).
- Reply in at most 3 short sentences, ending with exactly ONE guiding question.
- Build on what they already have: look at their code and point them at the specific part to rethink (by describing it, not rewriting it).
- If they ask for the answer or code directly, kindly refuse and ask a smaller question that moves them one step forward.
- Prefer questions about a tiny concrete example, an invariant, or the complexity of their current approach.
- Plain text, no markdown headings, no lists.

Problem: ${q.title}
${q.statement.slice(0, 3000)}

Hints they've already seen:
${q.hints.map((h, i) => `${i + 1}. ${h}`).join("\n") || "(none)"}

Their current code:
\`\`\`python
${q.code.slice(0, 4000)}
\`\`\`

Conversation so far:
${convo}

Write only the tutor's next reply.`;
  return (await ask(prompt, TUTOR_MODEL)).trim();
}

export async function gradeExplain(q: {
  question: string;
  keyPoints: string[];
  answer: string;
}): Promise<Grade> {
  const prompt = `You are a strict but fair technical interviewer grading a candidate's verbal explanation in a DSA interview. Be honest, never flattering: vague or hand-wavy answers score low.

Question: ${q.question}

Key points a strong answer covers:
${q.keyPoints.map((k, i) => `${i + 1}. ${k}`).join("\n")}

Candidate's answer:
"""
${q.answer}
"""

Reply with ONLY a JSON object, no prose, no code fence:
{"score": <integer 0-5, 5 = interview-ready>, "covered": [<true/false per key point, in order>], "feedback": "<2-3 short sentences: what was good, what was missing or wrong>", "followUp": "<one probing follow-up question an interviewer would ask next>"}`;

  const g = json(await ask(prompt));
  return {
    score: Math.max(0, Math.min(5, Math.round(Number(g.score) || 0))),
    covered: q.keyPoints.map((_, i) => !!g.covered?.[i]),
    feedback: String(g.feedback ?? ""),
    followUp: String(g.followUp ?? ""),
  };
}

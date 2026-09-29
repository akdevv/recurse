import { spawn } from "node:child_process";
import { join } from "node:path";
import { problemDir } from "../content.ts";
import type { JudgeResult } from "../../shared/types.ts";

const PYJUDGE = join(import.meta.dirname, "pyjudge.py");

/** Runs user code in a local python3 process. Per-test limits are enforced in Python; this is the hard backstop. */
export function judge(
  problemId: string,
  code: string,
  mode: "run" | "submit",
  custom: string[] = [],
): Promise<JudgeResult> {
  return new Promise((resolve) => {
    const p = spawn("python3", [PYJUDGE], {
      timeout: mode === "run" ? 20_000 : 90_000,
    });
    let out = "",
      err = "";
    p.stdout.on("data", (d) => (out += d));
    p.stderr.on("data", (d) => (err += d));
    p.on("close", (code, signal) => {
      try {
        resolve(JSON.parse(out));
      } catch {
        resolve({
          verdict: signal ? "Time Limit Exceeded" : "Judge Error",
          passed: 0,
          total: 0,
          results: [],
          error: signal
            ? "Killed: total time limit exceeded"
            : err.slice(-2000) || `exit ${code}`,
        });
      }
    });
    p.stdin.end(
      JSON.stringify({ code, problemDir: problemDir(problemId), mode, custom }),
    );
  });
}

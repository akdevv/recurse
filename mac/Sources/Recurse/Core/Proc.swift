import Foundation

struct JudgeResult: Decodable {
    struct Case: Decodable {
        let kind, verdict: String
        let ms: Double
        let stdout: String
        let input: [String]
        let expected, got, error: String?
    }
    var verdict: String
    var passed, total: Int
    var error: String?
    var slowestMs: Double?
    var results: [Case]

    static func passes(_ verdict: String) -> Bool { verdict == "Accepted" || verdict == "Ran" }
}

struct Grade: Codable, Equatable {
    var score: Int // 0..5
    var covered: [Bool]
    var feedback, followUp: String
}

enum Proc {
    struct Output: Sendable { let status: Int32; let out: String; let err: String; let timedOut: Bool }

    // GUI apps start with a bare PATH; add where python3 (Homebrew) and claude (~/.local/bin) live
    static let env: [String: String] = {
        var e = ProcessInfo.processInfo.environment
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        e["PATH"] = ["\(home)/.local/bin", "/opt/homebrew/bin", "/usr/local/bin", e["PATH"] ?? "/usr/bin:/bin"]
            .joined(separator: ":")
        return e
    }()

    static func run(_ args: [String], stdin: String = "", timeout: TimeInterval, cwd: URL? = nil) async -> Output {
        await withCheckedContinuation { cont in
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            p.arguments = args
            p.environment = env
            if let cwd { p.currentDirectoryURL = cwd }
            let inPipe = Pipe(), outPipe = Pipe(), errPipe = Pipe()
            p.standardInput = inPipe
            p.standardOutput = outPipe
            p.standardError = errPipe
            // read pipes concurrently so a chatty child can't fill the buffer and block
            let out = Buffer(), err = Buffer()
            let group = DispatchGroup()
            for (pipe, buf) in [(outPipe, out), (errPipe, err)] {
                group.enter()
                DispatchQueue.global().async {
                    buf.data = pipe.fileHandleForReading.readDataToEndOfFile()
                    group.leave()
                }
            }
            let killed = Buffer()
            p.terminationHandler = { p in
                group.notify(queue: .global()) {
                    cont.resume(returning: Output(
                        status: p.terminationStatus, out: String(decoding: out.data, as: UTF8.self),
                        err: String(decoding: err.data, as: UTF8.self), timedOut: killed.flag))
                }
            }
            do { try p.run() } catch {
                cont.resume(returning: Output(status: -1, out: "", err: "\(error)", timedOut: false))
                return
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                if p.isRunning { killed.flag = true; p.terminate() }
            }
            inPipe.fileHandleForWriting.write(Data(stdin.utf8))
            try? inPipe.fileHandleForWriting.close()
        }
    }

    private final class Buffer: @unchecked Sendable { var data = Data(); var flag = false }

    /// Per-test limits are enforced in Python; the timeout here is the hard backstop.
    static func judge(problemDir: URL, code: String, mode: String, custom: [String] = []) async -> JudgeResult {
        let req = try! JSONSerialization.data(withJSONObject: [
            "code": code, "problemDir": problemDir.path, "mode": mode, "custom": custom,
        ])
        let o = await run(["python3", Paths.pyjudge.path], stdin: String(decoding: req, as: UTF8.self),
                          timeout: mode == "run" ? 20 : 90)
        if let r = try? JSONDecoder().decode(JudgeResult.self, from: Data(o.out.utf8)) { return r }
        return JudgeResult(
            verdict: o.timedOut ? "Time Limit Exceeded" : "Judge Error", passed: 0, total: 0,
            error: o.timedOut ? "Killed: total time limit exceeded" : String((o.err.isEmpty ? "exit \(o.status)" : o.err).suffix(2000)),
            results: [])
    }

    struct AIError: LocalizedError { let errorDescription: String? }

    static func tutorReply(title: String, statement: String, hints: [String], code: String,
                           history: [(role: String, text: String)], ai: AI.Config) async throws -> String {
        let convo = history.map { "\($0.role == "user" ? "Learner" : "Tutor"): \($0.text)" }.joined(separator: "\n\n")
        let seen = hints.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n")
        let prompt = """
        You are a Socratic DSA tutor helping a learner who is stuck on a coding problem (Python). Your job is to make THEM find the idea.

        Rules:
        - Never give the solution, the algorithm name if they haven't reached it, or any code (not even pseudocode or a line of it).
        - Reply in at most 3 short sentences, ending with exactly ONE guiding question.
        - Build on what they already have: look at their code and point them at the specific part to rethink (by describing it, not rewriting it).
        - If they ask for the answer or code directly, kindly refuse and ask a smaller question that moves them one step forward.
        - Prefer questions about a tiny concrete example, an invariant, or the complexity of their current approach.
        - Plain text, no markdown headings, no lists.

        Problem: \(title)
        \(statement.prefix(3000))

        Hints they've already seen:
        \(seen.isEmpty ? "(none)" : seen)

        Their current code:
        ```python
        \(code.prefix(4000))
        ```

        Conversation so far:
        \(convo)

        Write only the tutor's next reply.
        """
        return try await AI.ask(prompt, ai, .tutor).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func gradeExplain(question: String, keyPoints: [String], answer: String, ai: AI.Config) async throws -> Grade {
        let points = keyPoints.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n")
        let prompt = """
        You are a strict but fair technical interviewer grading a candidate's verbal explanation in a DSA interview. Be honest, never flattering: vague or hand-wavy answers score low.

        Question: \(question)

        Key points a strong answer covers:
        \(points)

        Candidate's answer:
        \"\"\"
        \(answer)
        \"\"\"

        Reply with ONLY a JSON object, no prose, no code fence:
        {"score": <integer 0-5, 5 = interview-ready>, "covered": [<true/false per key point, in order>], "feedback": "<2-3 short sentences: what was good, what was missing or wrong>", "followUp": "<one probing follow-up question an interviewer would ask next>"}
        """
        let text = try await AI.ask(prompt, ai, .grade)
        guard let a = text.firstIndex(of: "{"), let b = text.lastIndex(of: "}"),
              let g = try? JSONSerialization.jsonObject(with: Data(text[a...b].utf8)) as? [String: Any]
        else { throw AIError(errorDescription: "unreadable grade") }
        let covered = g["covered"] as? [Bool] ?? []
        return Grade(
            score: max(0, min(5, Int(((g["score"] as? NSNumber)?.doubleValue ?? 0).rounded()))),
            covered: keyPoints.indices.map { $0 < covered.count && covered[$0] },
            feedback: "\(g["feedback"] ?? "")", followUp: "\(g["followUp"] ?? "")")
    }
}

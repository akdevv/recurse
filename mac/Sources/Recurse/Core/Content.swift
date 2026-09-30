// Reads courses/dsa from disk. Keep the problem.md parser in sync with scripts/pyjudge.py.
import Foundation

enum Difficulty: String, Decodable {
    case easy = "Easy", medium = "Medium", hard = "Hard"
}

enum Role: String, Decodable {
    case guided, core, optional
}

struct Course: Decodable { let id, title: String; let modules: [String] }

struct Module: Decodable, Identifiable, Hashable {
    let id: String
    let number: Int
    let title, summary: String
    let prereqs, topics: [String]
    struct Boss: Decodable, Hashable { let timeLimitMin: Int }
    let boss: Boss
}

struct ProblemRef: Decodable, Hashable {
    let id: String
    let role: Role
    // only set for problems not imported yet
    let title: String?
    let difficulty: Difficulty?
    let lc: Int?
}

struct Topic: Decodable, Identifiable, Hashable {
    let id, title, status, learn: String
    let hook: String?
    let patterns: [String]
    let problems: [ProblemRef]
    struct Explain: Decodable, Hashable { let prompt: String; let keyPoints: [String] }
    let explain: Explain
    var ready: Bool { status == "ready" }
}

struct QuizQ: Decodable, Identifiable {
    let id, q: String
    let code: String?
    let options: [String]
    let answer: Int
    let why: String
}

/// Loose JSON for viz traces (each view has its own step shape).
enum JSON: Decodable, Equatable {
    case num(Double), str(String), bool(Bool), arr([JSON]), obj([String: JSON]), null

    init(from d: Decoder) throws {
        let c = try d.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let v = try? c.decode(Bool.self) { self = .bool(v) }
        else if let v = try? c.decode(Double.self) { self = .num(v) }
        else if let v = try? c.decode(String.self) { self = .str(v) }
        else if let v = try? c.decode([JSON].self) { self = .arr(v) }
        else { self = .obj(try c.decode([String: JSON].self)) }
    }

    subscript(_ k: String) -> JSON? { if case .obj(let o) = self { o[k] } else { nil } }
    subscript(_ i: Int) -> JSON? { if case .arr(let a) = self, a.indices.contains(i) { a[i] } else { nil } }
    var array: [JSON] { if case .arr(let a) = self { a } else { [] } }
    var object: [String: JSON] { if case .obj(let o) = self { o } else { [:] } }
    var number: Double? { if case .num(let n) = self { n } else { nil } }
    var int: Int? { number.map { Int($0) } }
    var string: String? { if case .str(let s) = self { s } else { nil } }
    var isNull: Bool { self == .null }

    /// How Python/JS would print it: ints without ".0", strings bare.
    var text: String {
        switch self {
        case .num(let n): n == n.rounded() && abs(n) < 1e15 ? String(Int(n)) : String(n)
        case .str(let s): s
        case .bool(let b): b ? "true" : "false"
        case .null: "null"
        case .arr(let a): "[" + a.map(\.json).joined(separator: ",") + "]"
        case .obj(let o): "{" + o.sorted { $0.key < $1.key }.map { "\"\($0.key)\":\($0.value.json)" }.joined(separator: ",") + "}"
        }
    }
    var json: String { if case .str(let s) = self { "\"\(s)\"" } else { text } }
}

struct VizTrace: Decodable {
    let title, view: String
    let steps: [JSON]
}

struct Solution: Identifiable {
    let id, title, time, space: String
    let reference, slow: Bool
    let code, notes: String
}

struct Problem {
    let id: String
    let lc: Int?
    let title: String
    let difficulty: Difficulty
    let patterns: [String]
    let params: [String]
    let starter: String
    let statement: String
    let hints: [String]
    let keyPoints: [String]
    let solutions: [Solution]
}

@MainActor
enum Content {
    private static func json<T: Decodable>(_ url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        do { return try JSONDecoder().decode(T.self, from: data) } catch {
            print("bad JSON \(url.path): \(error)")
            return nil
        }
    }

    private static func text(_ url: URL) -> String { (try? String(contentsOf: url, encoding: .utf8)) ?? "" }

    // ponytail: JSON files are re-read on every call so content edits show up live; problems are cached by mtime
    static func course() -> Course { json(Paths.course.appending(path: "course.json"))! }
    static func module(_ id: String) -> Module { json(Paths.course.appending(path: "modules/\(id)/module.json"))! }
    static func modules() -> [Module] { course().modules.map(module) }

    static func topicDir(_ id: String) -> URL? {
        for m in course().modules {
            let d = Paths.course.appending(path: "modules/\(m)/topics/\(id)")
            if FileManager.default.fileExists(atPath: d.appending(path: "topic.json").path) { return d }
        }
        return nil
    }

    static func topic(_ id: String) -> Topic? { topicDir(id).flatMap { json($0.appending(path: "topic.json")) } }

    static func quiz(_ topicId: String) -> [QuizQ] {
        topicDir(topicId).flatMap { json($0.appending(path: "quiz.json")) } ?? []
    }

    static func lesson(_ topicId: String) -> (markdown: String, viz: [String: VizTrace]) {
        guard let d = topicDir(topicId) else { return ("", [:]) }
        var viz: [String: VizTrace] = [:]
        let vdir = d.appending(path: "viz")
        for f in (try? FileManager.default.contentsOfDirectory(atPath: vdir.path)) ?? [] where f.hasSuffix(".json") {
            viz[String(f.dropLast(5))] = json(vdir.appending(path: f))
        }
        return (text(d.appending(path: "lesson.md")), viz)
    }

    // MARK: problems

    private static let problemsDir = Paths.course.appending(path: "problems")

    private static var dirNames: [String: String] = [:] // slug → "0001-two-sum"

    static func problemDir(_ id: String) -> URL {
        if dirNames[id] == nil { // new problems show up without a restart
            let names = (try? FileManager.default.contentsOfDirectory(atPath: problemsDir.path)) ?? []
            dirNames = Dictionary(names.map { ($0.replacing(/^\d+-/, with: ""), $0) }, uniquingKeysWith: { a, _ in a })
        }
        return problemsDir.appending(path: dirNames[id] ?? id)
    }

    /// Playable: authored (tests generated), not just imported from LeetCode.
    static func hasProblem(_ id: String) -> Bool {
        FileManager.default.fileExists(atPath: problemDir(id).appending(path: "tests.json").path)
    }

    /// Split markdown on top-level "# " headings, ignoring code fences. First entry (head "") is the intro.
    static func sections(_ body: String) -> [(head: String, text: String)] {
        var out: [(head: String, text: String)] = [("", "")]
        var fence = false
        for line in body.split(separator: "\n", omittingEmptySubsequences: false) {
            if line.hasPrefix("```") { fence.toggle() }
            if !fence && line.hasPrefix("# ") {
                out.append((String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces), ""))
            } else {
                out[out.count - 1].text += line + "\n"
            }
        }
        return out.map { ($0.head, $0.text.trimmingCharacters(in: .whitespacesAndNewlines)) }
    }

    static func pyBlocks(_ s: String) -> [String] {
        s.matches(of: /```python\n([\s\S]*?)```/).map { String($0.output.1) }
    }

    private static var parsed: [String: (mtime: Date, problem: Problem?)] = [:]

    static func problem(_ id: String) -> Problem? {
        let url = problemDir(id).appending(path: "problem.md")
        let mtime = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
        if let hit = parsed[id], hit.mtime == mtime { return hit.problem }
        let p = parseProblem(id, text(url))
        parsed[id] = (mtime, p)
        return p
    }

    private static func parseProblem(_ id: String, _ src: String) -> Problem? {
        guard let m = src.firstMatch(of: /^---\n([\s\S]*?)\n---\n([\s\S]*)$/) else { return nil }
        var meta: [String: JSON] = [:]
        for line in m.output.1.split(separator: "\n") {
            guard let r = line.range(of: ": ") else { continue }
            meta[String(line[..<r.lowerBound])] = try? JSONDecoder().decode(JSON.self, from: Data(line[r.upperBound...].utf8))
        }
        let secs = sections(String(m.output.2))
        var starter = "", hints: [String] = [], keyPoints: [String] = [], solutions: [Solution] = []
        for (head, t) in secs.dropFirst() {
            let blocks = pyBlocks(t)
            let lines = t.split(separator: "\n").map(String.init)
            if head == "Starter" {
                starter = String(blocks.first?.dropLast() ?? "")
            } else if head == "Hints" {
                hints = lines.filter { $0.contains(#/^\d+\. /#) }.map { $0.replacing(/^\d+\.\s*/, with: "") }
            } else if head == "Key points" {
                keyPoints = lines.filter { $0.hasPrefix("- ") }.map { String($0.dropFirst(2)) }
            } else if head.hasPrefix("Solution:") {
                let parts = head.dropFirst("Solution:".count).components(separatedBy: " · ").map {
                    $0.trimmingCharacters(in: .whitespaces)
                }
                guard parts.count >= 4, let code = blocks.last else { continue }
                let notes = t.range(of: "```python\n" + code, options: .backwards).map { String(t[..<$0.lowerBound]) } ?? ""
                solutions.append(Solution(
                    id: parts[0], title: parts[1], time: parts[2], space: parts[3],
                    reference: parts.contains("reference"), slow: parts.contains("slow"),
                    code: code, notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)))
            }
        }
        return Problem(
            id: id, lc: meta["lc"]?.int, title: meta["title"]?.string ?? id,
            difficulty: Difficulty(rawValue: meta["difficulty"]?.string ?? "") ?? .medium,
            patterns: meta["patterns"]?.array.compactMap(\.string) ?? [],
            params: meta["entry"]?["params"]?.array.compactMap { $0["name"]?.string } ?? [],
            starter: starter, statement: secs[0].text, hints: hints, keyPoints: keyPoints, solutions: solutions)
    }

    static func problemHome(_ id: String) -> (module: Module, topic: Topic, role: Role)? {
        for m in modules() {
            for tid in m.topics {
                if let t = topic(tid), let ref = t.problems.first(where: { $0.id == id }) { return (m, t, ref.role) }
            }
        }
        return nil
    }
}

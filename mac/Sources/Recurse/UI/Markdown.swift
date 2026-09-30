// The markdown subset courses/dsa uses; ```viz blocks become visualizations.
import SwiftUI

enum Block {
    case heading(Int, String)
    case paragraph(String)
    case list(ordered: Bool, items: [String])
    case quote(String)
    case table(header: [String], rows: [[String]])
    case code(lang: String, text: String)
    case viz(String)
    case image(URL)
}

enum MD {
    static func blocks(_ src: String) -> [Block] {
        let lines = src.components(separatedBy: "\n")
        var out: [Block] = []
        var para: [String] = []
        var i = 0
        func flush() {
            if !para.isEmpty { out.append(.paragraph(para.joined(separator: "\n"))) }
            para = []
        }
        let listItem = #/^\s*(?:[-*]|(\d+)\.)\s+(.*)$/#
        while i < lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("```") {
                flush()
                let lang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var body: [String] = []
                i += 1
                while i < lines.count, !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    body.append(lines[i])
                    i += 1
                }
                let text = body.joined(separator: "\n")
                out.append(lang == "viz" ? .viz(text.trimmingCharacters(in: .whitespacesAndNewlines)) : .code(lang: lang, text: text))
            } else if trimmed.isEmpty {
                flush()
            } else if let m = trimmed.firstMatch(of: #/^(#{1,6})\s+(.*)$/#) {
                flush()
                out.append(.heading(m.output.1.count, String(m.output.2)))
            } else if let m = trimmed.wholeMatch(of: #/!\[[^\]]*\]\(([^)\s]+)[^)]*\)/#), let url = URL(string: String(m.output.1)) {
                flush()
                out.append(.image(url))
            } else if trimmed.hasPrefix("|"), i + 1 < lines.count, lines[i + 1].contains(#/^\s*\|?\s*:?-{3,}/#) {
                flush()
                let cells = { (l: String) in
                    l.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "|"))
                        .components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                }
                let header = cells(line)
                var rows: [[String]] = []
                i += 2
                while i < lines.count, lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("|") {
                    rows.append(cells(lines[i]))
                    i += 1
                }
                out.append(.table(header: header, rows: rows))
                continue
            } else if trimmed.hasPrefix(">") {
                flush()
                var q: [String] = []
                while i < lines.count, lines[i].trimmingCharacters(in: .whitespaces).hasPrefix(">") {
                    q.append(String(lines[i].trimmingCharacters(in: .whitespaces).dropFirst()).trimmingCharacters(in: .whitespaces))
                    i += 1
                }
                out.append(.quote(q.joined(separator: " ")))
                continue
            } else if let m = line.wholeMatch(of: listItem) {
                flush()
                let ordered = m.output.1 != nil
                var items = [String(m.output.2)]
                i += 1
                // continuation lines (indented, not a new item) join the current item; nested lists flatten
                while i < lines.count, !lines[i].trimmingCharacters(in: .whitespaces).isEmpty {
                    if let n = lines[i].wholeMatch(of: listItem) { items.append(String(n.output.2)) }
                    else if lines[i].hasPrefix(" ") { items[items.count - 1] += " " + lines[i].trimmingCharacters(in: .whitespaces) }
                    else { break }
                    i += 1
                }
                out.append(.list(ordered: ordered, items: items))
                continue
            } else {
                para.append(line)
            }
            i += 1
        }
        flush()
        return out
    }

    /// Inline markdown (bold, italic, `code`, links) plus the few HTML tags LeetCode statements carry.
    static func inline(_ s: String) -> AttributedString {
        let cleaned = s
            .replacing(#/<br\s*/?>/#, with: "\n")
            .replacing(#/<sup>(.*?)</sup>/#) { "^" + $0.output.1 }
            .replacing(#/<sub>(.*?)</sub>/#) { "_" + $0.output.1 }
            .replacing(#/</?[a-zA-Z][^>]*>/#, with: "")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
        var a = (try? AttributedString(markdown: cleaned, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            ?? AttributedString(cleaned)
        for run in a.runs where run.inlinePresentationIntent?.contains(.code) == true {
            a[run.range].backgroundColor = Color.primary.opacity(0.07)
            a[run.range].font = .system(.body, design: .monospaced).weight(.regular)
        }
        return a
    }
}

struct MarkdownView: View {
    let text: String
    var viz: [String: VizTrace] = [:]
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 10 : 14) {
            ForEach(Array(MD.blocks(text).enumerated()), id: \.offset) { _, b in
                block(b)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .textSelection(.enabled)
    }

    @ViewBuilder
    private func block(_ b: Block) -> some View {
        switch b {
        case .heading(let level, let s):
            Text(MD.inline(s))
                .font(level <= 2 ? .title3.weight(.semibold) : .headline)
                .padding(.top, level <= 2 && !compact ? 18 : 6)
                .id(level == 2 ? "h:" + s : "")
                .trackSection(level == 2 ? "h:" + s : "")
        case .paragraph(let s):
            Text(MD.inline(s)).lineSpacing(4).foregroundStyle(.primary.opacity(0.88))
        case .list(let ordered, let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(ordered ? "\(i + 1)." : "•").foregroundStyle(.secondary).monospacedDigit()
                            .frame(minWidth: 14, alignment: .trailing)
                        Text(MD.inline(item)).lineSpacing(3).foregroundStyle(.primary.opacity(0.88))
                    }
                }
            }
        case .quote(let s):
            Text(MD.inline(s)).foregroundStyle(.secondary).padding(.leading, 12)
                .overlay(alignment: .leading) { Rectangle().fill(.quaternary).frame(width: 3) }
        case .table(let header, let rows):
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow { ForEach(header.indices, id: \.self) { Text(MD.inline(header[$0])).fontWeight(.medium) } }
                Divider()
                ForEach(rows.indices, id: \.self) { r in
                    GridRow { ForEach(rows[r].indices, id: \.self) { Text(MD.inline(rows[r][$0])).foregroundStyle(.primary.opacity(0.85)) } }
                }
            }
            .font(.callout)
            .padding(12)
            .background(.canvas.opacity(0.6), in: .rect(cornerRadius: 12, style: .continuous))
        case .code(let lang, let s):
            CodeBlock(code: s, python: lang == "python")
        case .viz(let name):
            if let t = viz[name] { VizView(trace: t) } else { Text("Missing visualization: \(name)").foregroundStyle(.danger) }
        case .image(let url):
            AsyncImage(url: url) { img in img.resizable().scaledToFit().frame(maxWidth: 420, maxHeight: 260) } placeholder: {
                ProgressView().frame(height: 60)
            }
            .clipShape(.rect(cornerRadius: 6))
        }
    }
}

struct CodeBlock: View {
    let code: String
    var python = true

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(python ? Python.highlighted(code) : AttributedString(code))
                .font(.system(size: 12.5, design: .monospaced))
                .lineSpacing(3)
                .textSelection(.enabled)
                .padding(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.canvas.opacity(0.6), in: .rect(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(.hairline))
    }
}

enum Python {
    enum Kind { case keyword, builtin, string, comment, number, definition }

    static let keywords: Set<String> = [
        "False", "None", "True", "and", "as", "assert", "async", "await", "break", "class", "continue", "def", "del",
        "elif", "else", "except", "finally", "for", "from", "global", "if", "import", "in", "is", "lambda",
        "nonlocal", "not", "or", "pass", "raise", "return", "try", "while", "with", "yield", "self",
    ]
    static let builtins: Set<String> = [
        "len", "range", "print", "min", "max", "sum", "sorted", "enumerate", "zip", "list", "dict", "set", "int",
        "str", "float", "bool", "abs", "map", "filter", "reversed", "any", "all", "tuple", "heapq", "deque",
        "defaultdict", "Counter", "Optional", "List", "isinstance", "ord", "chr", "divmod", "pow", "iter", "next",
    ]

    // one pass: strings and comments first so keywords inside them aren't colored
    nonisolated(unsafe) private static let token = #/("""[\s\S]*?"""|'''[\s\S]*?'''|"(?:\\.|[^"\\\n])*"|'(?:\\.|[^'\\\n])*'|#[^\n]*|\b\d+(?:\.\d+)?\b|\b[A-Za-z_]\w*\b)/#

    static func spans(_ code: String) -> [(Range<String.Index>, Kind)] {
        var out: [(Range<String.Index>, Kind)] = []
        var afterDef = false
        for m in code.matches(of: token) {
            let s = m.output.1
            let kind: Kind?
            if s.hasPrefix("#") { kind = .comment }
            else if s.hasPrefix("\"") || s.hasPrefix("'") { kind = .string }
            else if s.first!.isNumber { kind = .number }
            else if afterDef { kind = .definition }
            else if keywords.contains(String(s)) { kind = .keyword }
            else if builtins.contains(String(s)) { kind = .builtin }
            else { kind = nil }
            afterDef = s == "def" || s == "class"
            if let kind { out.append((m.range, kind)) }
        }
        return out
    }

    static func color(_ k: Kind) -> NSColor {
        switch k {
        case .keyword: CodeColors.keyword
        case .builtin: CodeColors.builtin
        case .string: CodeColors.string
        case .comment: CodeColors.comment
        case .number: CodeColors.number
        case .definition: CodeColors.definition
        }
    }

    static func highlighted(_ code: String) -> AttributedString {
        var a = AttributedString(code)
        a.foregroundColor = Color(nsColor: CodeColors.text)
        for (r, k) in spans(code) {
            guard let lo = AttributedString.Index(r.lowerBound, within: a), let hi = AttributedString.Index(r.upperBound, within: a) else { continue }
            a[lo..<hi].foregroundColor = Color(nsColor: color(k))
        }
        return a
    }
}

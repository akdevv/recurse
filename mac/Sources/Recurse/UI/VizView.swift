import SwiftUI

struct VizView: View {
    let trace: VizTrace
    @Environment(Activity.self) private var activity
    @State private var i = 0
    @State private var playing = false

    private var n: Int { trace.steps.count }
    private var step: JSON { trace.steps[min(i, n - 1)] }
    private var atEnd: Bool { i >= n - 1 }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 18) {
                Text(trace.title).font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                ScrollView(.horizontal, showsIndicators: false) {
                    VizStage(view: trace.view, step: step).padding(.horizontal, 4).frame(maxWidth: .infinity)
                }
                if let vars = step["vars"]?.object, !vars.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(vars.keys.sorted(), id: \.self) { k in
                            Text("\(Text("\(k) = ").foregroundStyle(.secondary))\(Text(vars[k]!.json))")
                                .font(.system(size: 11, design: .monospaced))
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(.background, in: .rect(cornerRadius: 6))
                                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
                        }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 64) // room for the floating controls
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(DotGrid())
            .overlay(alignment: .bottom) { controls.padding(12) }

            GeometryReader { g in
                Capsule().fill(Color.brand).frame(width: g.size.width * Double(i + 1) / Double(max(1, n)))
            }
            .frame(height: 2)
            .background(.quaternary)

            Text(step["caption"]?.string ?? "").font(.callout).lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .background(.surface)
        .clipShape(.rect(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.hairline))
        .animation(.easeOut(duration: 0.25), value: i)
        .task(id: playing) {
            guard playing else { return }
            let release = activity.hold() // watching counts as active time
            defer { release() }
            while playing, !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(1100))
                if !NSApp.isActive { playing = false; break }
                if atEnd { playing = false } else { i += 1 }
            }
        }
    }

    private var controls: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                HStack(spacing: 2) {
                    Button { go(i - 1) } label: { Image(systemName: "chevron.left").frame(width: 22, height: 22) }.disabled(i == 0)
                    Text("\(i + 1) / \(n)").font(.caption.monospacedDigit()).foregroundStyle(.secondary).frame(minWidth: 44)
                    Button { go(i + 1) } label: { Image(systemName: "chevron.right").frame(width: 22, height: 22) }.disabled(atEnd)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8).padding(.vertical, 5)
                .glassEffect(.regular.interactive(), in: .capsule)
                Button { toggle() } label: {
                    Image(systemName: playing ? "pause.fill" : atEnd ? "arrow.counterclockwise" : "play.fill")
                        .contentTransition(.symbolEffect(.replace)).frame(width: 18, height: 22)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .help(playing ? "Pause" : atEnd ? "Replay" : "Play")
            }
        }
    }

    private func go(_ to: Int) {
        playing = false
        i = max(0, min(n - 1, to))
    }

    private func toggle() {
        if atEnd { i = 0 }
        playing.toggle()
    }
}

/// The drawing for one step (separate from the controls so it can be rendered on its own).
struct VizStage: View {
    let view: String
    let step: JSON

    var body: some View {
        switch view {
        case "array":
            if let stack = step["stack"] {
                HStack(alignment: .bottom, spacing: 36) {
                    ArrayViz(s: step)
                    StackViz(frames: stack.array.map(\.text), label: step["stackLabel"]?.string ?? "stack", small: true)
                }
            } else { ArrayViz(s: step) }
        case "stack": StackViz(frames: step["stack"]?.array.map(\.text) ?? [], label: step["stackLabel"]?.string ?? "call stack")
        case "grid": GridViz(s: step)
        case "list": ListViz(s: step)
        case "graph": GraphViz(s: step)
        case "tree":
            HStack(alignment: .top, spacing: 28) {
                TreeViz(s: step)
                if let stack = step["stack"] { StackViz(frames: stack.array.map(\.text), label: "call stack", small: true) }
            }
        default: Text("Unknown view \(view)").foregroundStyle(.secondary)
        }
    }
}

private struct DotGrid: View {
    var body: some View {
        Canvas { ctx, size in
            for x in stride(from: 8.0, to: size.width, by: 16) {
                for y in stride(from: 8.0, to: size.height, by: 16) {
                    ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.2, height: 1.2)), with: .color(.primary.opacity(0.12)))
                }
            }
        }
    }
}

// MARK: pieces

private let mono = Font.system(size: 13, design: .monospaced)

private struct Cell: View {
    let text: String
    var on = false
    var dim = false
    var round = false
    var body: some View {
        Text(text).font(mono)
            .frame(minWidth: 40, minHeight: 40).padding(.horizontal, text.count > 3 ? 6 : 0)
            .background(on ? Color.brand.opacity(0.18) : Color.primary.opacity(0.06), in: .rect(cornerRadius: round ? 20 : 8))
            .overlay(RoundedRectangle(cornerRadius: round ? 20 : 8).strokeBorder(on ? Color.brand : Color.primary.opacity(0.15)))
            .foregroundStyle(on ? Color.brand : .primary)
            .opacity(dim ? 0.25 : 1)
            .strikethrough(dim && !round)
    }
}

private func pointerTags(_ s: JSON, at k: Int) -> some View {
    let names = s["pointers"]?.object.filter { $0.value.int == k }.keys.sorted() ?? []
    return VStack(spacing: 0) {
        ForEach(names, id: \.self) { Text("↑ \($0)") }
    }
    .font(.system(size: 11, weight: .medium, design: .monospaced)).foregroundStyle(.warning).frame(minHeight: 14)
}

private func intSet(_ j: JSON?) -> Set<Int> { Set(j?.array.compactMap(\.int) ?? []) }
private func strSet(_ j: JSON?) -> Set<String> { Set(j?.array.compactMap { $0.string ?? $0.int.map(String.init) } ?? []) }

private struct ArrayViz: View {
    let s: JSON
    var body: some View {
        let arr = s["array"]?.array ?? []
        let hi = intSet(s["highlight"]), dim = intSet(s["dim"])
        if arr.isEmpty { Text("(empty)").foregroundStyle(.secondary) } else {
            HStack(alignment: .top, spacing: 6) {
                ForEach(arr.indices, id: \.self) { k in
                    VStack(spacing: 5) {
                        Cell(text: arr[k].text, on: hi.contains(k), dim: dim.contains(k))
                        Text("\(k)").font(.system(size: 10, design: .monospaced)).foregroundStyle(.tertiary)
                        pointerTags(s, at: k)
                    }
                }
            }
        }
    }
}

private struct StackViz: View {
    let frames: [String]
    var label = "call stack"
    var small = false
    var body: some View {
        VStack(spacing: 5) {
            ForEach(frames.indices.reversed(), id: \.self) { k in
                let top = k == frames.count - 1
                Text(frames[k]).font(.system(size: 12, design: .monospaced))
                    .frame(maxWidth: .infinity).padding(.vertical, 5)
                    .background(top ? Color.warning.opacity(0.12) : Color.primary.opacity(0.06), in: .rect(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(top ? Color.warning.opacity(0.5) : Color.primary.opacity(0.15)))
                    .foregroundStyle(top ? Color.warning : .primary)
            }
            Divider()
            Text(label.uppercased()).font(.system(size: 10)).tracking(1).foregroundStyle(.secondary)
        }
        .frame(width: small ? 160 : 240)
    }
}

private struct GridViz: View {
    let s: JSON
    var body: some View {
        let grid = s["grid"]?.array.map(\.array) ?? []
        let key = { (c: JSON) in "\(c[0]?.int ?? -1),\(c[1]?.int ?? -1)" }
        let hi = Set(s["highlight"]?.array.map(key) ?? []), dim = Set(s["dim"]?.array.map(key) ?? [])
        let ptrs = s["pointers"]?.object ?? [:]
        let compact = s["compact"] == .bool(true)
        let size: CGFloat = compact ? 22 : 40
        VStack(spacing: compact ? 2 : 6) {
            ForEach(grid.indices, id: \.self) { r in
                HStack(spacing: compact ? 2 : 6) {
                    Text("\(r)").font(.system(size: 10, design: .monospaced)).foregroundStyle(.tertiary).frame(width: 16, alignment: .trailing)
                    ForEach(grid[r].indices, id: \.self) { c in
                        let v = grid[r][c].text, k = "\(r),\(c)", on = hi.contains(k)
                        let here = ptrs.contains { $0.value[0]?.int == r && $0.value[1]?.int == c }
                        let filled = v == "█"
                        Text(filled ? "" : v).font(.system(size: compact ? 10 : 13, design: .monospaced))
                            .frame(width: size, height: size)
                            .background(filled ? (on ? Color.brand.opacity(0.7) : Color.primary.opacity(0.3))
                                               : on ? Color.brand.opacity(0.18) : Color.primary.opacity(0.06),
                                        in: .rect(cornerRadius: compact ? 4 : 8))
                            .overlay(RoundedRectangle(cornerRadius: compact ? 4 : 8)
                                .strokeBorder(here ? Color.warning : on ? Color.brand : Color.primary.opacity(0.15), lineWidth: here ? 2 : 1))
                            .foregroundStyle(on ? Color.brand : .primary)
                            .opacity(dim.contains(k) ? 0.25 : 1)
                    }
                }
            }
            if !ptrs.isEmpty {
                HStack(spacing: 12) {
                    ForEach(ptrs.keys.sorted(), id: \.self) { n in
                        Text("\(n) = (\(ptrs[n]![0]?.text ?? ""), \(ptrs[n]![1]?.text ?? ""))")
                    }
                }
                .font(.system(size: 11, weight: .medium, design: .monospaced)).foregroundStyle(.warning).padding(.top, 4)
            }
        }
    }
}

/// Linked list: `links[i]` = index node i points to (null = None); default i + 1. Far links (cycles) are listed below.
private struct ListViz: View {
    let s: JSON
    var body: some View {
        let vals = s["nodes"]?.array ?? []
        let n = vals.count
        let links: [Int?] = s["links"].map { $0.array.map(\.int) } ?? (0..<n).map { $0 + 1 < n ? $0 + 1 : nil }
        let hi = intSet(s["highlight"]), dim = intSet(s["dim"])
        let far = links.enumerated().compactMap { i, t in t.flatMap { $0 != i + 1 && $0 != i - 1 ? (i, $0) : nil } }
        if n == 0 { Text("(empty)").foregroundStyle(.secondary) } else {
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<n, id: \.self) { i in
                        VStack(spacing: 5) {
                            Cell(text: vals[i].text, on: hi.contains(i), dim: dim.contains(i), round: true)
                            if links[i] == nil && i < n - 1 {
                                Text("↓ None").font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary)
                            }
                            pointerTags(s, at: i)
                        }
                        if i + 1 < n {
                            let arrow = links[i] == i + 1 && links[i + 1] == i ? "⇄" : links[i] == i + 1 ? "→" : links[i + 1] == i ? "←" : " "
                            Text(arrow).font(.system(size: 15, design: .monospaced)).foregroundStyle(.secondary).frame(width: 32, height: 40)
                        }
                    }
                    if links[n - 1] == nil {
                        Text("→ None").font(.system(size: 11, design: .monospaced)).foregroundStyle(.tertiary).frame(height: 40).padding(.leading, 6)
                    }
                }
                ForEach(far, id: \.0) { i, t in
                    Text("\(vals[i].text) ↩ \(vals[t].text) (index \(t))").font(.system(size: 11, design: .monospaced)).foregroundStyle(.warning)
                }
            }
        }
    }
}

// recursion call trees (fib(3)=2) read best with the value inline; other trees get a tag below the node
private struct TreeViz: View {
    let s: JSON
    var body: some View {
        let nodes = s["nodes"]?.array ?? []
        let values = s["values"]?.object ?? [:]
        let marked = strSet(s["highlight"])
        let active = s["active"]?.string
        let id = { (n: JSON) in n["id"]?.string ?? n["id"]?.text ?? "" }
        let parent = { (n: JSON) -> String? in n["parent"].flatMap { $0.isNull ? nil : ($0.string ?? $0.text) } }
        let inline = { (label: String) in label.contains(#/^\w+\(/#) }
        let label = { (n: JSON) -> String in
            let l = n["label"]?.text ?? id(n)
            if let v = values[id(n)], inline(l) { return l.replacing(#/^fib/#, with: "f") + "=" + v.text }
            return l
        }
        // layout: leaves get consecutive x slots in DFS order, parents sit centered over their children
        var kids: [String: [String]] = [:]
        for n in nodes { if let p = parent(n) { kids[p, default: []].append(id(n)) } }
        var pos: [String: CGPoint] = [:]
        var slot = 0.0
        func place(_ nid: String, _ depth: Int) -> Double {
            let c = kids[nid] ?? []
            let x: Double
            if c.isEmpty { x = slot; slot += 1 } else { x = c.map { place($0, depth + 1) }.reduce(0, +) / Double(c.count) }
            pos[nid] = CGPoint(x: x, y: Double(depth))
            return x
        }
        for r in nodes where parent(r) == nil { _ = place(id(r), 0) }
        let boxW = { (n: JSON) in max(60, CGFloat(label(n).count) * 7.5 + 14) }
        let W = max(68, (nodes.map(boxW).max() ?? 60) + 8), H: CGFloat = 58
        let maxX = pos.values.map(\.x).max() ?? 0, maxY = pos.values.map(\.y).max() ?? 0
        let pt = { (nid: String) in CGPoint(x: pos[nid, default: .zero].x * W + W / 2, y: pos[nid, default: .zero].y * H + 20) }
        let visible = nodes.filter { $0["hidden"] != .bool(true) }

        return ZStack(alignment: .topLeading) {
            Canvas { ctx, _ in
                for n in visible { if let p = parent(n) {
                    var path = Path()
                    path.move(to: pt(p))
                    path.addLine(to: pt(id(n)))
                    ctx.stroke(path, with: .color(.primary.opacity(0.2)))
                } }
            }
            ForEach(visible.indices, id: \.self) { k in
                let n = visible[k], nid = id(n)
                let isActive = active == nid, done = s["highlight"] != nil ? marked.contains(nid) : values[nid] != nil
                let tint: Color = isActive ? .warning : done ? .brand : .primary
                VStack(spacing: 3) {
                    Text(label(n)).font(.system(size: 11, design: .monospaced))
                        .frame(width: boxW(n), height: 26)
                        .background(isActive || done ? tint.opacity(0.14) : .clear, in: .rect(cornerRadius: 7))
                        .background(Color(nsColor: .windowBackgroundColor), in: .rect(cornerRadius: 7)) // hide edges behind the box
                        .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(isActive || done ? tint.opacity(0.7) : Color.primary.opacity(0.2)))
                        .foregroundStyle(tint)
                    if let v = values[nid], !inline(n["label"]?.text ?? "") {
                        Text(v.text).font(.system(size: 10, design: .monospaced)).foregroundStyle(.warning)
                    }
                }
                .position(x: pt(nid).x, y: pt(nid).y + (values[nid] != nil && !inline(n["label"]?.text ?? "") ? 8 : 0))
            }
        }
        .frame(width: (maxX + 1) * W, height: (maxY + 1) * H + 24)
    }
}

/// Fixed-layout graph: nodes {id, label?, x, y} in grid units, edges {from, to, w?}.
private struct GraphViz: View {
    let s: JSON
    var body: some View {
        let nodes = s["nodes"]?.array ?? []
        let edges = s["edges"]?.array ?? []
        let directed = s["directed"] == .bool(true)
        let hi = strSet(s["highlight"]), dim = strSet(s["dim"])
        let values = s["values"]?.object ?? [:]
        let active = s["active"]?.text
        let ek = { (a: String, b: String) in "\(a)>\(b)" }
        let ehi = Set((s["edgeHighlight"]?.array ?? []).flatMap { e -> [String] in
            let a = e[0]?.text ?? "", b = e[1]?.text ?? ""
            return directed ? [ek(a, b)] : [ek(a, b), ek(b, a)]
        })
        let S: CGFloat = 70, R: CGFloat = 17
        let at = Dictionary(nodes.map { n in (n["id"]?.text ?? "", CGPoint(x: (n["x"]?.number ?? 0) * S + 30, y: (n["y"]?.number ?? 0) * S + 26)) },
                            uniquingKeysWith: { a, _ in a })
        let W = (nodes.compactMap { $0["x"]?.number }.max() ?? 0) * S + 100
        let H = (nodes.compactMap { $0["y"]?.number }.max() ?? 0) * S + 64

        return ZStack(alignment: .topLeading) {
            Canvas { ctx, _ in
                for e in edges {
                    let from = e["from"]?.text ?? "", to = e["to"]?.text ?? ""
                    guard let a = at[from], let b = at[to] else { continue }
                    let dx = b.x - a.x, dy = b.y - a.y, len = max(1, hypot(dx, dy))
                    let tip = R + (directed ? 3 : 0)
                    let p1 = CGPoint(x: a.x + dx / len * R, y: a.y + dy / len * R)
                    let p2 = CGPoint(x: b.x - dx / len * tip, y: b.y - dy / len * tip)
                    let on = ehi.contains(ek(from, to))
                    let color: Color = on ? .brand : .primary.opacity(0.25)
                    var line = Path()
                    line.move(to: p1)
                    line.addLine(to: p2)
                    ctx.stroke(line, with: .color(color), lineWidth: on ? 2.5 : 1.2)
                    if directed {
                        let ux = dx / len, uy = dy / len
                        var head = Path()
                        head.move(to: p2)
                        head.addLine(to: CGPoint(x: p2.x - ux * 8 - uy * 4, y: p2.y - uy * 8 + ux * 4))
                        head.addLine(to: CGPoint(x: p2.x - ux * 8 + uy * 4, y: p2.y - uy * 8 - ux * 4))
                        head.closeSubpath()
                        ctx.fill(head, with: .color(color))
                    }
                    if let w = e["w"] {
                        ctx.draw(Text(w.text).font(.system(size: 10, design: .monospaced)).foregroundStyle(on ? Color.brand : .secondary),
                                 at: CGPoint(x: (a.x + b.x) / 2 + dy / len * 10, y: (a.y + b.y) / 2 - dx / len * 10))
                    }
                }
            }
            ForEach(nodes.indices, id: \.self) { k in
                let n = nodes[k], nid = n["id"]?.text ?? "", p = at[nid] ?? .zero
                let isActive = active == nid, on = hi.contains(nid)
                let tint: Color = isActive ? .warning : on ? .brand : .primary
                Text(n["label"]?.text ?? nid).font(.system(size: 12, design: .monospaced))
                    .frame(width: R * 2, height: R * 2)
                    .background(Circle().fill(isActive || on ? tint.opacity(0.16) : .clear))
                    .background(Circle().fill(Color(nsColor: .windowBackgroundColor)))
                    .overlay(Circle().strokeBorder(isActive || on ? tint : Color.primary.opacity(0.25)))
                    .foregroundStyle(tint)
                    .overlay(alignment: .topTrailing) {
                        if let v = values[nid] {
                            Text(v.text).font(.system(size: 10, design: .monospaced)).foregroundStyle(.warning).fixedSize().offset(x: 14, y: -8)
                        }
                    }
                    .opacity(dim.contains(nid) ? 0.3 : 1)
                    .position(p)
            }
        }
        .frame(width: W, height: H)
    }
}

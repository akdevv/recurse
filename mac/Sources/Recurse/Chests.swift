// Mystery chests: earned by boss wins and clean first solves, never bought. Port of web/server/chests.ts;
// rewards are stored in the same JSON shape, so both apps read each other's chests.
import SwiftUI

enum ChestReward: Codable, Equatable {
    case xp(Int)
    case freeze
    case collectible(id: String, name: String, desc: String)

    private enum K: String, CodingKey { case kind, amount, id, name, desc }

    init(from d: Decoder) throws {
        let c = try d.container(keyedBy: K.self)
        switch try c.decode(String.self, forKey: .kind) {
        case "xp": self = .xp(try c.decode(Int.self, forKey: .amount))
        case "freeze": self = .freeze
        default: self = .collectible(id: try c.decode(String.self, forKey: .id), name: try c.decode(String.self, forKey: .name),
                                     desc: try c.decode(String.self, forKey: .desc))
        }
    }

    func encode(to e: Encoder) throws {
        var c = e.container(keyedBy: K.self)
        switch self {
        case .xp(let n): try c.encode("xp", forKey: .kind); try c.encode(n, forKey: .amount)
        case .freeze: try c.encode("freeze", forKey: .kind)
        case .collectible(let id, let name, let desc):
            try c.encode("collectible", forKey: .kind)
            try c.encode(id, forKey: .id); try c.encode(name, forKey: .name); try c.encode(desc, forKey: .desc)
        }
    }

    var title: String {
        switch self {
        case .xp(let n): "+\(n) XP"
        case .freeze: "Streak freeze"
        case .collectible(_, let name, _): name
        }
    }
    var subtitle: String {
        switch self {
        case .xp: "Bonus XP"
        case .freeze: "Covers one missed day in a week (you can bank 2)"
        case .collectible(_, _, let desc): desc
        }
    }
    var icon: String {
        switch self {
        case .xp: "sparkles"
        case .freeze: "snowflake"
        case .collectible(let id, _, _): Collectible.all.first { $0.id == id }?.icon ?? "sparkles"
        }
    }
    var tint: Color {
        switch self {
        case .xp: .brand
        case .freeze: .success
        case .collectible: .warning
        }
    }
}

struct Collectible: Identifiable {
    let id, name, desc, icon: String

    static let all = [
        Collectible(id: "golden-pointer", name: "Golden Pointer", desc: "Never off by one.", icon: "cursorarrow"),
        Collectible(id: "rubber-duck", name: "Rubber Duck", desc: "Listens to every bug, judges none.", icon: "bird"),
        Collectible(id: "lucky-pivot", name: "Lucky Pivot", desc: "Always splits the array in half.", icon: "suit.club.fill"),
        Collectible(id: "bottomless-stack", name: "Bottomless Stack", desc: "Has never overflowed.", icon: "square.stack.3d.up"),
        Collectible(id: "perfect-hash", name: "Perfect Hash", desc: "Zero collisions, every time.", icon: "number"),
        Collectible(id: "big-o-mug", name: "Big-O Mug", desc: "Holds exactly O(1) coffee.", icon: "cup.and.saucer"),
        Collectible(id: "memo-pad", name: "Memo Pad", desc: "Never solves the same thing twice.", icon: "note.text"),
        Collectible(id: "dijkstra-compass", name: "Dijkstra's Compass", desc: "Points to the closest node.", icon: "safari"),
        Collectible(id: "balanced-bonsai", name: "Balanced Bonsai", desc: "Height O(log n), always.", icon: "tree"),
        Collectible(id: "xor-coin", name: "XOR Coin", desc: "Flip it twice, it cancels out.", icon: "circle.lefthalf.filled"),
        Collectible(id: "trie-leaf", name: "Trie Leaf", desc: "Shares its prefixes generously.", icon: "leaf"),
        Collectible(id: "tortoise-hare", name: "Tortoise & Hare", desc: "They always meet in the loop.", icon: "hare"),
    ]
}

struct ChestRow: Identifiable {
    let id: Int
    let ts, source, ref: String
    let openedAt: String?
    let reward: ChestReward?
}

extension Store {
    static let solveChestChance = 0.25

    @discardableResult
    func earnChest(_ source: String, _ ref: String) -> Int {
        let id = _db.run("INSERT INTO chests (ts, source, ref) VALUES (?, ?, ?)", Dates.iso(), source, ref)
        chestQueue.append(id) // pops the opening sheet wherever you are
        return id
    }

    func maybeSolveChest(_ pid: String, _ o: Outcome) {
        if o == .solved && Double.random(in: 0..<1) < Store.solveChestChance { earnChest("solve", pid) }
    }

    func chests() -> [ChestRow] {
        db.all("SELECT * FROM chests ORDER BY id DESC").map {
            ChestRow(id: $0.int("id")!, ts: $0.str("ts")!, source: $0.str("source")!, ref: $0.str("ref")!,
                     openedAt: $0.str("opened_at"),
                     reward: $0.str("reward").flatMap { try? JSONDecoder().decode(ChestReward.self, from: Data($0.utf8)) })
        }
    }

    var chestsWaiting: Int { db.one("SELECT COUNT(*) AS n FROM chests WHERE opened_at IS NULL")?.int("n") ?? 0 }

    func ownedCollectibles() -> Set<String> {
        Set(chests().compactMap { if case .collectible(let id, _, _) = $0.reward { id } else { nil } })
    }

    private func roll(_ source: String) -> ChestReward {
        let boss = source == "boss"
        let x = Double.random(in: 0..<1)
        if x < (boss ? 0.35 : 0.15) {
            let have = ownedCollectibles()
            if let c = Collectible.all.filter({ !have.contains($0.id) }).randomElement() {
                return .collectible(id: c.id, name: c.name, desc: c.desc)
            }
        } else if x < (boss ? 0.6 : 0.4), me().streak.freezes < Streak.maxFreezes {
            return .freeze
        }
        return .xp(boss ? 50 + 10 * Int.random(in: 0..<8) : 15 + 5 * Int.random(in: 0..<6))
    }

    func openChest(_ id: Int) -> ChestReward? {
        guard let c = chests().first(where: { $0.id == id }) else { return nil }
        if let r = c.reward { return r }
        let reward = roll(c.source)
        _db.run("UPDATE chests SET opened_at = ?, reward = ? WHERE id = ?", Dates.iso(),
                String(decoding: try! JSONEncoder().encode(reward), as: UTF8.self), id)
        if case .xp(let n) = reward { addXp(n, "chest", String(id)) }
        changed()
        return reward
    }
}

// MARK: views

/// The opening sheet: a closed chest, then the reward it held.
struct ChestSheet: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    let id: Int
    @State private var reward: ChestReward?
    @State private var shake = false

    var body: some View {
        VStack(spacing: 18) {
            if let r = reward {
                Image(systemName: r.icon).font(.system(size: 36)).foregroundStyle(r.tint)
                    .frame(width: 88, height: 88).glassEffect(.regular.tint(r.tint.opacity(0.25)), in: .rect(cornerRadius: 24, style: .continuous))
                    .transition(.scale.combined(with: .opacity))
                VStack(spacing: 4) {
                    if case .collectible = r { Text("Rare collectible").font(.caption).foregroundStyle(.secondary) }
                    else { Text("You found").font(.caption).foregroundStyle(.secondary) }
                    Text(r.title).font(.title2.weight(.semibold))
                    Text(r.subtitle).font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                Button("Nice") { dismiss() }.buttonStyle(.glassProminent).controlSize(.large).keyboardShortcut(.defaultAction)
            } else {
                Image(systemName: "shippingbox.fill").font(.system(size: 36)).foregroundStyle(.warning)
                    .frame(width: 88, height: 88).glassEffect(.regular.tint(Color.warning.opacity(0.2)), in: .rect(cornerRadius: 24, style: .continuous))
                    .rotationEffect(.degrees(shake ? 4 : -4))
                    .animation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true), value: shake)
                    .onAppear { shake = true }
                VStack(spacing: 4) {
                    Text("Mystery chest").font(.title2.weight(.semibold))
                    Text("Earned by your effort. Bonus XP, a streak freeze, or a rare collectible.")
                        .font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                HStack {
                    Button("Later") { dismiss() }.keyboardShortcut(.cancelAction).buttonStyle(.glass)
                    Button("Open it") { withAnimation(.spring(duration: 0.4)) { reward = store.openChest(id) } }
                        .buttonStyle(.glassProminent).keyboardShortcut(.defaultAction)
                }
                .controlSize(.large)
            }
        }
        .padding(32)
        .frame(width: 340)
    }
}

struct ChestsView: View {
    @Environment(Store.self) private var store
    @State private var opening: Int?

    var body: some View {
        let rows = store.chests()
        let unopened = rows.filter { $0.openedAt == nil }
        let opened = rows.filter { $0.openedAt != nil }.prefix(20)
        let owned = store.ownedCollectibles()

        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    header("Waiting to be opened", "Every boss win drops one; a clean first solve has a 1 in 4 chance")
                    if unopened.isEmpty {
                        Label("No chests right now. Win a boss fight or solve something without hints for a chance at one.", systemImage: "shippingbox")
                            .foregroundStyle(.secondary).card()
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 12)], spacing: 12) {
                            ForEach(unopened) { c in
                                HStack(spacing: 12) {
                                    Image(systemName: "shippingbox.fill").foregroundStyle(.warning).font(.title3)
                                        .frame(width: 40, height: 40).background(Color.warning.opacity(0.12), in: .rect(cornerRadius: 10))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(c.source == "boss" ? "Boss chest" : "Solve chest").fontWeight(.medium).fixedSize()
                                        Text("Earned \(short(c.ts))").font(.caption).foregroundStyle(.secondary).fixedSize()
                                    }
                                    Spacer()
                                    Button("Open") { opening = c.id }.buttonStyle(.glassProminent)
                                }
                                .card(padding: 12)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    header("Collectibles", "\(owned.count)/\(Collectible.all.count) found · only from chests")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                        ForEach(Collectible.all) { c in
                            let have = owned.contains(c.id)
                            VStack(spacing: 8) {
                                Group {
                                    if have { Image(systemName: c.icon).font(.title2).foregroundStyle(.warning) }
                                    else { Text("?").font(.title2.weight(.semibold)).foregroundStyle(.quaternary) }
                                }
                                .frame(width: 48, height: 48)
                                .background((have ? Color.warning : .primary).opacity(have ? 0.12 : 0.05), in: .rect(cornerRadius: 12))
                                Text(have ? c.name : "Undiscovered").font(.callout.weight(.medium)).foregroundStyle(have ? .primary : .secondary)
                                Text(have ? c.desc : "Keep opening chests").font(.caption).foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center).lineLimit(2, reservesSpace: true)
                            }
                            .frame(maxWidth: .infinity)
                            .card(padding: 14)
                        }
                    }
                }

                if !opened.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        header("Recent finds", nil)
                        VStack(spacing: 0) {
                            ForEach(Array(opened.enumerated()), id: \.element.id) { i, c in
                                if let r = c.reward {
                                    HStack(spacing: 10) {
                                        Image(systemName: r.icon).foregroundStyle(r.tint).frame(width: 28, height: 28)
                                            .background(.quaternary, in: .rect(cornerRadius: 7))
                                        Text(r.title)
                                        Spacer()
                                        Label(short(c.openedAt ?? c.ts), systemImage: c.source == "boss" ? "figure.fencing" : "chevron.left.forwardslash.chevron.right")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 7)
                                    if i < opened.count - 1 { Divider() }
                                }
                            }
                        }
                        .card(padding: 12)
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity)
        }
        .sheet(item: Binding(get: { opening.map(SheetID.init) }, set: { opening = $0?.id })) { ChestSheet(id: $0.id) }
    }

    private func header(_ title: String, _ sub: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title).font(.headline)
            if let sub { Text(sub).font(.caption).foregroundStyle(.secondary) }
        }
    }
}

struct SheetID: Identifiable { let id: Int }

func short(_ iso: String) -> String { Dates.fromIso(iso)?.formatted(.dateTime.day().month()) ?? "" }

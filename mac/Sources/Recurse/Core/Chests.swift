// Rewards are stored in the web app's JSON shape.
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
    let ts, source: String
    let openedAt: String?
    let reward: ChestReward?
}

extension Store {
    static let solveChestChance = 0.25

    @discardableResult
    func earnChest(_ source: String, _ ref: String) -> Int {
        let id = _db.run("INSERT INTO chests (ts, source, ref) VALUES (?, ?, ?)", Dates.iso(), source, ref)
        chestQueue.append(id)
        return id
    }

    func maybeSolveChest(_ pid: String, _ o: Outcome) {
        if o == .solved && Double.random(in: 0..<1) < Store.solveChestChance { earnChest("solve", pid) }
    }

    func chests() -> [ChestRow] {
        db.all("SELECT * FROM chests ORDER BY id DESC").map {
            ChestRow(id: $0.int("id")!, ts: $0.str("ts")!, source: $0.str("source")!,
                     openedAt: $0.str("opened_at"),
                     reward: $0.json("reward"))
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
        _db.run("UPDATE chests SET opened_at = ?, reward = ? WHERE id = ?", Dates.iso(), reward.jsonText, id)
        if case .xp(let n) = reward { addXp(n, "chest", String(id)) }
        changed()
        return reward
    }
}

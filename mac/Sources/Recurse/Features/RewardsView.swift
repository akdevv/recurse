import SwiftUI

struct RewardsView: View {
    @Environment(Store.self) private var store
    @AppStorage("rewardsTab") private var tab = "path"

    var body: some View {
        let path = store.rewardPath()
        let badges = store.badges()
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 14) {
                    Group {
                        if tab == "trophies" { Medal(icon: "trophy.fill", metal: .gold, size: 52) }
                        else { ArtImage(name: tab == "chests" ? "chest" : "gift", size: 48).shadow(color: .black.opacity(0.35), radius: 8, y: 4) }
                    }
                    .frame(width: 52, height: 52)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Rewards").font(.title2.weight(.semibold))
                        Text(subtitle).font(.callout).foregroundStyle(.muted)
                            .contentTransition(.opacity).animation(.snappy, value: tab)
                    }
                    Spacer(minLength: 20)
                    Segments(selection: $tab, options: [
                        ("path", "Path \(path.filter { $0.status != .locked }.count)/\(path.count)"),
                        ("trophies", "Trophies \(badges.reduce(0) { $0 + $1.tier })/\(badges.reduce(0) { $0 + $1.tiers.count })"),
                        ("chests", store.chestsWaiting > 0 ? "Chests · \(store.chestsWaiting) new" : "Chests"),
                    ])
                }
                switch tab {
                case "trophies": TrophiesTab(badges: badges)
                case "chests": ChestsView()
                default: PathTab(path: path)
                }
            }
            .padding(28)
            .frame(maxWidth: 1000)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Rewards")
    }

    private var subtitle: String {
        switch tab {
        case "trophies": "Earned by effort, kept for good. Each one has bronze, silver and gold."
        case "chests": "Surprises from boss wins and clean solves."
        default: "Real treats for finishing modules. Enjoy each one, then mark it."
        }
    }
}

private struct PathTab: View {
    @Environment(Store.self) private var store
    let path: [RewardState]

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            NextReward(path: path)
            phase("Early wins", "Small treats, often, while the habit forms", path.filter { $0.def.size == .small }, longHaul: false)
            phase("The climb", "Fewer, bigger rewards for the harder modules", path.filter { $0.def.size == .medium }, longHaul: true)
            if let big = path.first(where: { $0.def.size == .big }) { Finale(x: big) }
        }
    }

    private func phase(_ title: String, _ desc: String, _ items: [RewardState], longHaul: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title).font(.headline)
                Text(desc).font(.caption).foregroundStyle(.secondary)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                ForEach(items) { RewardCard(x: $0) }
                if longHaul {
                    VStack(spacing: 6) {
                        Image(systemName: "mountain.2").font(.title2).foregroundStyle(.tertiary)
                        Text("The long haul").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                        Text("Greedy, DP, Tries, Bits. No gifts on purpose.").font(.caption2).foregroundStyle(.tertiary).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity).padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4])).foregroundStyle(Color.hairline))
                }
            }
        }
    }
}

private struct RewardArt: View {
    let icon: String
    let status: RewardState.Status
    var size: CGFloat = 64

    var body: some View {
        ArtImage(name: icon, size: size, locked: status == .locked)
            .shadow(color: .black.opacity(status == .locked ? 0 : 0.35), radius: 8, y: 5)
            .background {
                if status == .unlocked { Circle().fill(Color.warning.opacity(0.18)).blur(radius: 16) }
            }
            .overlay(alignment: .bottomTrailing) {
                Group {
                    if status == .availed { Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.success) }
                    else if status == .locked { Image(systemName: "lock.circle.fill").foregroundStyle(Color.muted) }
                }
                .font(.system(size: max(14, size * 0.24)))
                .background(Circle().fill(Color.surface).padding(1))
            }
    }
}

private struct RewardCard: View {
    @Environment(Store.self) private var store
    let x: RewardState
    @State private var hover = false

    var body: some View {
        VStack(spacing: 4) {
            RewardArt(icon: x.def.icon, status: x.status).padding(.bottom, 6)
            Text(x.def.title).font(.callout.weight(.semibold)).foregroundStyle(x.status == .locked ? .secondary : .primary).lineLimit(1)
            Text(x.def.label).font(.caption).foregroundStyle(.muted).lineLimit(1)
            Spacer(minLength: 12)
            switch x.status {
            case .locked:
                VStack(spacing: 6) {
                    ProgressView(value: Double(x.done), total: Double(max(1, x.total))).tint(.warning)
                    Text("\(x.done) of \(x.total) topics").font(.caption2.monospacedDigit()).foregroundStyle(.muted)
                }
            case .unlocked:
                Button("Mark availed") { store.setAvailed(x.id, true) }
                    .buttonStyle(.glassProminent).tint(.warning).buttonBorderShape(.capsule).controlSize(.small)
            case .availed:
                if hover { Button("Mark as pending") { store.setAvailed(x.id, false) }.buttonStyle(.plain).font(.caption).foregroundStyle(.muted) }
                else { Label("Availed \(short(x.availedAt ?? ""))", systemImage: "checkmark").font(.caption).foregroundStyle(.success) }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 180)
        .surface(border: x.status == .unlocked ? Color.warning.opacity(0.5) : .hairline)
        .help(x.def.note)
        .onHover { hover = $0 }
    }
}

private struct NextReward: View {
    @Environment(Store.self) private var store
    let path: [RewardState]

    var body: some View {
        let next = path.first { $0.status == .locked }
        let waiting = path.filter { $0.status == .unlocked }
        let unlocked = path.filter { $0.status != .locked }.count
        VStack(spacing: 0) {
            HStack(spacing: 18) {
                RewardArt(icon: next?.def.icon ?? "gift", status: .unlocked, size: 68)
                VStack(alignment: .leading, spacing: 4) {
                    Text(next == nil ? "Every reward unlocked" : "Up next").font(.caption).foregroundStyle(.secondary)
                    Text(next?.def.title ?? "You finished the course").font(.title2.weight(.semibold))
                    if let next {
                        let left = next.total - next.done
                        Text("\(Text("Finish \(next.requires.joined(separator: " + ")) · "))\(Text("\(left) topic\(left == 1 ? "" : "s") to go").foregroundStyle(.primary))")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(Text("\(unlocked)").font(.title.weight(.semibold)))\(Text("/\(path.count)").foregroundStyle(.secondary))").monospacedDigit()
                    Text("unlocked").font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(20)
            if let w = waiting.first {
                Divider()
                HStack {
                    Circle().fill(.warning).frame(width: 7, height: 7).shadow(color: .warning, radius: 4)
                    let more = waiting.count > 1 ? " (+\(waiting.count - 1) more)" : ""
                    Text("\(Text(w.def.title).fontWeight(.medium))\(Text(" is unlocked\(more). Enjoy it, then mark it as availed.").foregroundStyle(.secondary))")
                        .font(.callout)
                    Spacer()
                    Button("Mark as availed") { store.setAvailed(w.id, true) }
                        .buttonStyle(.glassProminent).tint(.warning).buttonBorderShape(.capsule)
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
            } else if let next {
                ProgressView(value: Double(next.done), total: Double(max(1, next.total))).tint(.warning).padding(.horizontal, 20).padding(.bottom, 14)
            }
        }
        .surface()
    }
}

private struct Finale: View {
    @Environment(Store.self) private var store
    let x: RewardState

    var body: some View {
        let pct = x.total > 0 ? Double(x.done) / Double(x.total) : 0
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("The summit").font(.headline)
                Text("All of it, plus one mock interview").font(.caption).foregroundStyle(.secondary)
            }
            HStack(spacing: 20) {
                RewardArt(icon: x.def.icon, status: x.status, size: 84)
                VStack(alignment: .leading, spacing: 4) {
                    Text(x.def.title).font(.title2.weight(.semibold))
                    Text(x.def.note).foregroundStyle(.secondary)
                }
                Spacer()
                switch x.status {
                case .locked:
                    VStack(alignment: .trailing) {
                        Text("\(Int(pct * 100))%").font(.title.weight(.semibold).monospacedDigit())
                        Text(x.done == x.total ? "Now beat the DP boss" : "of the course done").font(.caption).foregroundStyle(.secondary)
                    }
                case .unlocked:
                    Button("Mark as availed") { store.setAvailed(x.id, true) }
                        .buttonStyle(.glassProminent).tint(.warning).buttonBorderShape(.capsule)
                case .availed: Text("Availed \(short(x.availedAt ?? ""))").foregroundStyle(.success)
                }
            }
            .padding(16)
            .padding(4)
            .background(LinearGradient(colors: [Color.warning.opacity(0.08), Color.surface], startPoint: .leading, endPoint: .trailing), in: .rect(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.warning.opacity(0.3)))
        }
    }
}

private struct TrophiesTab: View {
    let badges: [Badge]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 12)], spacing: 12) {
            ForEach(badges) { TrophyCard(b: $0) }
        }
    }
}

private struct TrophyCard: View {
    let b: Badge
    var body: some View {
        let earned = b.tier > 0
        HStack(spacing: 14) {
            Medal(icon: b.icon, metal: b.medal, size: 72)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(b.name).fontWeight(.semibold).foregroundStyle(earned ? .primary : .secondary).lineLimit(1)
                    Spacer()
                    if b.single {
                        Text(earned ? "Earned" : "Locked").font(.caption).foregroundStyle(earned ? Color.brand : .secondary)
                    } else {
                        HStack(spacing: 3) {
                            ForEach(1...3, id: \.self) { t in
                                Circle().fill(t <= b.tier ? Badge.metal(t, single: false) : Color.primary.opacity(0.1))
                                    .frame(width: 7, height: 7)
                            }
                        }
                        .help(Badge.metalName[b.tier])
                    }
                }
                ProgressView(value: b.next.map { Double(min(b.value, $0)) / Double($0) } ?? 1)
                    .tint(b.next == nil && !b.single ? .warning : .brand)
                HStack {
                    Text("\(Text(b.next.map { "\(min(b.value, $0))/\($0)" } ?? "\(b.value)").foregroundStyle(.primary))\(Text(" \(b.desc)"))")
                        .lineLimit(1)
                    Spacer()
                    if !b.single {
                        Text(b.next == nil ? "Complete" : "\(Badge.metalName[b.tier + 1]) next").foregroundStyle(b.next == nil ? Color.warning : .secondary)
                    }
                }
                .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
        }
        .card(padding: 14)
        .opacity(earned ? 1 : 0.85)
    }
}

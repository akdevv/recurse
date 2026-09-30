import SwiftUI

struct ChestSheet: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    let id: Int
    @State private var reward: ChestReward?
    @State private var shake = false

    var body: some View {
        VStack(spacing: 20) {
            if let r = reward {
                VStack(spacing: 6) {
                    if case .collectible(let cid, _, _) = r {
                        ArtImage(name: cid, size: 64).shadow(color: .black.opacity(0.35), radius: 6, y: 4)
                    } else {
                        Image(systemName: r.icon).font(.system(size: 26, weight: .semibold)).foregroundStyle(r.tint)
                            .frame(width: 56, height: 56).glassEffect(.regular.tint(r.tint.opacity(0.25)), in: .circle)
                    }
                    ArtImage(name: "chest-open", size: 104).shadow(color: Color.warning.opacity(0.35), radius: 16)
                }
                .transition(.scale.combined(with: .opacity))
                VStack(spacing: 6) {
                    Text(isCollectible(r) ? "Rare collectible" : "You found").font(.caption.weight(.medium))
                        .foregroundStyle(isCollectible(r) ? Color.warning : .muted)
                    Text(r.title).font(.title2.weight(.semibold))
                    Text(r.subtitle).font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button { dismiss() } label: { Text("Nice").frame(minWidth: 120) }
                    .buttonStyle(.glassProminent).keyboardShortcut(.defaultAction)
            } else {
                ArtImage(name: store.chests().first { $0.id == id }?.source == "boss" ? "chest-boss" : "chest", size: 120)
                    .shadow(color: .black.opacity(0.4), radius: 10, y: 6)
                    .rotationEffect(.degrees(shake ? 4 : -4), anchor: .bottom)
                    .animation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true), value: shake)
                    .onAppear { shake = true }
                VStack(spacing: 6) {
                    Text("Mystery chest").font(.title2.weight(.semibold))
                    Text("Earned by your effort. Bonus XP, a streak freeze, or a rare collectible.")
                        .font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 10) {
                    Button { dismiss() } label: { Text("Later").frame(minWidth: 96) }
                        .keyboardShortcut(.cancelAction).buttonStyle(.glass).tint(.raised)
                    Button { withAnimation(.spring(duration: 0.4)) { reward = store.openChest(id) } } label: { Text("Open It").frame(minWidth: 96) }
                        .buttonStyle(.glassProminent).keyboardShortcut(.defaultAction)
                }
            }
        }
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .padding(.horizontal, 32).padding(.vertical, 28)
        .frame(width: 360)
    }

    private func isCollectible(_ r: ChestReward) -> Bool { if case .collectible = r { true } else { false } }
}

struct ChestsView: View {
    @Environment(Store.self) private var store
    @State private var opening: Int?

    var body: some View {
        let rows = store.chests()
        let unopened = rows.filter { $0.openedAt == nil }
        let opened = rows.filter { $0.openedAt != nil }.prefix(20)
        let owned = store.ownedCollectibles()

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
                                    ArtImage(name: c.source == "boss" ? "chest-boss" : "chest", size: 56)
                                        .shadow(color: .black.opacity(0.35), radius: 6, y: 4)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(c.source == "boss" ? "Boss chest" : "Solve chest").fontWeight(.medium).fixedSize()
                                        Text("Earned \(short(c.ts))").font(.caption).foregroundStyle(.secondary).fixedSize()
                                    }
                                    Spacer()
                                    Button("Open") { opening = c.id }
                                        .buttonStyle(.glassProminent).tint(.warning).buttonBorderShape(.capsule)
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
                            VStack(spacing: 6) {
                                Group {
                                    if have {
                                        ArtImage(name: c.id, size: 60).shadow(color: .black.opacity(0.35), radius: 6, y: 4)
                                    } else {
                                        Image(systemName: "questionmark").font(.title3.weight(.semibold)).foregroundStyle(Color.muted.opacity(0.5))
                                            .frame(width: 48, height: 48)
                                            .background(Circle().fill(Color.raised))
                                            .overlay(Circle().strokeBorder(Color.hairline, lineWidth: 1.5))
                                    }
                                }
                                .frame(height: 60)
                                .padding(.bottom, 2)
                                Text(have ? c.name : "Undiscovered").font(.callout.weight(.semibold)).foregroundStyle(have ? .primary : .secondary)
                                Text(have ? c.desc : " ").font(.caption).foregroundStyle(.muted)
                                    .multilineTextAlignment(.center).lineLimit(2, reservesSpace: true)
                            }
                            .frame(maxWidth: .infinity)
                            .opacity(have ? 1 : 0.7)
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
                                        Group {
                                            if case .collectible(let cid, _, _) = r { ArtImage(name: cid, size: 28) }
                                            else {
                                                Image(systemName: r.icon).foregroundStyle(r.tint).frame(width: 28, height: 28)
                                                    .background(r.tint.opacity(0.14), in: .circle)
                                            }
                                        }
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
        .sheet(item: Binding(get: { opening.map(SheetID.init) }, set: { opening = $0?.id })) { ChestSheet(id: $0.id) }
    }

    private func header(_ title: String, _ sub: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title).font(.headline)
            if let sub { Text(sub).font(.caption).foregroundStyle(.secondary) }
        }
    }
}

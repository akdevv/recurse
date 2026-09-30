import AppKit

/// Manual updates from GitHub Releases. The data lives in Application Support, so swapping the .app keeps it.
@MainActor
enum Updates {
    static let repo = "akdevv/recurse"
    static let releasesPage = URL(string: "https://github.com/\(repo)/releases/latest")!

    /// Nil for `swift run` builds, which have no Info.plist.
    static var current: String? { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }

    struct Release {
        let version: String
        let zip: URL?
    }

    struct Failure: LocalizedError { let errorDescription: String? }

    static func latest() async throws -> Release {
        struct Asset: Decodable { let name: String; let browser_download_url: URL }
        struct Latest: Decodable { let tag_name: String; let assets: [Asset] }
        let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest")!
        guard let (data, response) = try? await URLSession.shared.data(from: url) else {
            throw Failure(errorDescription: "Couldn't reach GitHub. Check your connection.")
        }
        guard (response as? HTTPURLResponse)?.statusCode == 200, let r = try? JSONDecoder().decode(Latest.self, from: data) else {
            throw Failure(errorDescription: "No public release on GitHub yet.")
        }
        return Release(version: r.tag_name.replacing(/^v/, with: ""),
                       zip: r.assets.first { $0.name.hasSuffix(".zip") }?.browser_download_url)
    }

    /// "0.10.0" is newer than "0.9.2".
    nonisolated static func isNewer(_ a: String, than b: String) -> Bool {
        let x = a.split(separator: ".").map { Int($0) ?? 0 }, y = b.split(separator: ".").map { Int($0) ?? 0 }
        for i in 0..<max(x.count, y.count) where x[safe: i] ?? 0 != y[safe: i] ?? 0 { return x[safe: i] ?? 0 > y[safe: i] ?? 0 }
        return false
    }

    /// Downloads the release, then quits; a small script swaps the .app once this process is gone and reopens it.
    static func install(_ release: Release) async throws {
        let app = Bundle.main.bundleURL
        guard app.pathExtension == "app", let zip = release.zip else { throw Failure(errorDescription: "Download it from GitHub instead.") }
        guard FileManager.default.isWritableFile(atPath: app.deletingLastPathComponent().path) else {
            throw Failure(errorDescription: "Can't write to \(app.deletingLastPathComponent().path). Download it from GitHub instead.")
        }
        let dir = FileManager.default.temporaryDirectory.appending(path: "recurse-update-\(UUID())")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let (file, _) = try await URLSession.shared.download(from: zip)
        let unzip = await Proc.run(["ditto", "-x", "-k", file.path, dir.path], timeout: 120)
        let new = dir.appending(path: "Recurse.app")
        guard unzip.status == 0, Bundle(url: new)?.bundleIdentifier == Bundle.main.bundleIdentifier else {
            throw Failure(errorDescription: "The download didn't contain Recurse.app.")
        }
        let q = { (u: URL) in "'" + u.path.replacingOccurrences(of: "'", with: "'\\''") + "'" }
        let swap = Process()
        swap.executableURL = URL(fileURLWithPath: "/bin/sh")
        swap.arguments = ["-c", """
            while kill -0 \(ProcessInfo.processInfo.processIdentifier) 2>/dev/null; do sleep 0.2; done
            mv \(q(app)) \(q(dir.appending(path: "old.app"))) || exit 1
            mv \(q(new)) \(q(app)) || mv \(q(dir.appending(path: "old.app"))) \(q(app))
            open \(q(app))
            """]
        try swap.run()
        NSApp.terminate(nil)
    }
}

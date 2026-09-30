import Foundation
import Security

enum AIProvider: String, Codable, CaseIterable, Identifiable {
    case claudeCode, anthropic, openai, gemini

    var id: String { rawValue }

    var title: String {
        switch self {
        case .claudeCode: "Claude subscription"
        case .anthropic: "Anthropic API"
        case .openai: "OpenAI API"
        case .gemini: "Google Gemini API"
        }
    }

    var usesKey: Bool { self != .claudeCode }

    /// Grading wants the stronger model; the tutor a faster one.
    func defaultModel(_ purpose: AI.Purpose) -> String {
        switch (self, purpose) {
        case (.claudeCode, .grade): ProcessInfo.processInfo.environment["AI_MODEL"] ?? "opus"
        case (.claudeCode, .tutor): ProcessInfo.processInfo.environment["AI_TUTOR_MODEL"] ?? "sonnet"
        case (.anthropic, .grade): "claude-opus-5-5"
        case (.anthropic, .tutor): "claude-sonnet-5-5"
        case (.openai, .grade): "gpt-5"
        case (.openai, .tutor): "gpt-5-mini"
        case (.gemini, _): "gemini-flash-latest" // free keys get no Pro quota
        }
    }

    var keyPage: URL? {
        switch self {
        case .claudeCode: nil
        case .anthropic: URL(string: "https://console.anthropic.com/settings/keys")
        case .openai: URL(string: "https://platform.openai.com/api-keys")
        case .gemini: URL(string: "https://aistudio.google.com/apikey")
        }
    }
}

enum AI {
    enum Purpose { case grade, tutor }

    /// Stored under the `ai` settings key. Keys never are: they live in the Keychain.
    struct Config: Codable, Equatable {
        var provider = AIProvider.claudeCode
        var model = "" // empty = the provider's defaults

        func model(_ purpose: Purpose) -> String {
            let m = model.trimmingCharacters(in: .whitespaces)
            return m.isEmpty ? provider.defaultModel(purpose) : m
        }
    }

    static func ask(_ prompt: String, _ config: Config, _ purpose: Purpose) async throws -> String {
        let model = config.model(purpose)
        guard config.provider.usesKey else { return try await claudeCode(prompt, model: model) }
        guard let key = Keychain.get(config.provider.rawValue) else {
            throw Proc.AIError(errorDescription: "Add your \(config.provider.title) key in Settings › AI.")
        }
        for attempt in 1... {
            let (data, response): (Data, URLResponse)
            do { (data, response) = try await URLSession.shared.data(for: request(config.provider, model: model, key: key, prompt: prompt)) } catch {
                throw Proc.AIError(errorDescription: "Couldn't reach \(config.provider.title). Check your connection.")
            }
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            // overloaded (503, Anthropic's 529) is usually over in seconds: one retry
            if status >= 500, attempt == 1 { try await Task.sleep(for: .seconds(3)); continue }
            return try parse(config.provider, data, status: status)
        }
        fatalError()
    }

    static func request(_ provider: AIProvider, model: String, key: String, prompt: String) -> URLRequest {
        let (url, headers, body): (String, [String: String], [String: Any]) = switch provider {
        case .anthropic:
            ("https://api.anthropic.com/v1/messages", ["x-api-key": key, "anthropic-version": "2023-06-01"],
             ["model": model, "max_tokens": 2048, "messages": [["role": "user", "content": prompt]]])
        case .openai:
            ("https://api.openai.com/v1/chat/completions", ["Authorization": "Bearer \(key)"],
             ["model": model, "messages": [["role": "user", "content": prompt]]])
        case .gemini:
            ("https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent", ["x-goog-api-key": key],
             ["contents": [["role": "user", "parts": [["text": prompt]]]]])
        case .claudeCode: preconditionFailure("the Claude subscription goes through the CLI")
        }
        var r = URLRequest(url: URL(string: url)!, timeoutInterval: 120)
        r.httpMethod = "POST"
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (k, v) in headers { r.setValue(v, forHTTPHeaderField: k) }
        r.httpBody = try! JSONSerialization.data(withJSONObject: body)
        return r
    }

    static func parse(_ provider: AIProvider, _ data: Data, status: Int) throws -> String {
        let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard status == 200, let obj else {
            let message = ((obj?["error"] as? [String: Any])?["message"] as? String)?.split(separator: "\n").first.map(String.init) ?? "HTTP \(status)"
            throw Proc.AIError(errorDescription: "\(provider.title): \(message)")
        }
        let parts: [[String: Any]]? = switch provider {
        case .anthropic: obj["content"] as? [[String: Any]]
        case .openai: ((obj["choices"] as? [[String: Any]])?.first?["message"] as? [String: Any]).map { [$0] }
        case .gemini: (((obj["candidates"] as? [[String: Any]])?.first?["content"] as? [String: Any])?["parts"] as? [[String: Any]])
            // thinking models return their thoughts as parts too
            .map { $0.filter { $0["thought"] as? Bool != true } }
        case .claudeCode: nil
        }
        let text = (parts ?? []).compactMap { ($0["text"] ?? $0["content"]) as? String }.joined()
        guard !text.isEmpty else { throw Proc.AIError(errorDescription: "\(provider.title) sent an empty reply.") }
        return text
    }

    private static func claudeCode(_ prompt: String, model: String) async throws -> String {
        // tmp cwd so the CLI doesn't load this repo's CLAUDE.md into every call
        let o = await Proc.run(["claude", "-p", prompt, "--model", model, "--output-format", "json"],
                               timeout: 120, cwd: FileManager.default.temporaryDirectory)
        guard o.status == 0,
              let obj = try? JSONSerialization.jsonObject(with: Data(o.out.utf8)) as? [String: Any],
              obj["is_error"] as? Bool != true, let result = obj["result"]
        else {
            if o.status == 127 { throw Proc.AIError(errorDescription: "The claude CLI isn't installed.") }
            throw Proc.AIError(errorDescription: o.timedOut ? "Claude timed out." : String((o.err.isEmpty ? o.out : o.err).suffix(500)))
        }
        return "\(result)"
    }

    /// The path of the `claude` CLI, if it's on the app's PATH.
    static func claudePath() async -> String? {
        let o = await Proc.run(["which", "claude"], timeout: 5)
        return o.status == 0 ? o.out.trimmingCharacters(in: .whitespacesAndNewlines) : nil
    }
}

/// API keys as generic passwords in the login Keychain, one per provider.
enum Keychain {
    static let service = "dev.akdevv.recurse.ai"

    private static func query(_ account: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account]
    }

    static func get(_ account: String) -> String? {
        var q = query(account)
        q[kSecReturnData as String] = true
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        var out: CFTypeRef?
        guard SecItemCopyMatching(q as CFDictionary, &out) == errSecSuccess, let data = out as? Data else { return nil }
        return String(decoding: data, as: UTF8.self)
    }

    @discardableResult
    static func set(_ account: String, _ value: String) -> Bool {
        let data = Data(value.utf8)
        let status = SecItemUpdate(query(account) as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        guard status == errSecItemNotFound else { return status == errSecSuccess }
        var q = query(account)
        q[kSecValueData as String] = data
        q[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        return SecItemAdd(q as CFDictionary, nil) == errSecSuccess
    }

    static func delete(_ account: String) {
        SecItemDelete(query(account) as CFDictionary)
    }
}

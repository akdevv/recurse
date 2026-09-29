import Foundation
import SQLite3

/// Repo root: courses/, scripts/ and the web app's schema live here.
enum Paths {
    // ponytail: #filePath points at this checkout, fine for a single-user build; RECURSE_ROOT overrides it
    static let root: URL = {
        if let env = ProcessInfo.processInfo.environment["RECURSE_ROOT"] { return URL(fileURLWithPath: env) }
        return URL(fileURLWithPath: #filePath).deletingLastPathComponent() // Recurse
            .deletingLastPathComponent().deletingLastPathComponent() // mac
            .deletingLastPathComponent()
    }()
    static let course = root.appending(path: "courses/dsa")
    static let pyjudge = root.appending(path: "scripts/pyjudge.py")
    /// Same schema as the web app, so the two DBs stay interchangeable.
    static let schema = root.appending(path: "web/server/schema.sql")

    static let db: URL = {
        if let env = ProcessInfo.processInfo.environment["DB_PATH"] { return URL(fileURLWithPath: env) }
        let dir = URL.applicationSupportDirectory.appending(path: "Recurse")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appending(path: "recurse.db")
    }()
}

enum SQL: Equatable {
    case int(Int), real(Double), text(String), null
}

typealias Row = [String: SQL]

extension Dictionary where Key == String, Value == SQL {
    func int(_ k: String) -> Int? {
        switch self[k] {
        case .int(let v): v
        case .real(let v): Int(v)
        default: nil
        }
    }
    func real(_ k: String) -> Double? {
        switch self[k] {
        case .int(let v): Double(v)
        case .real(let v): v
        default: nil
        }
    }
    func str(_ k: String) -> String? {
        if case .text(let v) = self[k] { return v }
        return nil
    }
}

protocol SQLBindable { var sql: SQL { get } }
extension Int: SQLBindable { var sql: SQL { .int(self) } }
extension Double: SQLBindable { var sql: SQL { .real(self) } }
extension String: SQLBindable { var sql: SQL { .text(self) } }
extension Bool: SQLBindable { var sql: SQL { .int(self ? 1 : 0) } }
extension Optional: SQLBindable where Wrapped: SQLBindable { var sql: SQL { self?.sql ?? .null } }

@MainActor
final class DB {
    private var handle: OpaquePointer?

    init(path: URL = Paths.db) throws {
        let fresh = !FileManager.default.fileExists(atPath: path.path)
        let seed = Paths.root.appending(path: "data/learn.db")
        if fresh, path == Paths.db, ProcessInfo.processInfo.environment["DB_PATH"] == nil,
           FileManager.default.fileExists(atPath: seed.path) {
            // first launch: carry progress over from the web app (read-only on its DB)
            var src: OpaquePointer?
            if sqlite3_open_v2(seed.path, &src, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
                let q = path.path.replacingOccurrences(of: "'", with: "''")
                sqlite3_exec(src, "VACUUM INTO '\(q)'", nil, nil, nil)
            }
            sqlite3_close(src)
        }
        guard sqlite3_open(path.path, &handle) == SQLITE_OK else { throw DBError(message: "can't open \(path.path)") }
        try exec("PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;")
        try exec(String(contentsOf: Paths.schema, encoding: .utf8))
    }

    struct DBError: Error, LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    func exec(_ sql: String) throws {
        var err: UnsafeMutablePointer<CChar>?
        if sqlite3_exec(handle, sql, nil, nil, &err) != SQLITE_OK {
            let msg = err.map { String(cString: $0) } ?? "sqlite error"
            sqlite3_free(err)
            throw DBError(message: msg)
        }
    }

    @discardableResult
    func run(_ sql: String, _ args: any SQLBindable...) -> Int {
        _ = query(sql, args)
        return Int(sqlite3_last_insert_rowid(handle))
    }

    func all(_ sql: String, _ args: any SQLBindable...) -> [Row] { query(sql, args) }
    func one(_ sql: String, _ args: any SQLBindable...) -> Row? { query(sql, args).first }

    private func query(_ sql: String, _ args: [any SQLBindable]) -> [Row] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) == SQLITE_OK else {
            // ponytail: statements are all static, a bad one is a programming error
            fatalError("SQL: \(String(cString: sqlite3_errmsg(handle))) in \(sql)")
        }
        defer { sqlite3_finalize(stmt) }
        let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        for (i, a) in args.enumerated() {
            let idx = Int32(i + 1)
            switch a.sql {
            case .int(let v): sqlite3_bind_int64(stmt, idx, Int64(v))
            case .real(let v): sqlite3_bind_double(stmt, idx, v)
            case .text(let v): sqlite3_bind_text(stmt, idx, v, -1, transient)
            case .null: sqlite3_bind_null(stmt, idx)
            }
        }
        var rows: [Row] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: Row = [:]
            for c in 0..<sqlite3_column_count(stmt) {
                let name = String(cString: sqlite3_column_name(stmt, c))
                switch sqlite3_column_type(stmt, c) {
                case SQLITE_INTEGER: row[name] = .int(Int(sqlite3_column_int64(stmt, c)))
                case SQLITE_FLOAT: row[name] = .real(sqlite3_column_double(stmt, c))
                case SQLITE_TEXT: row[name] = .text(String(cString: sqlite3_column_text(stmt, c)))
                default: row[name] = .null
                }
            }
            rows.append(row)
        }
        return rows
    }
}

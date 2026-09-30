import Foundation
import SQLite3

enum Paths {
    /// The checkout this was built from, so content edits show up live; a downloaded app uses the copy in its Resources.
    static let root: URL = {
        if let env = ProcessInfo.processInfo.environment["RECURSE_ROOT"] { return URL(fileURLWithPath: env) }
        var dir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while dir.path != "/" {
            if FileManager.default.fileExists(atPath: dir.appending(path: "courses/dsa/course.json").path) { return dir }
            dir.deleteLastPathComponent()
        }
        return Bundle.main.resourceURL ?? dir
    }()
    static let course = root.appending(path: "courses/dsa")
    static let pyjudge = root.appending(path: "scripts/pyjudge.py")

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
    func json<T: Decodable>(_ k: String) -> T? { str(k).flatMap { try? JSONDecoder().decode(T.self, from: Data($0.utf8)) } }
}

extension Encodable {
    var jsonText: String { String(decoding: try! JSONEncoder().encode(self), as: UTF8.self) }
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
    let path: URL

    init(path: URL = Paths.db) throws {
        self.path = path
        guard sqlite3_open(path.path, &handle) == SQLITE_OK else { throw DBError(message: "can't open \(path.path)") }
        try exec("PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;")
        try exec(DB.schema)
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

    /// A consistent single-file copy, safe while the app is writing.
    func export(to url: URL) throws {
        try? FileManager.default.removeItem(at: url)
        try exec("VACUUM INTO '\(url.path.replacingOccurrences(of: "'", with: "''"))'")
    }

    /// Replaces everything in this database with the backup at `url`, in place.
    func restore(from url: URL) throws {
        var src: OpaquePointer?
        defer { sqlite3_close(src) }
        var stmt: OpaquePointer?
        guard sqlite3_open_v2(url.path, &src, SQLITE_OPEN_READONLY, nil) == SQLITE_OK,
              sqlite3_prepare_v2(src, "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'attempts'", -1, &stmt, nil) == SQLITE_OK
        else { throw DBError(message: "That file isn't a Recurse backup.") }
        let isBackup = sqlite3_step(stmt) == SQLITE_ROW
        sqlite3_finalize(stmt)
        guard isBackup else { throw DBError(message: "That file isn't a Recurse backup.") }
        guard let b = sqlite3_backup_init(handle, "main", src, "main") else { throw DBError(message: String(cString: sqlite3_errmsg(handle))) }
        sqlite3_backup_step(b, -1)
        guard sqlite3_backup_finish(b) == SQLITE_OK else { throw DBError(message: String(cString: sqlite3_errmsg(handle))) }
        try exec(DB.schema) // older backups get tables added since
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

extension DB {
    /// Progress is keyed by content slugs (topic / problem / module ids), so content can be reordered or extended freely.
    static let schema = """
        CREATE TABLE IF NOT EXISTS activity (
          date    TEXT PRIMARY KEY,          -- local YYYY-MM-DD
          seconds INTEGER NOT NULL DEFAULT 0 -- active (focused + in use) seconds
        );

        CREATE TABLE IF NOT EXISTS attempts (
          id              INTEGER PRIMARY KEY,
          problem_id      TEXT NOT NULL,
          started_at      TEXT NOT NULL,
          finished_at     TEXT,
          active_seconds  INTEGER NOT NULL DEFAULT 0,
          hints_used      INTEGER NOT NULL DEFAULT 0,
          solution_viewed INTEGER NOT NULL DEFAULT 0,
          approach        TEXT NOT NULL DEFAULT '',
          code            TEXT,
          outcome         TEXT,              -- solved | hinted | assisted
          explain         TEXT
        );
        CREATE INDEX IF NOT EXISTS attempts_problem ON attempts(problem_id);

        CREATE TABLE IF NOT EXISTS submissions (
          id         INTEGER PRIMARY KEY,
          attempt_id INTEGER NOT NULL REFERENCES attempts(id),
          ts         TEXT NOT NULL,
          kind       TEXT NOT NULL,          -- run | submit
          verdict    TEXT NOT NULL,
          passed     INTEGER NOT NULL,
          total      INTEGER NOT NULL,
          code       TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS topic_progress (
          topic_id       TEXT PRIMARY KEY,
          lesson_done_at TEXT,
          quiz_best      REAL,               -- best score 0..1
          explain        TEXT,
          explain_at     TEXT
        );

        CREATE TABLE IF NOT EXISTS reviews (
          item_type    TEXT NOT NULL,        -- problem | topic
          item_id      TEXT NOT NULL,
          interval_idx INTEGER NOT NULL,
          due          TEXT NOT NULL,        -- local YYYY-MM-DD
          last_result  TEXT,
          PRIMARY KEY (item_type, item_id)
        );

        CREATE TABLE IF NOT EXISTS xp_events (
          id     INTEGER PRIMARY KEY,
          ts     TEXT NOT NULL,
          amount INTEGER NOT NULL,
          reason TEXT NOT NULL,
          ref    TEXT
        );

        CREATE TABLE IF NOT EXISTS settings (
          key   TEXT PRIMARY KEY,
          value TEXT NOT NULL                -- JSON
        );

        CREATE TABLE IF NOT EXISTS grades (   -- AI explain-back grades
          id     INTEGER PRIMARY KEY,
          kind   TEXT NOT NULL,              -- topic | problem | boss
          ref    TEXT NOT NULL,              -- topic / problem / module id
          ts     TEXT NOT NULL,
          score  INTEGER NOT NULL,           -- 0..5
          json   TEXT NOT NULL               -- full Grade
        );
        CREATE INDEX IF NOT EXISTS grades_ref ON grades(kind, ref);

        CREATE TABLE IF NOT EXISTS reward_claims (  -- real-world rewards marked as availed
          id         TEXT PRIMARY KEY,         -- RewardDef.id
          claimed_at TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS boss_runs (
          id          INTEGER PRIMARY KEY,
          module_id   TEXT NOT NULL,
          problem_id  TEXT NOT NULL,
          attempt_id  INTEGER NOT NULL REFERENCES attempts(id),
          started_at  TEXT NOT NULL,
          limit_s     INTEGER NOT NULL,
          solved_at   TEXT,                  -- first Accepted submit
          finished_at TEXT,                  -- explained (or abandoned)
          score       INTEGER,
          passed      INTEGER
        );

        CREATE TABLE IF NOT EXISTS notifications (  -- sent reminders, for the daily cap and tuning
          id    INTEGER PRIMARY KEY,
          ts    TEXT NOT NULL,
          kind  TEXT NOT NULL,
          title TEXT NOT NULL,
          body  TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS tutor_messages (  -- Socratic tutor chat, per attempt
          id         INTEGER PRIMARY KEY,
          attempt_id INTEGER NOT NULL REFERENCES attempts(id),
          ts         TEXT NOT NULL,
          role       TEXT NOT NULL,          -- user | tutor
          text       TEXT NOT NULL
        );
        CREATE INDEX IF NOT EXISTS tutor_attempt ON tutor_messages(attempt_id);

        CREATE TABLE IF NOT EXISTS chests (   -- mystery chests, earned by boss wins and clean solves
          id        INTEGER PRIMARY KEY,
          ts        TEXT NOT NULL,
          source    TEXT NOT NULL,           -- boss | solve
          ref       TEXT NOT NULL,           -- module / problem id
          opened_at TEXT,
          reward    TEXT                     -- JSON {kind: xp | freeze | collectible, ...}
        );
        """
}

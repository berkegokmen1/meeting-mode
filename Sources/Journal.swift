import Foundation

struct Session: Codable {
    var started: Date
    var focusPending: Bool
}
final class Journal {
    let url: URL
    init(url: URL) { self.url = url }
    func read() throws -> Session? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try JSONDecoder().decode(Session.self, from: Data(contentsOf: url))
    }
    func save(_ state: Session) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(state).write(to: url, options: .atomic)
    }
    func clear() throws {
        if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
    }
}

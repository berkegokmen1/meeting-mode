import Foundation
let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
defer { try? FileManager.default.removeItem(at: root) }
let journal = Journal(url: root.appendingPathComponent("session.json"))
let empty1 = try journal.read(); assert(empty1 == nil)
let state = Session(started: Date(timeIntervalSince1970: 100), focusPending: true)
try journal.save(state)
let recovered = try journal.read()!
assert(recovered.started == state.started && recovered.focusPending)
try journal.save(state)
let repeated = try journal.read()!; assert(repeated.started == state.started)
try journal.clear(); try journal.clear()
let cleared = try journal.read(); assert(cleared == nil)
try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
try Data("corrupt".utf8).write(to: journal.url)
do { _ = try journal.read(); fatalError("Corruption must fail") } catch {}
let blocked = Journal(url: journal.url.appendingPathComponent("child"))
do { try blocked.save(state); fatalError("Write must fail") } catch {}
assert(FileManager.default.fileExists(atPath: journal.url.path))
print("Journal fixture checks passed")

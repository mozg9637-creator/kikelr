import Foundation
import Combine

struct LogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let category: String
    let message: String

    var formatted: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return "[\(f.string(from: date))] [\(category)] \(message)"
    }
}

/// Простой лог в памяти приложения — виден в разделе «Для разработчика»,
/// чтобы не лазить в Xcode Console. Никуда не отправляется, живёт только
/// пока приложение открыто (плюс последние 300 записей хранятся в UserDefaults
/// между запусками, для удобства отладки).
final class AppLogger: ObservableObject {
    static let shared = AppLogger()
    private init() {
        load()
    }

    @Published private(set) var entries: [LogEntry] = []
    private let maxEntries = 300
    private let storageKey = "app_logger_entries_v1"

    func log(_ message: String, category: String = "app") {
        let entry = LogEntry(date: Date(), category: category, message: message)
        DispatchQueue.main.async {
            self.entries.append(entry)
            if self.entries.count > self.maxEntries {
                self.entries.removeFirst(self.entries.count - self.maxEntries)
            }
            self.persist()
            #if DEBUG
            print(entry.formatted)
            #endif
        }
    }

    func clear() {
        entries.removeAll()
        persist()
    }

    private func persist() {
        let lines = entries.map { "\($0.date.timeIntervalSince1970)|\($0.category)|\($0.message)" }
        UserDefaults.standard.set(lines, forKey: storageKey)
    }

    private func load() {
        guard let lines = UserDefaults.standard.stringArray(forKey: storageKey) else { return }
        entries = lines.compactMap { line in
            let parts = line.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
            guard parts.count == 3, let ts = Double(parts[0]) else { return nil }
            return LogEntry(date: Date(timeIntervalSince1970: ts), category: String(parts[1]), message: String(parts[2]))
        }
    }
}

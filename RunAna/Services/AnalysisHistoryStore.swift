import Combine
import Foundation

struct AnalysisRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let title: String
    let text: String

    init(id: UUID = UUID(), date: Date = Date(), title: String, text: String) {
        self.id = id
        self.date = date
        self.title = title
        self.text = text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        text = try container.decode(String.self, forKey: .text)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Caption Draft"
    }
}

@MainActor
final class AnalysisHistoryStore: ObservableObject {
    @Published private(set) var items: [AnalysisRecord] = []

    private let defaults = UserDefaults.standard
    private let storageKey = "melancholy_philosopher_caption_history"

    init() {
        load()
    }

    func add(title: String, text: String) {
        let record = AnalysisRecord(title: title, text: text)
        items.insert(record, at: 0)
        items = Array(items.prefix(30))
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([AnalysisRecord].self, from: data) else {
            items = []
            return
        }
        items = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: storageKey)
    }
}

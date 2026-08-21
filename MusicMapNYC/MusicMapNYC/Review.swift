import Foundation

struct Review: Identifiable, Codable {
    let id: UUID
    let author: String
    let rating: Int   // 1...5
    let text: String
    let date: Date

    init(author: String, rating: Int, text: String, date: Date = Date()) {
        self.id = UUID()
        self.author = author
        self.rating = rating
        self.text = text
        self.date = date
    }
}

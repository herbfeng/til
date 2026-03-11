import Foundation
import SwiftData

@Model
final class TILPost {
    @Attribute(.unique) var id: UUID = UUID()
    var content: String = ""
    var category: String = "General"
    var createdAt: Date = Date()
    
    init(content: String, category: String = "General") {
        self.content = content
        self.category = category
        self.createdAt = Date()
    }
}

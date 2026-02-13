import Foundation
import SwiftData

@Model
final class CreativeBrief {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var project: Project?
    
    init(title: String, content: String = "", project: Project? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.project = project
    }
}

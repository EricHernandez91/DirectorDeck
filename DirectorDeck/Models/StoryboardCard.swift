import Foundation
import SwiftData

@Model
final class StoryboardCard {
    var id: UUID
    var title: String
    var sceneDescription: String
    var imageData: Data?
    var orderIndex: Int
    var duration: String
    var cameraAngle: String
    var notes: String
    var createdAt: Date
    var project: Project?
    
    init(title: String, sceneDescription: String = "", orderIndex: Int = 0, project: Project? = nil) {
        self.id = UUID()
        self.title = title
        self.sceneDescription = sceneDescription
        self.imageData = nil
        self.orderIndex = orderIndex
        self.duration = ""
        self.cameraAngle = ""
        self.notes = ""
        self.createdAt = Date()
        self.project = project
    }
}

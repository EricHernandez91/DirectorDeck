import Foundation
import SwiftData

enum ShotType: String, Codable, CaseIterable {
    case wideShot = "Wide Shot"
    case mediumShot = "Medium Shot"
    case closeUp = "Close-Up"
    case extremeCloseUp = "Extreme Close-Up"
    case overTheShoulder = "Over the Shoulder"
    case pov = "POV"
    case aerial = "Aerial"
    case tracking = "Tracking"
    case dolly = "Dolly"
    case steadicam = "Steadicam"
    case handheld = "Handheld"
    case crane = "Crane"
    case tiltShot = "Tilt"
    case panShot = "Pan"
    case insert = "Insert"
    case cutaway = "Cutaway"
    case establishing = "Establishing"
    case twoShot = "Two Shot"
    case other = "Other"
}

@Model
final class ShotListItem {
    var id: UUID
    var shotNumber: String
    var title: String
    var shotTypeRaw: String
    var lens: String
    var shotDescription: String
    var notes: String
    var isCompleted: Bool
    var orderIndex: Int
    var imageData: Data?
    var scene: String
    var location: String
    var createdAt: Date
    var project: Project?
    
    var shotType: ShotType {
        get { ShotType(rawValue: shotTypeRaw) ?? .other }
        set { shotTypeRaw = newValue.rawValue }
    }
    
    init(shotNumber: String = "", title: String, shotType: ShotType = .wideShot, lens: String = "", shotDescription: String = "", notes: String = "", orderIndex: Int = 0, scene: String = "", location: String = "", project: Project? = nil) {
        self.id = UUID()
        self.shotNumber = shotNumber
        self.title = title
        self.shotTypeRaw = shotType.rawValue
        self.lens = lens
        self.shotDescription = shotDescription
        self.notes = notes
        self.isCompleted = false
        self.orderIndex = orderIndex
        self.imageData = nil
        self.scene = scene
        self.location = location
        self.createdAt = Date()
        self.project = project
    }
}

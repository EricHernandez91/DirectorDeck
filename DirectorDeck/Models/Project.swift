import Foundation
import SwiftData

@Model
final class Project {
    var id: UUID
    var name: String
    var projectDescription: String
    var createdAt: Date
    var updatedAt: Date
    var colorHex: String
    
    @Relationship(deleteRule: .cascade, inverse: \CreativeBrief.project)
    var briefs: [CreativeBrief]
    
    @Relationship(deleteRule: .cascade, inverse: \InterviewSubject.project)
    var interviewSubjects: [InterviewSubject]
    
    @Relationship(deleteRule: .cascade, inverse: \StoryboardCard.project)
    var storyboardCards: [StoryboardCard]
    
    @Relationship(deleteRule: .cascade, inverse: \ShotListItem.project)
    var shotListItems: [ShotListItem]
    
    @Relationship(deleteRule: .cascade, inverse: \ImportedDocument.project)
    var documents: [ImportedDocument]
    
    @Relationship(deleteRule: .cascade, inverse: \ProjectFolder.project)
    var folders: [ProjectFolder]
    
    init(name: String, projectDescription: String = "", colorHex: String = "#00BCD4") {
        self.id = UUID()
        self.name = name
        self.projectDescription = projectDescription
        self.createdAt = Date()
        self.updatedAt = Date()
        self.colorHex = colorHex
        self.briefs = []
        self.interviewSubjects = []
        self.storyboardCards = []
        self.shotListItems = []
        self.documents = []
        self.folders = []
    }
}

@Model
final class ProjectFolder {
    var id: UUID
    var name: String
    var createdAt: Date
    var project: Project?
    
    init(name: String, project: Project? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.project = project
    }
}

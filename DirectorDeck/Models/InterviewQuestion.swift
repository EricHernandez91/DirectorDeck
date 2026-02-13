import Foundation
import SwiftData

@Model
final class InterviewSubject {
    var id: UUID
    var name: String
    var role: String
    var notes: String
    var createdAt: Date
    var project: Project?
    
    @Relationship(deleteRule: .cascade, inverse: \InterviewQuestion.subject)
    var questions: [InterviewQuestion]
    
    init(name: String, role: String = "", notes: String = "", project: Project? = nil) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.notes = notes
        self.createdAt = Date()
        self.project = project
        self.questions = []
    }
    
    var sortedQuestions: [InterviewQuestion] {
        questions.sorted { $0.orderIndex < $1.orderIndex }
    }
}

@Model
final class InterviewQuestion {
    var id: UUID
    var text: String
    var notes: String
    var isAsked: Bool
    var orderIndex: Int
    var subject: InterviewSubject?
    
    init(text: String, notes: String = "", orderIndex: Int = 0, subject: InterviewSubject? = nil) {
        self.id = UUID()
        self.text = text
        self.notes = notes
        self.isAsked = false
        self.orderIndex = orderIndex
        self.subject = subject
    }
}

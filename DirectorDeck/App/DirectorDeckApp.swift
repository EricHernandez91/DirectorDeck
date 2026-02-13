import SwiftUI
import SwiftData

@main
struct DirectorDeckApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Project.self,
            ProjectFolder.self,
            CreativeBrief.self,
            InterviewSubject.self,
            InterviewQuestion.self,
            StoryboardCard.self,
            ShotListItem.self,
            ImportedDocument.self
        ])
    }
}

import SwiftUI
import SwiftData

@main
struct DirectorDeckApp: App {
    @State private var recordingService = InterviewRecordingService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(recordingService)
        }
        .modelContainer(for: [
            Project.self,
            ProjectFolder.self,
            CreativeBrief.self,
            InterviewSubject.self,
            InterviewQuestion.self,
            InterviewRecording.self,
            InterviewMarker.self,
            StoryboardCard.self,
            ShotListItem.self,
            ImportedDocument.self
        ])
    }
}

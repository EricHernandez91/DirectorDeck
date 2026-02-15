import Foundation
import SwiftData

@Model
final class InterviewRecording {
    var id: UUID
    var subjectName: String
    var date: Date
    var duration: TimeInterval
    var audioFilePath: String
    var transcriptText: String
    var summaryText: String
    var isProcessing: Bool
    var project: Project?
    var subject: InterviewSubject?
    
    @Relationship(deleteRule: .cascade, inverse: \InterviewMarker.recording)
    var markers: [InterviewMarker]
    
    init(subjectName: String, audioFilePath: String, project: Project? = nil, subject: InterviewSubject? = nil) {
        self.id = UUID()
        self.subjectName = subjectName
        self.date = Date()
        self.duration = 0
        self.audioFilePath = audioFilePath
        self.transcriptText = ""
        self.summaryText = ""
        self.isProcessing = false
        self.project = project
        self.subject = subject
        self.markers = []
    }
    
    var sortedMarkers: [InterviewMarker] {
        markers.sorted { $0.timestamp < $1.timestamp }
    }
    
    var audioURL: URL? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docs.appendingPathComponent(audioFilePath)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
}

@Model
final class InterviewMarker {
    var id: UUID
    var timestamp: TimeInterval
    var label: String
    var notes: String
    var recording: InterviewRecording?
    
    init(timestamp: TimeInterval, label: String, notes: String = "", recording: InterviewRecording? = nil) {
        self.id = UUID()
        self.timestamp = timestamp
        self.label = label
        self.notes = notes
        self.recording = recording
    }
    
    /// TOD timecode display (timestamp is seconds since midnight)
    var formattedTimestamp: String {
        let total = Int(timestamp)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        let f = Int((timestamp.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d.%02d", h, m, s, f)
    }
}

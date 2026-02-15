import Foundation
import Speech

struct TranscriptionService {
    static func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    static func transcribe(url: URL) async throws -> String {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            throw TranscriptionError.unavailable
        }
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        
        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
    
    static func generateSummary(transcript: String, markers: [InterviewMarker]) -> String {
        guard !transcript.isEmpty else { return "No transcript available." }
        
        var summary = "## Interview Summary\n\n"
        
        if !markers.isEmpty {
            summary += "### Key Moments\n"
            for marker in markers.sorted(by: { $0.timestamp < $1.timestamp }) {
                summary += "- **[\(marker.formattedTimestamp)]** \(marker.label)"
                if !marker.notes.isEmpty {
                    summary += " — \(marker.notes)"
                }
                summary += "\n"
            }
            summary += "\n"
        }
        
        let sentences = transcript.components(separatedBy: ". ")
        if sentences.count > 3 {
            summary += "### Overview\n"
            summary += sentences.prefix(5).joined(separator: ". ") + ".\n\n"
            summary += "Total length: \(sentences.count) sentences.\n"
        } else {
            summary += "### Full Content\n\(transcript)\n"
        }
        
        return summary
    }
    
    enum TranscriptionError: LocalizedError {
        case unavailable
        var errorDescription: String? { "Speech recognition is not available on this device." }
    }
}

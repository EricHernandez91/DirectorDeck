import Foundation
import AVFoundation
import Observation

enum RecordingState {
    case idle, recording, paused, stopped
}

@Observable
final class InterviewRecordingService: NSObject {
    var state: RecordingState = .idle
    var elapsedTime: TimeInterval = 0
    var currentSubjectName: String = ""
    var currentRecordingID: UUID?
    var markers: [InterviewMarker] = []
    var showFloatingTags: Bool = false
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var recordingStartTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private(set) var currentFilePath: String = ""
    
    var isActive: Bool {
        state == .recording || state == .paused
    }
    
    var formattedTime: String {
        let h = Int(elapsedTime) / 3600
        let m = (Int(elapsedTime) % 3600) / 60
        let s = Int(elapsedTime) % 60
        let f = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d.%02d", h, m, s, f)
    }
    
    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func startRecording(subjectName: String) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
        
        let fileName = "interview_\(UUID().uuidString).m4a"
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docs.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
        
        currentFilePath = fileName
        currentSubjectName = subjectName
        currentRecordingID = UUID()
        recordingStartTime = Date()
        accumulatedTime = 0
        elapsedTime = 0
        state = .recording
        showFloatingTags = true
        startTimer()
    }
    
    func pause() {
        guard state == .recording else { return }
        audioRecorder?.pause()
        accumulatedTime = elapsedTime
        recordingStartTime = nil
        timer?.invalidate()
        state = .paused
    }
    
    func resume() {
        guard state == .paused else { return }
        audioRecorder?.record()
        recordingStartTime = Date()
        state = .recording
        startTimer()
    }
    
    func stop() -> (filePath: String, duration: TimeInterval) {
        timer?.invalidate()
        audioRecorder?.stop()
        let result = (filePath: currentFilePath, duration: elapsedTime)
        state = .stopped
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        return result
    }
    
    func reset() {
        state = .idle
        elapsedTime = 0
        currentSubjectName = ""
        currentRecordingID = nil
        currentFilePath = ""
        audioRecorder = nil
        markers = []
        showFloatingTags = false
    }
    
    func addMarker(label: String, notes: String = "") {
        let marker = InterviewMarker(timestamp: elapsedTime, label: label)
        marker.notes = notes
        markers.append(marker)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self, let start = self.recordingStartTime else { return }
            self.elapsedTime = self.accumulatedTime + Date().timeIntervalSince(start)
        }
    }
}

extension InterviewRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag { state = .stopped }
    }
}

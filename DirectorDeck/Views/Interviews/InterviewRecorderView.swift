import SwiftUI
import SwiftData

struct InterviewRecorderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(InterviewRecordingService.self) private var recorder
    
    let project: Project
    let subject: InterviewSubject?
    
    @State private var markers: [InterviewMarker] = []
    @State private var editingMarker: InterviewMarker?
    @State private var editNotes = ""
    @State private var showCustomTag = false
    @State private var customTagText = ""
    @State private var errorMessage: String?
    @State private var showError = false
    
    private let quickTags = ["Great Answer", "Key Quote", "Follow Up", "B-Roll Idea", "Emotional Moment"]
    private let tagIcons = ["star.fill", "quote.closing", "arrow.uturn.forward", "film", "heart.fill"]
    private let tagColors: [Color] = [.yellow, .cyan, .orange, .purple, .pink]
    
    var body: some View {
        VStack(spacing: 0) {
            // Timecode
            Text(recorder.formattedTime)
                .font(.system(size: 72, weight: .light, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.top, 40)
            
            Text(recorder.currentSubjectName.isEmpty ? "Interview" : recorder.currentSubjectName)
                .font(.title3)
                .foregroundStyle(DDTheme.teal)
                .padding(.bottom, 20)
            
            // Record controls
            HStack(spacing: 40) {
                if recorder.state == .idle || recorder.state == .stopped {
                    recordButton
                } else {
                    pauseResumeButton
                    stopButton
                }
            }
            .padding(.bottom, 30)
            
            // Quick tags
            if recorder.isActive {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(quickTags.enumerated()), id: \.offset) { i, tag in
                            Button {
                                addMarker(label: tag)
                            } label: {
                                Label(tag, systemImage: tagIcons[i])
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(tagColors[i].opacity(0.25))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(tagColors[i].opacity(0.4), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Button {
                            showCustomTag = true
                        } label: {
                            Label("Custom", systemImage: "tag")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
            }
            
            // Markers list
            if !markers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    SectionLabel(title: "Markers")
                        .padding(.horizontal)
                    
                    List {
                        ForEach(markers.reversed()) { marker in
                            HStack(spacing: 12) {
                                Text(marker.formattedTimestamp)
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundStyle(DDTheme.teal)
                                    .frame(width: 100, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(marker.label)
                                        .font(.system(size: 14, weight: .semibold))
                                    if !marker.notes.isEmpty {
                                        Text(marker.notes)
                                            .font(.system(size: 12))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    editingMarker = marker
                                    editNotes = marker.notes
                                } label: {
                                    Image(systemName: "pencil.circle")
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(DDTheme.cardGradient)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(DDTheme.deepBackground)
        .alert("Custom Tag", isPresented: $showCustomTag) {
            TextField("Tag label", text: $customTagText)
            Button("Cancel", role: .cancel) { customTagText = "" }
            Button("Add") {
                if !customTagText.isEmpty {
                    addMarker(label: customTagText)
                    customTagText = ""
                }
            }
        }
        .alert("Edit Notes", isPresented: Binding(
            get: { editingMarker != nil },
            set: { if !$0 { editingMarker = nil } }
        )) {
            TextField("Notes", text: $editNotes)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                editingMarker?.notes = editNotes
                editingMarker = nil
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
        .onAppear {
            if recorder.state == .idle {
                startRecording()
            }
        }
    }
    
    private var recordButton: some View {
        Button(action: startRecording) {
            Circle()
                .fill(Color.red)
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 90, height: 90)
                )
        }
        .buttonStyle(.plain)
    }
    
    private var pauseResumeButton: some View {
        Button {
            if recorder.state == .recording {
                recorder.pause()
            } else {
                recorder.resume()
            }
        } label: {
            Image(systemName: recorder.state == .recording ? "pause.fill" : "play.fill")
                .font(.system(size: 32))
                .foregroundStyle(.white)
                .frame(width: 70, height: 70)
                .background(DDTheme.cardGradient)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    private var stopButton: some View {
        Button(action: stopRecording) {
            Image(systemName: "stop.fill")
                .font(.system(size: 28))
                .foregroundStyle(.white)
                .frame(width: 70, height: 70)
                .background(Color.red.opacity(0.3))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.red.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    private func startRecording() {
        Task {
            let granted = await recorder.requestPermission()
            guard granted else {
                errorMessage = "Microphone access is required to record interviews."
                showError = true
                return
            }
            do {
                let name = subject?.name ?? "Interview"
                try recorder.startRecording(subjectName: name)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func stopRecording() {
        let result = recorder.stop()
        
        let recording = InterviewRecording(
            subjectName: recorder.currentSubjectName,
            audioFilePath: result.filePath,
            project: project,
            subject: subject
        )
        recording.duration = result.duration
        modelContext.insert(recording)
        
        for marker in markers {
            marker.recording = recording
            modelContext.insert(marker)
        }
        
        try? modelContext.save()
        
        // Transcribe in background
        recording.isProcessing = true
        let recordingID = recording.id
        let audioURL = recording.audioURL
        let markersCopy = markers
        
        Task {
            if let url = audioURL {
                _ = await TranscriptionService.requestPermission()
                let transcript = (try? await TranscriptionService.transcribe(url: url)) ?? ""
                
                await MainActor.run {
                    recording.transcriptText = transcript
                    try? modelContext.save()
                }
                
                // Try GPT summary, fall back to local summary
                var summary: String
                if GPTSummaryService.isConfigured && !transcript.isEmpty {
                    do {
                        summary = try await GPTSummaryService.generateSummary(
                            transcript: transcript,
                            markers: markersCopy
                        )
                    } catch {
                        print("GPT summary failed: \(error.localizedDescription)")
                        summary = TranscriptionService.generateSummary(
                            transcript: transcript,
                            markers: markersCopy
                        )
                    }
                } else {
                    summary = TranscriptionService.generateSummary(
                        transcript: transcript,
                        markers: markersCopy
                    )
                }
                
                await MainActor.run {
                    recording.summaryText = summary
                    recording.isProcessing = false
                    try? modelContext.save()
                }
            } else {
                await MainActor.run {
                    recording.isProcessing = false
                }
            }
        }
        
        markers = []
        recorder.reset()
        dismiss()
    }
    
    private func addMarker(label: String) {
        let marker = InterviewMarker(timestamp: recorder.elapsedTime, label: label)
        markers.append(marker)
    }
}

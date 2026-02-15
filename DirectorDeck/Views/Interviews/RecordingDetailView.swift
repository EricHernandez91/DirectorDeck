import SwiftUI
import AVFoundation

struct RecordingDetailView: View {
    let recording: InterviewRecording
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showShareSheet = false
    @State private var exportURL: URL?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(recording.subjectName)
                        .font(.system(size: 24, weight: .bold))
                    Text(recording.date.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Duration: \(formattedDuration(recording.duration))")
                        .font(.subheadline)
                        .foregroundStyle(DDTheme.teal)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .dashboardCard()
                
                // Player
                if recording.audioURL != nil {
                    VStack(spacing: 12) {
                        // Scrubber
                        Slider(value: $currentTime, in: 0...max(recording.duration, 1)) { editing in
                            if !editing {
                                player?.currentTime = currentTime
                            }
                        }
                        .tint(DDTheme.teal)
                        
                        HStack {
                            Text(formattedDuration(currentTime))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(formattedDuration(recording.duration))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 30) {
                            Button { skip(-15) } label: {
                                Image(systemName: "gobackward.15")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                            
                            Button { togglePlayback() } label: {
                                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(DDTheme.teal)
                            }
                            
                            Button { skip(15) } label: {
                                Image(systemName: "goforward.15")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .dashboardCard()
                }
                
                // Processing state
                if recording.isProcessing {
                    HStack {
                        ProgressView()
                            .tint(DDTheme.teal)
                        Text("Transcribing audio...")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .dashboardCard()
                }
                
                // Markers
                if !recording.sortedMarkers.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Markers", icon: "bookmark.fill")
                        
                        ForEach(recording.sortedMarkers) { marker in
                            Button {
                                seekTo(marker.timestamp)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(marker.formattedTimestamp)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundStyle(DDTheme.teal)
                                        .frame(width: 100, alignment: .leading)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(marker.label)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.white)
                                        if !marker.notes.isEmpty {
                                            Text(marker.notes)
                                                .font(.system(size: 12))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "play.circle")
                                        .foregroundStyle(DDTheme.teal.opacity(0.5))
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .dashboardCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .dashboardCard()
                }
                
                // Summary
                if !recording.summaryText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Summary", icon: "doc.text")
                        Text(recording.summaryText)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding()
                    .dashboardCard()
                }
                
                // Transcript
                if !recording.transcriptText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Transcript", icon: "text.alignleft")
                        Text(recording.transcriptText)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                            .textSelection(.enabled)
                    }
                    .padding()
                    .dashboardCard()
                }
            }
            .padding()
        }
        .background(DDTheme.deepBackground)
        .navigationTitle("Recording")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let url = PremiereXMLExporter.exportURL(for: recording) {
                        exportURL = url
                        showShareSheet = true
                    }
                } label: {
                    Label("Export XML", systemImage: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
        .onAppear { setupPlayer() }
        .onDisappear { stopPlayback() }
    }
    
    private func setupPlayer() {
        guard let url = recording.audioURL else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
    }
    
    private func togglePlayback() {
        if isPlaying {
            player?.pause()
            timer?.invalidate()
            isPlaying = false
        } else {
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
            player?.play()
            isPlaying = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                currentTime = player?.currentTime ?? 0
                if !(player?.isPlaying ?? false) && isPlaying {
                    isPlaying = false
                    timer?.invalidate()
                }
            }
        }
    }
    
    private func stopPlayback() {
        player?.stop()
        timer?.invalidate()
    }
    
    private func seekTo(_ time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
        if !isPlaying { togglePlayback() }
    }
    
    private func skip(_ seconds: TimeInterval) {
        let newTime = max(0, min((player?.currentTime ?? 0) + seconds, recording.duration))
        player?.currentTime = newTime
        currentTime = newTime
    }
    
    private func formattedDuration(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        let s = Int(t) % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

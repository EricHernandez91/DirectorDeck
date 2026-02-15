import SwiftUI

struct FloatingRecordingOverlay: View {
    @Environment(InterviewRecordingService.self) private var recorder
    @State private var showCustomTag = false
    @State private var customTagText = ""
    @State private var tagsExpanded = true
    @State private var lastMarkerLabel: String?
    @State private var showMarkerFlash = false
    
    private let quickTags = ["Great Answer", "Key Quote", "Follow Up", "B-Roll Idea", "Emotional Moment"]
    private let tagIcons = ["star.fill", "quote.closing", "arrow.uturn.forward", "film", "heart.fill"]
    private let tagColors: [Color] = [.yellow, .cyan, .orange, .purple, .pink]
    
    var body: some View {
        if recorder.isActive {
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 8) {
                    // Marker flash feedback
                    if showMarkerFlash, let label = lastMarkerLabel {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Marked: \(label)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("@ \(recorder.formattedTime)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2), in: Capsule())
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Quick tag buttons (collapsible)
                    if tagsExpanded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(quickTags.enumerated()), id: \.offset) { i, tag in
                                    Button {
                                        addTag(label: tag)
                                    } label: {
                                        Label(tag, systemImage: tagIcons[i])
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(tagColors[i].opacity(0.3))
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(tagColors[i].opacity(0.5), lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                Button {
                                    showCustomTag = true
                                } label: {
                                    Label("Custom", systemImage: "tag")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Banner bar
                    HStack(spacing: 12) {
                        // Pulsing red dot
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .opacity(recorder.state == .recording ? 1 : 0.4)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: recorder.state)
                        
                        Text(recorder.state == .paused ? "PAUSED" : "REC")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(recorder.state == .paused ? .yellow : .red)
                        
                        Text(recorder.formattedTime)
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white)
                        
                        Text(recorder.formattedElapsed)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                        
                        if !recorder.currentSubjectName.isEmpty {
                            Text("• \(recorder.currentSubjectName)")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                        
                        if !recorder.markers.isEmpty {
                            Text("• \(recorder.markers.count) markers")
                                .font(.system(size: 11))
                                .foregroundStyle(DDTheme.teal)
                        }
                        
                        Spacer()
                        
                        // Toggle tags visibility
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                tagsExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: tagsExpanded ? "chevron.down" : "chevron.up")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        
                        // Pause/Resume
                        Button {
                            if recorder.state == .recording {
                                recorder.pause()
                            } else {
                                recorder.resume()
                            }
                        } label: {
                            Image(systemName: recorder.state == .recording ? "pause.fill" : "play.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.1), in: Circle())
                        }
                        .buttonStyle(.plain)
                        
                        // Stop
                        Button {
                            // Post notification for the interviews view to handle stop + save
                            NotificationCenter.default.post(name: .stopRecordingRequested, object: nil)
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.red.opacity(0.3), in: Circle())
                                .overlay(Circle().stroke(Color.red.opacity(0.4), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .padding(.bottom, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 20, y: -5)
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 4)
            }
            .alert("Custom Tag", isPresented: $showCustomTag) {
                TextField("Tag label", text: $customTagText)
                Button("Cancel", role: .cancel) { customTagText = "" }
                Button("Add") {
                    if !customTagText.isEmpty {
                        addTag(label: customTagText)
                        customTagText = ""
                    }
                }
            }
        }
    }
    
    private func addTag(label: String) {
        recorder.addMarker(label: label)
        lastMarkerLabel = label
        withAnimation(.spring(response: 0.3)) {
            showMarkerFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showMarkerFlash = false }
        }
    }
}

extension Notification.Name {
    static let stopRecordingRequested = Notification.Name("stopRecordingRequested")
}

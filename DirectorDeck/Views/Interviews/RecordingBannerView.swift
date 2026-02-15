import SwiftUI

struct RecordingBannerView: View {
    @Environment(InterviewRecordingService.self) private var recorder
    let onTap: () -> Void
    
    var body: some View {
        if recorder.isActive {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    // Pulsing red dot
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .opacity(recorder.state == .recording ? 1 : 0.4)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: recorder.state)
                    
                    Text(recorder.state == .paused ? "PAUSED" : "REC")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(recorder.state == .paused ? .yellow : .red)
                    
                    Text(recorder.formattedTime)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white)
                    
                    if !recorder.currentSubjectName.isEmpty {
                        Text("• \(recorder.currentSubjectName)")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
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
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
            }
            .buttonStyle(.plain)
        }
    }
}

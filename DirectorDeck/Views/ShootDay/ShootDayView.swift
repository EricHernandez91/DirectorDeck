import SwiftUI

enum ShootDayFilter: String, CaseIterable {
    case all = "All"
    case remaining = "Remaining"
    case completed = "Completed"
}

struct ShootDayView: View {
    let project: Project
    @State private var filter: ShootDayFilter = .remaining
    @State private var showCelebration = false
    
    var allShots: [ShotListItem] {
        project.shotListItems.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var filteredShots: [ShotListItem] {
        switch filter {
        case .all: return allShots
        case .remaining: return allShots.filter { !$0.isCompleted }
        case .completed: return allShots.filter { $0.isCompleted }
        }
    }
    
    var completedCount: Int { allShots.filter(\.isCompleted).count }
    var totalCount: Int { allShots.count }
    var progress: Double { totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0 }
    var allDone: Bool { totalCount > 0 && completedCount == totalCount }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress header
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SHOOT DAY")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(DDTheme.teal)
                            .tracking(2)
                        Text(project.name)
                            .font(.system(.title, design: .rounded, weight: .bold))
                    }
                    
                    Spacer()
                    
                    // Circular progress
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                DDTheme.tealGradient,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                        VStack(spacing: 0) {
                            Text("\(completedCount)")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            Text("of \(totalCount)")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 90, height: 90)
                    .shadow(color: DDTheme.teal.opacity(0.2), radius: 12)
                }
                
                // Filter pills
                HStack(spacing: 10) {
                    ForEach(ShootDayFilter.allCases, id: \.self) { f in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { filter = f }
                        } label: {
                            Text(f.rawValue)
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 9)
                                .background(
                                    filter == f
                                        ? AnyShapeStyle(DDTheme.tealGradient)
                                        : AnyShapeStyle(Color.white.opacity(0.06)),
                                    in: Capsule()
                                )
                                .foregroundStyle(filter == f ? .white : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
            }
            .padding(DDTheme.largePadding)
            .background(.ultraThinMaterial)
            
            // Shot list
            if filteredShots.isEmpty {
                Spacer()
                if filter == .remaining && allDone {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(.green.gradient)
                            .shadow(color: .green.opacity(0.4), radius: 20)
                            .scaleEffect(showCelebration ? 1.0 : 0.5)
                            .opacity(showCelebration ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCelebration)
                        Text("All shots completed!")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        Text("Great work on set today 🎬")
                            .foregroundStyle(.secondary)
                    }
                    .onAppear { showCelebration = true }
                } else {
                    EmptyStateView(
                        icon: "video.slash",
                        title: "No Shots",
                        subtitle: filter == .completed ? "No completed shots yet" : "Add shots to your shot list first"
                    )
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredShots) { shot in
                            ShootDayShotCard(shot: shot)
                        }
                    }
                    .padding(DDTheme.largePadding)
                }
            }
        }
        .navigationTitle("Shoot Day")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShootDayShotCard: View {
    @Bindable var shot: ShotListItem
    @State private var justToggled = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Large tap target for checking off
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    shot.isCompleted.toggle()
                    justToggled = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    justToggled = false
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(shot.isCompleted ? Color.green.opacity(0.15) : Color.white.opacity(0.05))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(shot.isCompleted ? Color.green.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1.5)
                        )
                    Image(systemName: shot.isCompleted ? "checkmark" : "")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.green)
                        .scaleEffect(justToggled ? 1.3 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: justToggled)
                }
            }
            .buttonStyle(.plain)
            
            // Thumbnail
            if let data = shot.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Shot info
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    if !shot.shotNumber.isEmpty {
                        Text(shot.shotNumber)
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(DDTheme.teal.opacity(0.15), in: Capsule())
                            .foregroundStyle(DDTheme.teal)
                    }
                    Text(shot.title)
                        .font(.system(.headline, design: .rounded))
                        .strikethrough(shot.isCompleted, color: .secondary.opacity(0.5))
                        .foregroundStyle(shot.isCompleted ? .secondary : .primary)
                }
                
                HStack(spacing: 10) {
                    Label(shot.shotType.rawValue, systemImage: "camera.fill")
                    if !shot.lens.isEmpty {
                        Label(shot.lens, systemImage: "circle.circle")
                    }
                    if !shot.scene.isEmpty {
                        Label(shot.scene, systemImage: "film")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                if !shot.shotDescription.isEmpty {
                    Text(shot.shotDescription)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(14)
        .glassCard()
        .opacity(shot.isCompleted ? 0.7 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: shot.isCompleted)
    }
}

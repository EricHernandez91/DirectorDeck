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
            // Progress header card
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
                    
                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.06), lineWidth: 8)
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
                }
                
                // Filter pills
                HStack(spacing: 10) {
                    ForEach(ShootDayFilter.allCases, id: \.self) { f in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { filter = f }
                        } label: {
                            Text(f.rawValue)
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .foregroundStyle(filter == f ? .white : .secondary)
                                .background {
                                    if filter == f {
                                        Capsule().fill(DDTheme.tealGradient)
                                    } else {
                                        Capsule().fill(Color.white.opacity(0.04))
                                            .overlay(Capsule().stroke(DDTheme.cardBorder, lineWidth: 1))
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
            }
            .padding(DDTheme.largePadding)
            .dashboardCard(cornerRadius: 0)
            
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
                    LazyVStack(spacing: 14) {
                        ForEach(filteredShots) { shot in
                            ShootDayShotCard(shot: shot)
                        }
                    }
                    .padding(DDTheme.largePadding)
                }
            }
        }
        .background(DDTheme.deepBackground)
        .navigationTitle("Shoot Day")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShootDayShotCard: View {
    @Bindable var shot: ShotListItem
    @State private var justToggled = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
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
                        .fill(shot.isCompleted ? DDTheme.green.opacity(0.15) : Color.white.opacity(0.04))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle().stroke(shot.isCompleted ? DDTheme.green.opacity(0.3) : DDTheme.cardBorder, lineWidth: 1)
                        )
                    Image(systemName: shot.isCompleted ? "checkmark" : "")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(DDTheme.green)
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
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Shot info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    if !shot.shotNumber.isEmpty {
                        Text(shot.shotNumber)
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(DDTheme.teal)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(DDTheme.teal.opacity(0.12), in: Capsule())
                    }
                    Text(shot.title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(shot.isCompleted ? .secondary : .primary)
                }
                
                HStack(spacing: 14) {
                    Label(shot.shotType.rawValue, systemImage: "camera.fill")
                    if !shot.lens.isEmpty {
                        Label(shot.lens, systemImage: "circle.circle")
                    }
                    if !shot.scene.isEmpty {
                        Label(shot.scene, systemImage: "film")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary.opacity(0.7))
                
                if !shot.shotDescription.isEmpty {
                    Text(shot.shotDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.5))
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .dashboardCard(cornerRadius: 20)
        .opacity(shot.isCompleted ? 0.6 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: shot.isCompleted)
    }
}

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
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(DDTheme.teal)
                            .tracking(2)
                        Text(project.name)
                            .font(.system(size: 28, weight: .bold))
                    }
                    
                    Spacer()
                    
                    // Progress ring - 80pt, 6pt stroke
                    ZStack {
                        Circle()
                            .stroke(DDTheme.violet.opacity(0.1), lineWidth: 6)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                DDTheme.tealGradient,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 80, height: 80)
                }
                
                // Filter pills - 40pt height
                HStack(spacing: 10) {
                    ForEach(ShootDayFilter.allCases, id: \.self) { f in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { filter = f }
                        } label: {
                            Text(f.rawValue)
                                .font(.system(size: 15, weight: .medium))
                                .padding(.horizontal, 16)
                                .frame(height: 40)
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
            .background(
                ZStack {
                    DDTheme.cardGradient
                    RadialGradient(colors: [DDTheme.violet.opacity(0.06), .clear], center: .topTrailing, startRadius: 0, endRadius: 300)
                }
            )
            
            // Shot list
            if filteredShots.isEmpty {
                Spacer()
                if filter == .remaining && allDone {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(DDTheme.success.gradient)
                            .shadow(color: DDTheme.success.opacity(0.4), radius: 20)
                            .scaleEffect(showCelebration ? 1.0 : 0.5)
                            .opacity(showCelebration ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCelebration)
                        Text("All shots completed!")
                            .font(.system(size: 22, weight: .bold))
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
            // Checkbox - 44pt minimum tap target
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
                        .fill(shot.isCompleted ? DDTheme.success : Color.clear)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle().stroke(shot.isCompleted ? DDTheme.success : DDTheme.teal, lineWidth: shot.isCompleted ? 0 : 2)
                        )
                    if shot.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .scaleEffect(justToggled ? 1.3 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: justToggled)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Shot info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    if !shot.shotNumber.isEmpty {
                        Text(shot.shotNumber)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(DDTheme.teal, in: Capsule())
                    }
                    Text(shot.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(shot.isCompleted ? .secondary : .primary)
                }
                
                HStack(spacing: 6) {
                    PillView(text: shot.shotType.rawValue, color: DDTheme.mutedBlueGray)
                    if !shot.lens.isEmpty {
                        PillView(text: shot.lens)
                    }
                    if !shot.scene.isEmpty {
                        PillView(text: shot.scene, color: DDTheme.amber, background: DDTheme.amber.opacity(0.15))
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .dashboardCard()
        .opacity(shot.isCompleted ? 0.6 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: shot.isCompleted)
    }
}

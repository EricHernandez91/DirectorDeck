import SwiftUI

enum ShootDayFilter: String, CaseIterable {
    case all = "All"
    case remaining = "Remaining"
    case completed = "Completed"
}

struct ShootDayView: View {
    let project: Project
    @State private var filter: ShootDayFilter = .remaining
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress header
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SHOOT DAY")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(DDTheme.teal)
                            .tracking(2)
                        Text(project.name)
                            .font(.title.weight(.bold))
                    }
                    
                    Spacer()
                    
                    // Circular progress
                    ZStack {
                        Circle()
                            .stroke(Color(.tertiarySystemFill), lineWidth: 6)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(DDTheme.teal, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.5), value: progress)
                        VStack(spacing: 0) {
                            Text("\(completedCount)")
                                .font(.title2.weight(.bold))
                            Text("of \(totalCount)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 80, height: 80)
                }
                
                ProgressView(value: progress)
                    .tint(DDTheme.teal)
                
                // Filter pills
                HStack(spacing: 12) {
                    ForEach(ShootDayFilter.allCases, id: \.self) { f in
                        Button {
                            withAnimation(.spring(response: 0.3)) { filter = f }
                        } label: {
                            Text(f.rawValue)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(filter == f ? DDTheme.teal : Color(.tertiarySystemFill), in: Capsule())
                                .foregroundStyle(filter == f ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
            }
            .padding(DDTheme.largePadding)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Shot list
            if filteredShots.isEmpty {
                Spacer()
                if filter == .remaining && completedCount == totalCount && totalCount > 0 {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)
                        Text("All shots completed!")
                            .font(.title2.weight(.semibold))
                        Text("Great work on set today 🎬")
                            .foregroundStyle(.secondary)
                    }
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
    
    var body: some View {
        HStack(spacing: 16) {
            // Large tap target for checking off
            Button {
                withAnimation(.spring(response: 0.3)) {
                    shot.isCompleted.toggle()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(shot.isCompleted ? Color.green.opacity(0.15) : Color(.tertiarySystemFill))
                        .frame(width: 56, height: 56)
                    Image(systemName: shot.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 28))
                        .foregroundStyle(shot.isCompleted ? .green : .secondary)
                }
            }
            .buttonStyle(.plain)
            
            // Thumbnail
            if let data = shot.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Shot info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if !shot.shotNumber.isEmpty {
                        Text(shot.shotNumber)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(DDTheme.teal.opacity(0.2), in: Capsule())
                            .foregroundStyle(DDTheme.teal)
                    }
                    Text(shot.title)
                        .font(.headline)
                        .strikethrough(shot.isCompleted)
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
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .glassCard()
        .opacity(shot.isCompleted ? 0.7 : 1)
    }
}

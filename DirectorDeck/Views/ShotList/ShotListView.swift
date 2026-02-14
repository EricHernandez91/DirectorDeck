import SwiftUI
import SwiftData

struct ShotListView: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var selectedShot: ShotListItem?
    @State private var showNewShot = false
    @State private var searchText = ""
    @State private var filterType: ShotType?
    
    var shots: [ShotListItem] {
        var items = project.shotListItems.sorted { $0.orderIndex < $1.orderIndex }
        if !searchText.isEmpty {
            items = items.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.shotDescription.localizedCaseInsensitiveContains(searchText) }
        }
        if let filterType {
            items = items.filter { $0.shotType == filterType }
        }
        return items
    }
    
    var body: some View {
        Group {
            if project.shotListItems.isEmpty {
                EmptyStateView(
                    icon: "list.bullet.rectangle.fill",
                    title: "No Shots",
                    subtitle: "Build your shot list for production",
                    action: { showNewShot = true },
                    actionLabel: "Add Shot"
                )
            } else {
                List {
                    ForEach(shots) { shot in
                        ShotListRow(shot: shot)
                            .onTapGesture { selectedShot = shot }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparatorTint(Color.white.opacity(0.06))
                    }
                    .onMove(perform: moveShots)
                    .onDelete(perform: deleteShots)
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search shots")
            }
        }
        .navigationTitle("Shot List (\(project.shotListItems.count))")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("All Types") { filterType = nil }
                    Divider()
                    ForEach(ShotType.allCases, id: \.self) { type in
                        Button(type.rawValue) { filterType = type }
                    }
                } label: {
                    Image(systemName: filterType == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showNewShot = true }) {
                    Label("Add Shot", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showNewShot) {
            ShotEditSheet(project: project, orderIndex: project.shotListItems.count)
        }
        .sheet(item: $selectedShot) { shot in
            ShotEditSheet(project: project, existingShot: shot)
        }
    }
    
    private func moveShots(from source: IndexSet, to destination: Int) {
        var sorted = shots
        sorted.move(fromOffsets: source, toOffset: destination)
        for (i, s) in sorted.enumerated() { s.orderIndex = i }
    }
    
    private func deleteShots(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(shots[index])
        }
    }
}

struct ShotListRow: View {
    @Bindable var shot: ShotListItem
    
    var body: some View {
        HStack(spacing: 14) {
            // Completion toggle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    shot.isCompleted.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(shot.isCompleted ? Color.green.opacity(0.15) : Color.clear)
                        .frame(width: 32, height: 32)
                    Image(systemName: shot.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(shot.isCompleted ? Color.green : Color.secondary)
                }
            }
            .buttonStyle(.plain)
            
            // Thumbnail
            if let data = shot.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if !shot.shotNumber.isEmpty {
                        Text(shot.shotNumber)
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(DDTheme.teal.opacity(0.15), in: Capsule())
                            .foregroundStyle(DDTheme.teal)
                    }
                    Text(shot.title)
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .strikethrough(shot.isCompleted, color: .secondary.opacity(0.5))
                        .foregroundStyle(shot.isCompleted ? .secondary : .primary)
                }
                
                HStack(spacing: 10) {
                    Label(shot.shotType.rawValue, systemImage: "camera.fill")
                    if !shot.lens.isEmpty {
                        Label(shot.lens, systemImage: "circle.circle")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                if !shot.shotDescription.isEmpty {
                    Text(shot.shotDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.7))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if !shot.scene.isEmpty {
                Text(shot.scene)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.tertiarySystemFill), in: Capsule())
            }
        }
        .padding(.vertical, 4)
        .opacity(shot.isCompleted ? 0.65 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: shot.isCompleted)
    }
}

struct ShotEditSheet: View {
    let project: Project
    var existingShot: ShotListItem?
    var orderIndex: Int = 0
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var shotNumber = ""
    @State private var title = ""
    @State private var shotType: ShotType = .wideShot
    @State private var lens = ""
    @State private var description = ""
    @State private var notes = ""
    @State private var scene = ""
    @State private var location = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var isEditing: Bool { existingShot != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Shot Info") {
                    TextField("Shot Number (e.g. 1A)", text: $shotNumber)
                    TextField("Title", text: $title)
                    Picker("Shot Type", selection: $shotType) {
                        ForEach(ShotType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    TextField("Lens (e.g. 35mm)", text: $lens)
                }
                
                Section("Details") {
                    TextField("Scene", text: $scene)
                    TextField("Location", text: $location)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Storyboard Image") {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Button("Remove Image", role: .destructive) { selectedImage = nil }
                    }
                    Button(action: { showImagePicker = true }) {
                        Label("Attach Image", systemImage: "photo.on.rectangle")
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Shot" : "New Shot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { image in selectedImage = image }
            }
            .onAppear {
                if let shot = existingShot {
                    shotNumber = shot.shotNumber
                    title = shot.title
                    shotType = shot.shotType
                    lens = shot.lens
                    description = shot.shotDescription
                    notes = shot.notes
                    scene = shot.scene
                    location = shot.location
                    if let data = shot.imageData {
                        selectedImage = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    private func save() {
        if let shot = existingShot {
            shot.shotNumber = shotNumber
            shot.title = title
            shot.shotType = shotType
            shot.lens = lens
            shot.shotDescription = description
            shot.notes = notes
            shot.scene = scene
            shot.location = location
            shot.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        } else {
            let shot = ShotListItem(shotNumber: shotNumber, title: title, shotType: shotType, lens: lens, shotDescription: description, notes: notes, orderIndex: orderIndex, scene: scene, location: location, project: project)
            shot.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
            modelContext.insert(shot)
        }
    }
}

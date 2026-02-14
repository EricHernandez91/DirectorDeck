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
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(shots) { shot in
                            ShotListRow(shot: shot)
                                .onTapGesture { selectedShot = shot }
                        }
                    }
                    .padding(.horizontal, DDTheme.standardPadding)
                    .padding(.vertical, 8)
                }
                .searchable(text: $searchText, prompt: "Search shots")
            }
        }
        .background(DDTheme.deepBackground)
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
}

struct ShotListRow: View {
    @Bindable var shot: ShotListItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Shot number badge - teal circle
            if !shot.shotNumber.isEmpty {
                ZStack {
                    Circle()
                        .fill(DDTheme.teal)
                        .frame(width: 32, height: 32)
                    Text(shot.shotNumber)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                .shadow(color: DDTheme.teal.opacity(0.3), radius: 8, y: 2)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(shot.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
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
            
            // Checkbox
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    shot.isCompleted.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(shot.isCompleted ? DDTheme.success : Color.clear)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle().stroke(shot.isCompleted ? DDTheme.success : Color.white.opacity(0.2), lineWidth: 1.5)
                        )
                    if shot.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .dashboardCard()
        .opacity(shot.isCompleted ? 0.5 : 1)
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

import SwiftUI
import SwiftData
import PencilKit

struct StoryboardGridView: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var selectedCard: StoryboardCard?
    @State private var showNewCard = false
    
    var cards: [StoryboardCard] {
        project.storyboardCards.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        Group {
            if cards.isEmpty {
                EmptyStateView(
                    icon: "rectangle.split.3x3.fill",
                    title: "No Storyboard Cards",
                    subtitle: "Create cards to visualize your scenes",
                    action: { showNewCard = true },
                    actionLabel: "New Card"
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(cards) { card in
                            StoryboardCardView(card: card)
                                .onTapGesture { selectedCard = card }
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        modelContext.delete(card)
                                    }
                                }
                        }
                    }
                    .padding(DDTheme.largePadding)
                }
            }
        }
        .navigationTitle("Storyboards")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showNewCard = true }) {
                    Label("New Card", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showNewCard) {
            NewStoryboardCardSheet(project: project, orderIndex: cards.count)
        }
        .sheet(item: $selectedCard) { card in
            StoryboardCardDetailSheet(card: card)
        }
    }
}

struct StoryboardCardView: View {
    let card: StoryboardCard
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image area
            ZStack {
                Rectangle()
                    .fill(Color(.tertiarySystemBackground))
                    .aspectRatio(16/9, contentMode: .fit)
                
                if let data = card.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(16/9, contentMode: .fit)
                        .clipped()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundStyle(.tertiary)
                        Text("No Image")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                // Order badge — liquid glass pill
                VStack {
                    HStack {
                        Text("#\(card.orderIndex + 1)")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .liquidGlassPill()

                        Spacer()
                    }
                    Spacer()
                }
                .padding(10)
            }
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
            
            // Info area
            VStack(alignment: .leading, spacing: 8) {
                Text(card.title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                
                if !card.sceneDescription.isEmpty {
                    Text(card.sceneDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                if !card.cameraAngle.isEmpty || !card.duration.isEmpty {
                    HStack(spacing: 14) {
                        if !card.cameraAngle.isEmpty {
                            Label(card.cameraAngle, systemImage: "camera.fill")
                                .font(.caption2)
                                .foregroundStyle(DDTheme.teal)
                        }
                        if !card.duration.isEmpty {
                            Label(card.duration, systemImage: "clock.fill")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .dashboardCard(cornerRadius: 20)
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct NewStoryboardCardSheet: View {
    let project: Project
    let orderIndex: Int
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var cameraAngle = ""
    @State private var duration = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showDrawing = false
    @State private var drawingData: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Card Title", text: $title)
                    TextField("Scene Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Camera Angle", text: $cameraAngle)
                    TextField("Duration", text: $duration)
                }
                
                Section("Image") {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: { showImagePicker = true }) {
                        Label("Import Photo", systemImage: "photo.on.rectangle")
                    }
                    
                    Button(action: { showDrawing = true }) {
                        Label("Draw Storyboard", systemImage: "pencil.tip.crop.circle")
                    }
                }
            }
            .navigationTitle("New Storyboard Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let card = StoryboardCard(title: title, sceneDescription: description, orderIndex: orderIndex, project: project)
                        card.cameraAngle = cameraAngle
                        card.duration = duration
                        card.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                        modelContext.insert(card)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { image in
                    selectedImage = image
                }
            }
            .sheet(isPresented: $showDrawing) {
                DrawingSheet(drawingData: $drawingData) { image in
                    selectedImage = image
                }
            }
        }
    }
}

struct DrawingSheet: View {
    @Binding var drawingData: Data?
    let onSave: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            DrawingCanvas(canvasData: $drawingData)
                .navigationTitle("Draw")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Use Drawing") {
                            if let data = drawingData,
                               let drawing = try? PKDrawing(data: data) {
                                let image = drawing.image(from: drawing.bounds, scale: 2.0)
                                onSave(image)
                            }
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct StoryboardCardDetailSheet: View {
    @Bindable var card: StoryboardCard
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Rectangle()
                            .fill(Color(.tertiarySystemBackground))
                            .aspectRatio(16/9, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        if let data = card.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            Button(action: { showImagePicker = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 40))
                                    Text("Add Image")
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    VStack(spacing: 16) {
                        TextField("Title", text: $card.title)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .textFieldStyle(.plain)
                        
                        LabeledContent("Description") {
                            TextField("Scene description", text: $card.sceneDescription, axis: .vertical)
                                .multilineTextAlignment(.trailing)
                        }
                        LabeledContent("Camera Angle") {
                            TextField("e.g. Wide, Close-up", text: $card.cameraAngle)
                                .multilineTextAlignment(.trailing)
                        }
                        LabeledContent("Duration") {
                            TextField("e.g. 3s", text: $card.duration)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.system(.headline, design: .rounded))
                            TextEditor(text: $card.notes)
                                .frame(minHeight: 100)
                                .scrollContentBackground(.hidden)
                                .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Card #\(card.orderIndex + 1)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showImagePicker = true }) {
                        Image(systemName: "photo.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { image in
                    card.imageData = image.jpegData(compressionQuality: 0.8)
                }
            }
        }
    }
}

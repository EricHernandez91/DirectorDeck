import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DocumentsView: View {
    let project: Project
    var folder: ProjectFolder?
    @Environment(\.modelContext) private var modelContext
    @State private var showDocumentPicker = false
    @State private var showImagePicker = false
    @State private var selectedDocument: ImportedDocument?
    
    var documents: [ImportedDocument] {
        let folderName = folder?.name ?? "General"
        if folder != nil {
            return project.documents.filter { $0.folderName == folderName }.sorted { $0.createdAt > $1.createdAt }
        }
        return project.documents.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        Group {
            if documents.isEmpty {
                EmptyStateView(
                    icon: "folder.fill",
                    title: "No Documents",
                    subtitle: "Import PDFs, images, and other references",
                    action: { showDocumentPicker = true },
                    actionLabel: "Import"
                )
            } else {
                List {
                    ForEach(documents) { doc in
                        DocumentRow(document: doc)
                            .onTapGesture { selectedDocument = doc }
                    }
                    .onDelete(perform: deleteDocuments)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(folder?.name ?? "Documents")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showDocumentPicker = true }) {
                        Label("Import PDF", systemImage: "doc.fill")
                    }
                    Button(action: { showImagePicker = true }) {
                        Label("Import Image", systemImage: "photo.fill")
                    }
                } label: {
                    Label("Import", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(contentTypes: [.pdf]) { url in
                importFile(url: url, type: .pdf)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                if let data = image.jpegData(compressionQuality: 0.8) {
                    let doc = ImportedDocument(name: "Image \(Date().formatted(date: .abbreviated, time: .shortened))", documentType: .image, fileData: data, folderName: folder?.name ?? "General", project: project)
                    modelContext.insert(doc)
                }
            }
        }
        .sheet(item: $selectedDocument) { doc in
            DocumentDetailView(document: doc)
        }
    }
    
    private func importFile(url: URL, type: DocumentType) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        if let data = try? Data(contentsOf: url) {
            let doc = ImportedDocument(name: url.lastPathComponent, documentType: type, fileData: data, folderName: folder?.name ?? "General", project: project)
            modelContext.insert(doc)
        }
    }
    
    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(documents[index])
        }
    }
}

struct DocumentRow: View {
    let document: ImportedDocument
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(document.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                HStack {
                    Text(document.documentType.rawValue)
                    Text("•")
                    Text(document.createdAt, style: .date)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    var iconName: String {
        switch document.documentType {
        case .pdf: return "doc.fill"
        case .image: return "photo.fill"
        case .other: return "doc.fill"
        }
    }
    
    var iconColor: Color {
        switch document.documentType {
        case .pdf: return .red
        case .image: return DDTheme.teal
        case .other: return .gray
        }
    }
}

struct DocumentDetailView: View {
    let document: ImportedDocument
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if let data = document.fileData {
                    switch document.documentType {
                    case .pdf:
                        PDFKitView(data: data)
                    case .image:
                        if let uiImage = UIImage(data: data) {
                            ScrollView {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            }
                        }
                    case .other:
                        Text("Unsupported file type")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No file data available")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(document.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

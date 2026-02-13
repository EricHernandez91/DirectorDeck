import SwiftUI
import SwiftData

struct BriefsListView: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var selectedBrief: CreativeBrief?
    @State private var showNewBrief = false
    @State private var newBriefTitle = ""
    
    var briefs: [CreativeBrief] {
        project.briefs.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    var body: some View {
        Group {
            if briefs.isEmpty {
                EmptyStateView(
                    icon: "doc.text.fill",
                    title: "No Creative Briefs",
                    subtitle: "Create a brief to outline your creative vision",
                    action: { showNewBrief = true },
                    actionLabel: "New Brief"
                )
            } else {
                HSplitContent(briefs: briefs, selectedBrief: $selectedBrief, onDelete: deleteBrief)
            }
        }
        .navigationTitle("Creative Briefs")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showNewBrief = true }) {
                    Label("New Brief", systemImage: "plus")
                }
            }
        }
        .alert("New Brief", isPresented: $showNewBrief) {
            TextField("Brief Title", text: $newBriefTitle)
            Button("Cancel", role: .cancel) { newBriefTitle = "" }
            Button("Create") {
                guard !newBriefTitle.isEmpty else { return }
                let brief = CreativeBrief(title: newBriefTitle, project: project)
                modelContext.insert(brief)
                newBriefTitle = ""
                selectedBrief = brief
            }
        }
    }
    
    private func deleteBrief(_ brief: CreativeBrief) {
        if selectedBrief?.id == brief.id { selectedBrief = nil }
        modelContext.delete(brief)
    }
}

private struct HSplitContent: View {
    let briefs: [CreativeBrief]
    @Binding var selectedBrief: CreativeBrief?
    let onDelete: (CreativeBrief) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            List(briefs, selection: $selectedBrief) { brief in
                NavigationLink(value: brief) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(brief.title)
                            .font(.headline)
                        Text(brief.updatedAt, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions {
                    Button("Delete", role: .destructive) { onDelete(brief) }
                }
            }
            .listStyle(.sidebar)
            .frame(width: 260)
            
            Divider()
            
            if let brief = selectedBrief {
                BriefEditorView(brief: brief)
            } else {
                EmptyStateView(icon: "doc.text", title: "Select a Brief", subtitle: "Choose a brief to edit")
            }
        }
    }
}

struct BriefEditorView: View {
    @Bindable var brief: CreativeBrief
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Title", text: $brief.title)
                    .font(.title.weight(.semibold))
                    .textFieldStyle(.plain)
                Spacer()
                Text("Last edited \(brief.updatedAt, style: .relative) ago")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            
            Divider()
            
            TextEditor(text: $brief.content)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding()
                .onChange(of: brief.content) {
                    brief.updatedAt = Date()
                }
        }
        .background(Color(.systemBackground))
    }
}

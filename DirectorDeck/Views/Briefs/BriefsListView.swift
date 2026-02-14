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
        .background(DDTheme.deepBackground)
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
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DDTheme.tealGradient)
                            .frame(width: 4, height: 36)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(brief.title)
                                .font(.system(size: 15, weight: .semibold))
                            Text(brief.updatedAt, style: .relative)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions {
                    Button("Delete", role: .destructive) { onDelete(brief) }
                }
            }
            .listStyle(.sidebar)
            .frame(width: 280)
            
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
            // Editor card
            VStack(alignment: .leading, spacing: 16) {
                TextField("Title", text: $brief.title)
                    .font(.system(size: 24, weight: .bold))
                    .textFieldStyle(.plain)
                
                Divider().opacity(0.3)
                
                TextEditor(text: $brief.content)
                    .font(.system(size: 16))
                    .lineSpacing(8)
                    .scrollContentBackground(.hidden)
                    .onChange(of: brief.content) {
                        brief.updatedAt = Date()
                    }
                
                Spacer(minLength: 0)
                
                Text("Last edited \(brief.updatedAt, style: .relative) ago")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(DDTheme.largePadding)
            .background(DDTheme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
            .padding()
        }
        .background(DDTheme.deepBackground)
    }
}

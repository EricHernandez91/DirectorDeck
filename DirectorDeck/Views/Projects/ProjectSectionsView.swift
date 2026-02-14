import SwiftUI

struct ProjectSectionsView: View {
    let project: Project
    @Binding var selectedSection: SidebarSection?
    @Environment(\.modelContext) private var modelContext
    @State private var showNewFolder = false
    @State private var newFolderName = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // PRODUCTION
                sectionGroup(title: "PRODUCTION") {
                    sectionRow(.briefs, icon: "doc.richtext", label: "Creative Briefs", count: project.briefs.count)
                    sectionRow(.interviews, icon: "person.bubble", label: "Interviews", count: project.interviewSubjects.count)
                    sectionRow(.storyboards, icon: "rectangle.split.2x2", label: "Storyboards", count: project.storyboardCards.count)
                    sectionRow(.shotList, icon: "checklist", label: "Shot List", count: project.shotListItems.count)
                }
                
                // ON SET
                sectionGroup(title: "ON SET") {
                    sectionRow(.shootDay, icon: "camera.viewfinder", label: "Shoot Day Mode", count: nil)
                }
                
                // DOCUMENTS
                sectionGroup(title: "DOCUMENTS") {
                    sectionRow(.documents, icon: "archivebox", label: "All Documents", count: project.documents.count)
                    
                    ForEach(Array(project.folders.enumerated()), id: \.element.id) { _, folder in
                        sectionRow(.folder(folder), icon: "folder.fill", label: folder.name, count: nil)
                    }
                }
            }
            .padding(.horizontal, DDTheme.largePadding)
            .padding(.vertical, DDTheme.largePadding)
        }
        .background(
            ZStack {
                DDTheme.deepBackground
                DDTheme.ambientGlow
            }
        )
        .navigationTitle(project.name)
        .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 320)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showNewFolder = true }) {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
        .alert("New Folder", isPresented: $showNewFolder) {
            TextField("Folder Name", text: $newFolderName)
            Button("Cancel", role: .cancel) { newFolderName = "" }
            Button("Create") {
                guard !newFolderName.isEmpty else { return }
                let folder = ProjectFolder(name: newFolderName, project: project)
                modelContext.insert(folder)
                newFolderName = ""
            }
        }
    }
    
    private func sectionGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(title: title)
                .padding(.leading, 4)
                .padding(.bottom, 12)
            
            content()
        }
    }
    
    private func sectionRow(_ section: SidebarSection, icon: String, label: String, count: Int?) -> some View {
        let isSelected = selectedSection == section
        return Button {
            selectedSection = section
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(DDTheme.teal)
                    .frame(width: 24)
                
                Text(label)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                if let count {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: "#1A1A25"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(DDTheme.amber, in: Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AnyShapeStyle(LinearGradient(colors: [DDTheme.teal.opacity(0.08), DDTheme.violet.opacity(0.05)], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color.clear))
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

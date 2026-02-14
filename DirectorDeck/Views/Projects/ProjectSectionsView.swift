import SwiftUI

struct ProjectSectionsView: View {
    let project: Project
    @Binding var selectedSection: SidebarSection?
    @Environment(\.modelContext) private var modelContext
    @State private var showNewFolder = false
    @State private var newFolderName = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Project header
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(DDTheme.tealGradient)
                            .frame(width: 52, height: 52)
                            .overlay {
                                Text(String(project.name.prefix(1)).uppercased())
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .shadow(color: DDTheme.teal.opacity(0.25), radius: 10, y: 3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.name)
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            if !project.projectDescription.isEmpty {
                                Text(project.projectDescription)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.bottom, 4)
                
                // Production
                sectionGroup(title: "PRODUCTION") {
                    sectionRow(.briefs, icon: "doc.richtext", label: "Creative Briefs", count: project.briefs.count)
                    thinDivider()
                    sectionRow(.interviews, icon: "person.bubble", label: "Interviews", count: project.interviewSubjects.count)
                    thinDivider()
                    sectionRow(.storyboards, icon: "rectangle.split.2x2", label: "Storyboards", count: project.storyboardCards.count)
                    thinDivider()
                    sectionRow(.shotList, icon: "checklist", label: "Shot List", count: project.shotListItems.count)
                }
                
                // On Set
                sectionGroup(title: "ON SET") {
                    sectionRow(.shootDay, icon: "camera.viewfinder", label: "Shoot Day Mode", count: nil)
                }
                
                // Documents
                sectionGroup(title: "DOCUMENTS") {
                    sectionRow(.documents, icon: "archivebox", label: "All Documents", count: project.documents.count)
                    
                    ForEach(Array(project.folders.enumerated()), id: \.element.id) { index, folder in
                        thinDivider()
                        sectionRow(.folder(folder), icon: "folder.fill", label: folder.name, count: nil)
                    }
                }
            }
            .padding(.horizontal, DDTheme.largePadding)
            .padding(.vertical, DDTheme.largePadding)
        }
        .background(DDTheme.deepBackground)
        .navigationTitle(project.name)
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
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel(title: title)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .dashboardCard()
        }
    }
    
    private func thinDivider() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.04))
            .frame(height: 1)
            .padding(.leading, 56)
    }
    
    private func sectionRow(_ section: SidebarSection, icon: String, label: String, count: Int?) -> some View {
        Button {
            selectedSection = section
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(DDTheme.teal)
                    .frame(width: 28)
                
                Text(label)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if let count {
                    Text("\(count)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(DDTheme.teal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(DDTheme.teal.opacity(0.1), in: Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary.opacity(0.35))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
}

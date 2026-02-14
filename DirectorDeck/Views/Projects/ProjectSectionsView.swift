import SwiftUI

struct ProjectSectionsView: View {
    let project: Project
    @Binding var selectedSection: SidebarSection?
    @Environment(\.modelContext) private var modelContext
    @State private var showNewFolder = false
    @State private var newFolderName = ""
    
    var body: some View {
        List(selection: $selectedSection) {
            // Project header card
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(DDTheme.tealGradient)
                            .frame(width: 44, height: 44)
                            .overlay {
                                Text(String(project.name.prefix(1)).uppercased())
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .shadow(color: DDTheme.teal.opacity(0.3), radius: 6, y: 2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(project.name)
                                .font(.system(.title3, design: .rounded, weight: .bold))
                            if !project.projectDescription.isEmpty {
                                Text(project.projectDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                    
                    // Stats row with glass pills
                    HStack(spacing: 12) {
                        statPill(count: project.briefs.count, label: "Briefs")
                        statPill(count: project.storyboardCards.count, label: "Boards")
                        statPill(count: project.shotListItems.count, label: "Shots")
                        statPill(count: project.documents.count, label: "Docs")
                    }
                    .padding(.top, 2)
                }
                .padding(.vertical, 6)
            }
            
            Section {
                sectionRow(.briefs, icon: "doc.text.fill", label: "Creative Briefs", count: project.briefs.count)
                sectionRow(.interviews, icon: "person.2.fill", label: "Interviews", count: project.interviewSubjects.count)
                sectionRow(.storyboards, icon: "rectangle.split.3x3.fill", label: "Storyboards", count: project.storyboardCards.count)
                sectionRow(.shotList, icon: "list.bullet.rectangle.fill", label: "Shot List", count: project.shotListItems.count)
            } header: {
                Text("PRODUCTION")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1.2)
            }
            
            Section {
                sectionRow(.shootDay, icon: "video.fill", label: "Shoot Day Mode", count: nil)
            } header: {
                Text("ON SET")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1.2)
            }
            
            Section {
                sectionRow(.documents, icon: "folder.fill", label: "All Documents", count: project.documents.count)
                
                ForEach(project.folders) { folder in
                    sectionRow(.folder(folder), icon: "folder.fill", label: folder.name, count: nil)
                }
                .onDelete(perform: deleteFolders)
            } header: {
                Text("DOCUMENTS")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1.2)
            }
        }
        .listStyle(.sidebar)
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
    
    private func statPill(count: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(DDTheme.teal)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 48)
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
    }
    
    private func sectionRow(_ section: SidebarSection, icon: String, label: String, count: Int?) -> some View {
        NavigationLink(value: section) {
            Label {
                HStack {
                    Text(label)
                        .font(.system(.body, design: .rounded, weight: .medium))
                    Spacer()
                    if let count {
                        Text("\(count)")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundStyle(DDTheme.teal)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(DDTheme.teal.opacity(0.12), in: Capsule())
                    }
                }
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(DDTheme.teal)
            }
        }
    }
    
    private func deleteFolders(at offsets: IndexSet) {
        let folders = project.folders
        for index in offsets {
            modelContext.delete(folders[index])
        }
    }
}

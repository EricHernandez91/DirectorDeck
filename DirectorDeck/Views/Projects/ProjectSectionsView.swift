import SwiftUI

struct ProjectSectionsView: View {
    let project: Project
    @Binding var selectedSection: SidebarSection?
    @Environment(\.modelContext) private var modelContext
    @State private var showNewFolder = false
    @State private var newFolderName = ""
    
    var body: some View {
        List(selection: $selectedSection) {
            Section("Production") {
                sectionRow(.briefs, icon: "doc.text.fill", label: "Creative Briefs", count: project.briefs.count)
                sectionRow(.interviews, icon: "person.2.fill", label: "Interviews", count: project.interviewSubjects.count)
                sectionRow(.storyboards, icon: "rectangle.split.3x3.fill", label: "Storyboards", count: project.storyboardCards.count)
                sectionRow(.shotList, icon: "list.bullet.rectangle.fill", label: "Shot List", count: project.shotListItems.count)
            }
            
            Section("On Set") {
                sectionRow(.shootDay, icon: "video.fill", label: "Shoot Day Mode", count: nil)
            }
            
            Section("Documents") {
                sectionRow(.documents, icon: "folder.fill", label: "All Documents", count: project.documents.count)
                
                ForEach(project.folders) { folder in
                    sectionRow(.folder(folder), icon: "folder.fill", label: folder.name, count: nil)
                }
                .onDelete(perform: deleteFolders)
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
    
    private func sectionRow(_ section: SidebarSection, icon: String, label: String, count: Int?) -> some View {
        NavigationLink(value: section) {
            Label {
                HStack {
                    Text(label)
                    Spacer()
                    if let count {
                        Text("\(count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.quaternary, in: Capsule())
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

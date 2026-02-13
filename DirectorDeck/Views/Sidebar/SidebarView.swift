import SwiftUI
import SwiftData

struct SidebarView: View {
    let projects: [Project]
    @Binding var selectedProject: Project?
    @Binding var selectedSection: SidebarSection?
    @Binding var showNewProject: Bool
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List(selection: $selectedProject) {
            Section {
                ForEach(projects) { project in
                    NavigationLink(value: project) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(DDTheme.teal.gradient)
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Text(String(project.name.prefix(1)).uppercased())
                                        .font(.system(.callout, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.name)
                                    .font(.body.weight(.medium))
                                Text(project.projectDescription.isEmpty ? "No description" : project.projectDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteProjects)
            } header: {
                HStack {
                    Text("Projects")
                        .font(.headline)
                    Spacer()
                    Button(action: { showNewProject = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(DDTheme.teal)
                    }
                }
            }
        }
        .navigationTitle("DirectorDeck")
        .listStyle(.sidebar)
    }
    
    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            let project = projects[index]
            if selectedProject?.id == project.id {
                selectedProject = nil
                selectedSection = nil
            }
            modelContext.delete(project)
        }
    }
}

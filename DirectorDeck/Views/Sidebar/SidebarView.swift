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
                                .fill(DDTheme.tealGradient)
                                .frame(width: 38, height: 38)
                                .overlay {
                                    Text(String(project.name.prefix(1)).uppercased())
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                .overlay(Circle().stroke(DDTheme.violet.opacity(0.15), lineWidth: 1))
                                .shadow(color: DDTheme.teal.opacity(0.3), radius: 6, y: 2)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(project.name)
                                    .font(.system(size: 15, weight: .semibold))
                                Text(project.projectDescription.isEmpty ? "No description" : project.projectDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onDelete(perform: deleteProjects)
            } header: {
                HStack {
                    Text("PROJECTS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(1.5)
                    Spacer()
                    Button(action: { showNewProject = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(DDTheme.teal)
                            .font(.title3)
                    }
                }
            }
        }
        .navigationTitle("DirectorDeck")
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    Button {
                        SampleDataService.importCFAProject(context: modelContext)
                    } label: {
                        Label("Import CFA Sample Project", systemImage: "square.and.arrow.down")
                    }
                    Button {
                        SampleDataService.loadAllSampleProjects(context: modelContext)
                    } label: {
                        Label("Load All Sample Projects", systemImage: "tray.and.arrow.down")
                    }
                } label: {
                    Label("Import", systemImage: "ellipsis.circle")
                        .foregroundStyle(DDTheme.teal)
                }
            }
        }
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

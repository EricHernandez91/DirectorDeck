import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]
    @State private var selectedProject: Project?
    @State private var selectedSection: SidebarSection?
    @State private var showNewProject = false
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(
                projects: projects,
                selectedProject: $selectedProject,
                selectedSection: $selectedSection,
                showNewProject: $showNewProject
            )
        } content: {
            if let project = selectedProject {
                ProjectSectionsView(
                    project: project,
                    selectedSection: $selectedSection
                )
            } else {
                EmptyStateView(
                    icon: "film.stack",
                    title: "Select a Project",
                    subtitle: "Choose a project from the sidebar or create a new one",
                    action: { showNewProject = true },
                    actionLabel: "New Project"
                )
            }
        } detail: {
            if let project = selectedProject, let section = selectedSection {
                DetailRouter(project: project, section: section)
            } else {
                EmptyStateView(
                    icon: "rectangle.on.rectangle",
                    title: "DirectorDeck",
                    subtitle: "Select a section to get started"
                )
            }
        }
        .tint(DDTheme.teal)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showNewProject) {
            NewProjectSheet { name, description in
                let project = Project(name: name, projectDescription: description)
                modelContext.insert(project)
                selectedProject = project
            }
        }
    }
}

enum SidebarSection: Hashable {
    case briefs
    case interviews
    case storyboards
    case shotList
    case shootDay
    case documents
    case folder(ProjectFolder)
}

struct DetailRouter: View {
    let project: Project
    let section: SidebarSection
    
    var body: some View {
        switch section {
        case .briefs:
            BriefsListView(project: project)
        case .interviews:
            InterviewsListView(project: project)
        case .storyboards:
            StoryboardGridView(project: project)
        case .shotList:
            ShotListView(project: project)
        case .shootDay:
            ShootDayView(project: project)
        case .documents:
            DocumentsView(project: project)
        case .folder(let folder):
            DocumentsView(project: project, folder: folder)
        }
    }
}

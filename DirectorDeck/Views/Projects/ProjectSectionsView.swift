import SwiftUI

struct ProjectSectionsView: View {
    let project: Project
    @Binding var selectedSection: SidebarSection?
    @Environment(\.modelContext) private var modelContext
    @State private var showNewFolder = false
    @State private var newFolderName = ""
    
    private var completedShots: Int { project.shotListItems.filter(\.isCompleted).count }
    private var totalShots: Int { project.shotListItems.count }
    private var progress: Double { totalShots > 0 ? Double(completedShots) / Double(totalShots) : 0 }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DDTheme.sectionSpacing) {
                // Project header
                HStack(spacing: 14) {
                    Circle()
                        .fill(DDTheme.tealGradient)
                        .frame(width: 48, height: 48)
                        .overlay {
                            Text(String(project.name.prefix(1)).uppercased())
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: DDTheme.teal.opacity(0.3), radius: 8, y: 2)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(project.name)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        if !project.projectDescription.isEmpty {
                            Text(project.projectDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
                .padding(.bottom, 4)
                
                // Hero stats grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    StatCard(value: "\(totalShots)", label: "Total Shots", color: DDTheme.teal)
                    StatCard(value: "\(completedShots)", label: "Completed", color: DDTheme.green)
                    StatCard(value: "\(project.storyboardCards.count)", label: "Storyboards", color: DDTheme.orange)
                    StatCard(value: "\(project.documents.count)", label: "Documents", color: DDTheme.softBlue)
                }
                
                // Progress card
                if totalShots > 0 {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Shoot Progress")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(DDTheme.teal)
                        }
                        
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.06))
                                    .frame(height: 10)
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(DDTheme.tealGradient)
                                    .frame(width: geo.size.width * progress, height: 10)
                                    .animation(.spring(response: 0.6), value: progress)
                            }
                        }
                        .frame(height: 10)
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Circle().fill(DDTheme.green).frame(width: 8, height: 8)
                                Text("\(completedShots) done")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            HStack(spacing: 6) {
                                Circle().fill(Color.white.opacity(0.2)).frame(width: 8, height: 8)
                                Text("\(totalShots - completedShots) remaining")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(18)
                    .dashboardCard()
                }
                
                // Production section
                SectionLabel(title: "PRODUCTION")
                
                VStack(spacing: 2) {
                    sectionRow(.briefs, icon: "doc.richtext", label: "Creative Briefs", count: project.briefs.count)
                    sectionRow(.interviews, icon: "person.bubble", label: "Interviews", count: project.interviewSubjects.count)
                    sectionRow(.storyboards, icon: "rectangle.split.2x2", label: "Storyboards", count: project.storyboardCards.count)
                    sectionRow(.shotList, icon: "checklist", label: "Shot List", count: project.shotListItems.count)
                }
                .dashboardCard()
                
                // On Set section
                SectionLabel(title: "ON SET")
                
                VStack(spacing: 2) {
                    sectionRow(.shootDay, icon: "camera.viewfinder", label: "Shoot Day Mode", count: nil)
                }
                .dashboardCard()
                
                // Documents section
                SectionLabel(title: "DOCUMENTS")
                
                VStack(spacing: 2) {
                    sectionRow(.documents, icon: "archivebox", label: "All Documents", count: project.documents.count)
                    
                    ForEach(project.folders) { folder in
                        sectionRow(.folder(folder), icon: "folder.fill", label: folder.name, count: nil)
                    }
                }
                .dashboardCard()
            }
            .padding(DDTheme.largePadding)
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
                        .background(DDTheme.teal.opacity(0.12), in: Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay {
                    Circle()
                        .fill(color)
                        .frame(width: 10, height: 10)
                }
            
            Text(value)
                .font(.system(.title, design: .rounded, weight: .bold))
            
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .dashboardCard()
    }
}

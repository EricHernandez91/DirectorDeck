import SwiftUI

struct NewProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    let onCreate: (String, String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Project Name", text: $name)
                        .font(.title3)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your project will include sections for:")
                            .foregroundStyle(.secondary)
                        Label("Creative Briefs", systemImage: "doc.text.fill")
                        Label("Interview Questions", systemImage: "person.2.fill")
                        Label("Storyboards", systemImage: "rectangle.split.3x3.fill")
                        Label("Shot Lists", systemImage: "list.bullet.rectangle.fill")
                        Label("Document Import", systemImage: "folder.fill")
                    }
                    .font(.subheadline)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(name, description)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

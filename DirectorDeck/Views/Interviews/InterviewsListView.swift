import SwiftUI
import SwiftData

struct InterviewsListView: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var selectedSubject: InterviewSubject?
    @State private var showNewSubject = false
    @State private var newSubjectName = ""
    @State private var newSubjectRole = ""
    
    var subjects: [InterviewSubject] {
        project.interviewSubjects.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        Group {
            if subjects.isEmpty {
                EmptyStateView(
                    icon: "person.2.fill",
                    title: "No Interview Subjects",
                    subtitle: "Add subjects and organize questions for each",
                    action: { showNewSubject = true },
                    actionLabel: "Add Subject"
                )
            } else {
                HStack(spacing: 0) {
                    subjectsList
                    Divider()
                    if let subject = selectedSubject {
                        InterviewQuestionsView(subject: subject)
                    } else {
                        EmptyStateView(icon: "person.fill.questionmark", title: "Select a Subject", subtitle: "Choose an interview subject to manage questions")
                    }
                }
            }
        }
        .navigationTitle("Interviews")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showNewSubject = true }) {
                    Label("Add Subject", systemImage: "plus")
                }
            }
        }
        .alert("New Interview Subject", isPresented: $showNewSubject) {
            TextField("Name", text: $newSubjectName)
            TextField("Role / Title", text: $newSubjectRole)
            Button("Cancel", role: .cancel) { newSubjectName = ""; newSubjectRole = "" }
            Button("Add") {
                guard !newSubjectName.isEmpty else { return }
                let subject = InterviewSubject(name: newSubjectName, role: newSubjectRole, project: project)
                modelContext.insert(subject)
                newSubjectName = ""
                newSubjectRole = ""
                selectedSubject = subject
            }
        }
    }
    
    private var subjectsList: some View {
        List(subjects, selection: $selectedSubject) { subject in
            NavigationLink(value: subject) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subject.name)
                        .font(.headline)
                    if !subject.role.isEmpty {
                        Text(subject.role)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    let asked = subject.questions.filter(\.isAsked).count
                    let total = subject.questions.count
                    if total > 0 {
                        Text("\(asked)/\(total) asked")
                            .font(.caption2)
                            .foregroundStyle(DDTheme.teal)
                    }
                }
                .padding(.vertical, 4)
            }
            .swipeActions {
                Button("Delete", role: .destructive) {
                    if selectedSubject?.id == subject.id { selectedSubject = nil }
                    modelContext.delete(subject)
                }
            }
        }
        .listStyle(.sidebar)
        .frame(width: 260)
    }
}

struct InterviewQuestionsView: View {
    @Bindable var subject: InterviewSubject
    @Environment(\.modelContext) private var modelContext
    @State private var newQuestionText = ""
    @State private var editingQuestion: InterviewQuestion?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(.title2.weight(.semibold))
                if !subject.role.isEmpty {
                    Text(subject.role)
                        .foregroundStyle(.secondary)
                }
                let asked = subject.questions.filter(\.isAsked).count
                let total = subject.questions.count
                if total > 0 {
                    ProgressView(value: Double(asked), total: Double(total))
                        .tint(DDTheme.teal)
                        .padding(.top, 4)
                    Text("\(asked) of \(total) questions asked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Questions list
            List {
                ForEach(subject.sortedQuestions) { question in
                    QuestionRow(question: question, onEdit: { editingQuestion = question })
                }
                .onMove(perform: moveQuestions)
                .onDelete(perform: deleteQuestions)
            }
            .listStyle(.plain)
            
            Divider()
            
            // Add question
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(DDTheme.teal)
                    .font(.title3)
                TextField("Add a question...", text: $newQuestionText)
                    .textFieldStyle(.plain)
                    .onSubmit(addQuestion)
                Button("Add", action: addQuestion)
                    .disabled(newQuestionText.isEmpty)
                    .buttonStyle(.borderedProminent)
                    .tint(DDTheme.teal)
            }
            .padding()
        }
        .sheet(item: $editingQuestion) { question in
            EditQuestionSheet(question: question)
        }
    }
    
    private func addQuestion() {
        guard !newQuestionText.isEmpty else { return }
        let q = InterviewQuestion(text: newQuestionText, orderIndex: subject.questions.count, subject: subject)
        modelContext.insert(q)
        newQuestionText = ""
    }
    
    private func moveQuestions(from source: IndexSet, to destination: Int) {
        var sorted = subject.sortedQuestions
        sorted.move(fromOffsets: source, toOffset: destination)
        for (i, q) in sorted.enumerated() {
            q.orderIndex = i
        }
    }
    
    private func deleteQuestions(at offsets: IndexSet) {
        let sorted = subject.sortedQuestions
        for index in offsets {
            modelContext.delete(sorted[index])
        }
    }
}

struct QuestionRow: View {
    @Bindable var question: InterviewQuestion
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    question.isAsked.toggle()
                }
            } label: {
                Image(systemName: question.isAsked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(question.isAsked ? DDTheme.teal : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(question.text)
                    .font(.body)
                    .strikethrough(question.isAsked)
                    .foregroundStyle(question.isAsked ? .secondary : .primary)
                if !question.notes.isEmpty {
                    Text(question.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil.circle")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

struct EditQuestionSheet: View {
    @Bindable var question: InterviewQuestion
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    TextField("Question", text: $question.text, axis: .vertical)
                        .lineLimit(3...8)
                }
                Section("Notes") {
                    TextField("Notes", text: $question.notes, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle("Edit Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

import SwiftUI
import SwiftData

struct InterviewsListView: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @Environment(InterviewRecordingService.self) private var recorder
    @State private var selectedSubject: InterviewSubject?
    @State private var showNewSubject = false
    @State private var newSubjectName = ""
    @State private var newSubjectRole = ""
    @State private var showRecorder = false
    @State private var selectedRecording: InterviewRecording?
    
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
        .background(DDTheme.deepBackground)
        .navigationTitle("Interviews")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button(action: { showRecorder = true }) {
                        Label("Record", systemImage: "mic.circle.fill")
                            .foregroundStyle(.red)
                    }
                    Button(action: { showNewSubject = true }) {
                        Label("Add Subject", systemImage: "plus")
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            RecordingBannerView {
                showRecorder = true
            }
            .padding(.bottom, 8)
        }
        .fullScreenCover(isPresented: $showRecorder) {
            NavigationStack {
                InterviewRecorderView(project: project, subject: selectedSubject)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                if recorder.isActive {
                                    _ = recorder.stop()
                                    recorder.reset()
                                }
                                showRecorder = false
                            }
                        }
                    }
            }
        }
        .sheet(item: $selectedRecording) { recording in
            NavigationStack {
                RecordingDetailView(recording: recording)
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
                HStack(spacing: 12) {
                    Circle()
                        .fill(DDTheme.tealGradient)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Text(String(subject.name.prefix(1)).uppercased())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(subject.name)
                            .font(.system(size: 15, weight: .semibold))
                        if !subject.role.isEmpty {
                            Text(subject.role)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        let asked = subject.questions.filter(\.isAsked).count
                        let total = subject.questions.count
                        if total > 0 {
                            HStack(spacing: 6) {
                                ProgressView(value: Double(asked), total: Double(total))
                                    .tint(DDTheme.teal)
                                    .frame(width: 50)
                                Text("\(asked)/\(total)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(DDTheme.teal)
                            }
                        }
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
        .frame(width: 280)
        .safeAreaInset(edge: .bottom) {
            if !project.interviewRecordings.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    SectionLabel(title: "Recordings")
                        .padding(.horizontal)
                    ForEach(project.interviewRecordings.sorted(by: { $0.date > $1.date })) { rec in
                        Button { selectedRecording = rec } label: {
                            HStack(spacing: 10) {
                                Image(systemName: rec.isProcessing ? "waveform" : "waveform.circle.fill")
                                    .foregroundStyle(rec.isProcessing ? .orange : DDTheme.teal)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(rec.subjectName)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text(rec.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
                .background(DDTheme.surfaceBackground)
            }
        }
    }
}

struct InterviewQuestionsView: View {
    @Bindable var subject: InterviewSubject
    @Environment(\.modelContext) private var modelContext
    @Environment(InterviewRecordingService.self) private var recorder
    @State private var newQuestionText = ""
    @State private var editingQuestion: InterviewQuestion?
    @State private var showRecorder = false
    
    var askedCount: Int { subject.questions.filter(\.isAsked).count }
    var totalCount: Int { subject.questions.count }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(subject.name)
                    .font(.system(size: 22, weight: .bold))
                if !subject.role.isEmpty {
                    Text(subject.role)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if totalCount > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        ProgressView(value: Double(askedCount), total: Double(totalCount))
                            .tint(DDTheme.teal)
                        Text("\(askedCount) of \(totalCount) questions asked")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DDTheme.cardGradient)
            
            // Questions as cards (drag to reorder)
            List {
                ForEach(subject.sortedQuestions) { question in
                    QuestionCardRow(question: question, onEdit: { editingQuestion = question })
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                }
                .onMove(perform: moveQuestions)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            
            Divider()
            
            // Add question
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(DDTheme.teal)
                    .font(.title3)
                TextField("Add a question...", text: $newQuestionText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .onSubmit(addQuestion)
                Button("Add", action: addQuestion)
                    .disabled(newQuestionText.isEmpty)
                    .buttonStyle(.borderedProminent)
                    .tint(DDTheme.teal)
            }
            .padding()
        }
        .background(DDTheme.deepBackground)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showRecorder = true } label: {
                    Label("Record Interview", systemImage: "mic.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                }
            }
        }
        .fullScreenCover(isPresented: $showRecorder) {
            NavigationStack {
                InterviewRecorderView(project: subject.project!, subject: subject)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                if recorder.isActive {
                                    _ = recorder.stop()
                                    recorder.reset()
                                }
                                showRecorder = false
                            }
                        }
                    }
            }
        }
        .sheet(item: $editingQuestion) { question in
            EditQuestionSheet(question: question)
        }
    }
    
    private func moveQuestions(from source: IndexSet, to destination: Int) {
        var ordered = subject.sortedQuestions
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, question) in ordered.enumerated() {
            question.orderIndex = index
        }
    }
    
    private func addQuestion() {
        guard !newQuestionText.isEmpty else { return }
        let q = InterviewQuestion(text: newQuestionText, orderIndex: subject.questions.count, subject: subject)
        modelContext.insert(q)
        newQuestionText = ""
    }
}

struct QuestionCardRow: View {
    @Bindable var question: InterviewQuestion
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(question.text)
                    .font(.system(size: 16))
                    .foregroundStyle(question.isAsked ? .secondary : .primary)
                if !question.notes.isEmpty {
                    Text(question.notes)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            // Asked toggle pill
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    question.isAsked.toggle()
                }
            } label: {
                Text(question.isAsked ? "Asked" : "Not Asked")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(question.isAsked ? .white : .secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(question.isAsked ? DDTheme.teal : Color.white.opacity(0.06), in: Capsule())
            }
            .buttonStyle(.plain)
            
            Button(action: onEdit) {
                Image(systemName: "pencil.circle")
                    .foregroundStyle(.white.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .dashboardCard()
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: question.isAsked)
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

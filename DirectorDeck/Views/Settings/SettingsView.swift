import SwiftUI

struct SettingsView: View {
    @AppStorage("openai_api_key") private var apiKey = ""
    @State private var editingKey = ""
    @State private var showKey = false
    @State private var saved = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("OpenAI API Key", systemImage: "key.fill")
                            .font(.headline)
                            .foregroundStyle(DDTheme.teal)
                        
                        Text("Used to generate AI-powered interview summaries with GPT-4o-mini. Your key is stored locally on this device.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Group {
                            if showKey {
                                TextField("sk-...", text: $editingKey)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("sk-...", text: $editingKey)
                                    .textInputAutocapitalization(.never)
                            }
                        }
                        .font(.system(size: 14, design: .monospaced))
                        
                        Button {
                            showKey.toggle()
                        } label: {
                            Image(systemName: showKey ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button {
                        apiKey = editingKey.trimmingCharacters(in: .whitespacesAndNewlines)
                        saved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { saved = false }
                    } label: {
                        HStack {
                            Image(systemName: saved ? "checkmark.circle.fill" : "square.and.arrow.down")
                            Text(saved ? "Saved!" : "Save Key")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(saved ? DDTheme.green : DDTheme.teal)
                    .disabled(editingKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    if !apiKey.isEmpty {
                        Button(role: .destructive) {
                            apiKey = ""
                            editingKey = ""
                        } label: {
                            Label("Remove Key", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                } header: {
                    Text("AI Summary")
                } footer: {
                    Text("Get your API key at platform.openai.com. Costs ~$0.01 per interview summary.")
                }
                
                Section("About") {
                    HStack {
                        Text("AI Model")
                        Spacer()
                        Text("GPT-4o-mini")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Status")
                        Spacer()
                        if apiKey.isEmpty {
                            Label("Not Configured", systemImage: "xmark.circle")
                                .foregroundStyle(.orange)
                                .font(.subheadline)
                        } else {
                            Label("Ready", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(DDTheme.green)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { editingKey = apiKey }
        }
    }
}

import Foundation

struct GPTSummaryService {
    
    static var apiKey: String {
        UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }
    
    static var isConfigured: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    static func generateSummary(transcript: String, markers: [InterviewMarker]) async throws -> String {
        guard isConfigured else {
            throw GPTError.noAPIKey
        }
        
        let markerList = markers.sorted { $0.timestamp < $1.timestamp }
            .map { "[\($0.formattedTimestamp)] \($0.label)" + ($0.notes.isEmpty ? "" : " — \($0.notes)") }
            .joined(separator: "\n")
        
        let systemPrompt = """
        You are an expert film production assistant analyzing an interview recording transcript. \
        Generate a structured, actionable summary for a film director or editor. \
        Always reference specific timecodes in [HH:MM:SS] format so the editor can quickly locate moments. \
        Be concise but thorough.
        """
        
        let userPrompt = """
        Here is the transcript of an interview recording, along with timecoded markers the director placed during recording.
        
        ## Markers
        \(markerList.isEmpty ? "(No markers placed)" : markerList)
        
        ## Transcript
        \(transcript.prefix(12000))
        
        ---
        
        Please generate a structured summary with these sections:
        
        1. **Key Themes** — The 3-5 main topics or themes discussed, with timecode references
        2. **Notable Quotes** — Direct quotes worth highlighting, each with its approximate timecode
        3. **Action Items** — Any follow-ups, tasks, or things the director should revisit
        4. **Emotional Highlights** — Moments of strong emotion, humor, or authenticity (reference marker tags if relevant)
        5. **Editor's Notes** — A brief structured summary organized chronologically by the marker timestamps, useful for building a rough cut
        
        Use timecodes like [00:05:23] throughout. Keep the summary concise and production-ready.
        """
        
        let messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userPrompt]
        ]
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "temperature": 0.4,
            "max_tokens": 2000
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 60
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GPTError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            if httpResponse.statusCode == 401 {
                throw GPTError.invalidAPIKey
            }
            throw GPTError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw GPTError.invalidResponse
        }
        
        return content
    }
    
    enum GPTError: LocalizedError {
        case noAPIKey
        case invalidAPIKey
        case invalidResponse
        case apiError(statusCode: Int, message: String)
        
        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                return "No OpenAI API key configured. Add one in Settings."
            case .invalidAPIKey:
                return "Invalid OpenAI API key. Check your key in Settings."
            case .invalidResponse:
                return "Unexpected response from OpenAI API."
            case .apiError(let code, let msg):
                return "OpenAI API error (\(code)): \(msg)"
            }
        }
    }
}

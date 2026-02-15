import Foundation
import UniformTypeIdentifiers

struct PremiereXMLExporter {
    static func generateXML(for recording: InterviewRecording) -> String {
        let fps = 30
        let totalFrames = Int(recording.duration * Double(fps))
        let fileName = (recording.audioFilePath as NSString).lastPathComponent
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = docs.appendingPathComponent(recording.audioFilePath)
        
        var markersXML = ""
        for marker in recording.sortedMarkers {
            let frame = Int(marker.timestamp * Double(fps))
            let comment = escapeXML(marker.notes.isEmpty ? marker.label : "\(marker.label): \(marker.notes)")
            markersXML += """
                            <marker>
                                <comment>\(comment)</comment>
                                <name>\(escapeXML(marker.label))</name>
                                <in>\(frame)</in>
                                <out>-1</out>
                            </marker>\n
            """
        }
        
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE xmeml>
        <xmeml version="4">
            <sequence>
                <name>\(escapeXML(recording.subjectName)) Interview</name>
                <duration>\(totalFrames)</duration>
                <rate>
                    <timebase>\(fps)</timebase>
                    <ntsc>FALSE</ntsc>
                </rate>
                <media>
                    <audio>
                        <track>
                            <clipitem>
                                <name>\(escapeXML(fileName))</name>
                                <duration>\(totalFrames)</duration>
                                <rate>
                                    <timebase>\(fps)</timebase>
                                    <ntsc>FALSE</ntsc>
                                </rate>
                                <start>0</start>
                                <end>\(totalFrames)</end>
                                <in>0</in>
                                <out>\(totalFrames)</out>
                                <file id="file-1">
                                    <name>\(escapeXML(fileName))</name>
                                    <pathurl>file://localhost\(escapeXML(fileURL.path))</pathurl>
                                    <media>
                                        <audio>
                                            <channelcount>1</channelcount>
                                        </audio>
                                    </media>
                                </file>
        \(markersXML)
                            </clipitem>
                        </track>
                    </audio>
                </media>
            </sequence>
        </xmeml>
        """
    }
    
    static func exportURL(for recording: InterviewRecording) -> URL? {
        let xml = generateXML(for: recording)
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(recording.subjectName.replacingOccurrences(of: " ", with: "_"))_interview.xml"
        let url = tempDir.appendingPathComponent(fileName)
        do {
            try xml.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
    
    private static func escapeXML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

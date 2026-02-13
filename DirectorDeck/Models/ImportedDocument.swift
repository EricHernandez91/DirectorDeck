import Foundation
import SwiftData

enum DocumentType: String, Codable, CaseIterable {
    case pdf = "PDF"
    case image = "Image"
    case other = "Other"
}

@Model
final class ImportedDocument {
    var id: UUID
    var name: String
    var documentTypeRaw: String
    var fileData: Data?
    var folderName: String
    var createdAt: Date
    var project: Project?
    
    var documentType: DocumentType {
        get { DocumentType(rawValue: documentTypeRaw) ?? .other }
        set { documentTypeRaw = newValue.rawValue }
    }
    
    init(name: String, documentType: DocumentType, fileData: Data? = nil, folderName: String = "General", project: Project? = nil) {
        self.id = UUID()
        self.name = name
        self.documentTypeRaw = documentType.rawValue
        self.fileData = fileData
        self.folderName = folderName
        self.createdAt = Date()
        self.project = project
    }
}

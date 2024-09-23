import Foundation

struct MediaFile: Identifiable, Codable {
    let id = UUID()
    let name: String
    let url: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case name, url, type
    }
}

enum DownloadState {
    case notStarted
    case inProgress(progress: Double)
    case completed
    case failed
}

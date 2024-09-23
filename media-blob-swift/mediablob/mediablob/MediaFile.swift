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

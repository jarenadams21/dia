import Foundation

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    private let baseURL = "http://10.0.0.129:3000"

    func fetchMediaList(completion: @escaping ([MediaFile]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/media-list") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data else {
                print("Error fetching media list: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            do {
                let mediaList = try JSONDecoder().decode([MediaFile].self, from: data)
                completion(mediaList)
            } catch {
                print("Error decoding media list: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}

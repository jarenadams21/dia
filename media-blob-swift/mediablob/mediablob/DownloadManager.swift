// DownloadManager.swift

import Foundation
import Combine

class DownloadManager: ObservableObject {
    static let shared = DownloadManager()

    @Published var downloadProgress: Double = 0.0

    func download(mediaFile: MediaFile, progressHandler: @escaping (Double) -> Void, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: mediaFile.url) else {
            print("Invalid media file URL: \(mediaFile.url)")
            completion(false)
            return
        }

        let destinationURL = getDestinationURL(for: mediaFile.name)

        // Check if the file is already downloaded
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            print("File already exists at path: \(destinationURL.path)")
            completion(true)
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error = error {
                print("Error downloading file: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let tempURL = tempURL else {
                print("No temporary file URL")
                completion(false)
                return
            }

            do {
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                print("File successfully moved to \(destinationURL.path)")
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Error moving downloaded file: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }

        // Observe download progress
        let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                self.downloadProgress = progress.fractionCompleted
                progressHandler(progress.fractionCompleted)
            }
        }

        task.resume()
    }

    func isDownloaded(mediaFile: MediaFile) -> Bool {
        let destinationURL = getDestinationURL(for: mediaFile.name)
        return FileManager.default.fileExists(atPath: destinationURL.path)
    }

    public func getDestinationURL(for fileName: String) -> URL {
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }
}

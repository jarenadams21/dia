import Foundation
import Combine

class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloading: Bool = false

    func download(mediaFile: MediaFile, completion: @escaping () -> Void) {
        guard let url = URL(string: mediaFile.url) else {
            print("Invalid media file URL")
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
            guard let tempURL = tempURL, error == nil else {
                print("Error downloading file: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Move downloaded file to the documents directory
            let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(mediaFile.name)
            do {
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("Error moving downloaded file: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    func batchDownload(mediaFiles: [MediaFile], completion: @escaping (Bool) -> Void) {
        var totalFiles = mediaFiles.count
        var completedFiles = 0
        
        for mediaFile in mediaFiles {
            download(mediaFile: mediaFile) {
                completedFiles += 1
                self.downloadProgress = Double(completedFiles) / Double(totalFiles)
                
                if completedFiles == totalFiles {
                    completion(true)  // All files downloaded
                }
            }
        }
    }

    func downloadWithProgress(url: URL, fileName: String, completion: @escaping () -> Void) {
        var observation: NSKeyValueObservation?
        
        let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
            guard let tempURL = tempURL, error == nil else {
                print("Error downloading file: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
            do {
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("Error moving downloaded file: \(error.localizedDescription)")
            }
        }

        observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                self.downloadProgress = progress.fractionCompleted
            }
        }

        task.resume()
    }
}

import SwiftUI
import AVKit

class MediaFileItem: Identifiable, ObservableObject {
    let id = UUID()
    let mediaFile: MediaFile
    @Published var downloadState: DownloadState = .notStarted

    init(mediaFile: MediaFile) {
        self.mediaFile = mediaFile
        if isDownloaded() {
            self.downloadState = .completed
        }
    }

    func isDownloaded() -> Bool {
        let destinationURL = getDestinationURL()
        return FileManager.default.fileExists(atPath: destinationURL.path)
    }

    func getDestinationURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(mediaFile.name)
    }
}

struct ContentView: View {
    
    @frozen private enum Constants {
        
        struct TaggedURL: Identifiable {
            let id = UUID()
            var url: URL
        }
    }
    @State private var mediaFileItems: [MediaFileItem] = []
    @State private var selectedMediaURL: Constants.TaggedURL?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    let baseURL = "http://10.0.0.129:3000"

    var body: some View {
        NavigationView {
            List {
                ForEach(mediaFileItems) { item in
                    HStack {
                        Text(item.mediaFile.name)
                            .font(.headline)
                        Spacer()
                        switch item.downloadState {
                        case .notStarted:
                            Button("Download") {
                                download(mediaFileItem: item)
                            }
                        case .inProgress(let progress):
                            ProgressView(value: progress)
                                .frame(width: 100)
                        case .completed:
                            Text("Downloaded")
                                .foregroundColor(.green)
                        case .failed:
                            Text("Failed")
                                .foregroundColor(.red)
                            Button("Retry") {
                                download(mediaFileItem: item)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        openMediaFile(mediaFileItem: item)
                    }
                }
            }
            .navigationTitle("Media Files")
            .onAppear(perform: fetchMediaList)
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("OK")))
            }
            .sheet(item: $selectedMediaURL) { taggedurl in
                 let landing = taggedurl.url
                MediaPlayerView(url: landing)
            }
        }
    }

    func fetchMediaList() {
        guard let url = URL(string: "\(baseURL)/media-list") else {
            errorMessage = "Invalid server URL."
            showErrorAlert = true
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Failed to fetch media list: \(error.localizedDescription)"
                    showErrorAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received from server."
                    showErrorAlert = true
                }
                return
            }

            do {
                let mediaList = try JSONDecoder().decode([MediaFile].self, from: data)
                DispatchQueue.main.async {
                    self.mediaFileItems = mediaList.map { MediaFileItem(mediaFile: $0) }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode media list."
                    showErrorAlert = true
                }
            }
        }.resume()
    }

    func download(mediaFileItem: MediaFileItem) {
        guard let url = URL(string: mediaFileItem.mediaFile.url) else {
            errorMessage = "Invalid media URL."
            showErrorAlert = true
            return
        }

        let destinationURL = mediaFileItem.getDestinationURL()

        // Skip if already downloaded
        if mediaFileItem.isDownloaded() {
            openMediaFile(mediaFileItem: mediaFileItem)
            return
        }

        mediaFileItem.downloadState = .inProgress(progress: 0.0)

        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    mediaFileItem.downloadState = .failed
                    errorMessage = "Download failed: \(error.localizedDescription)"
                    showErrorAlert = true
                }
                return
            }

            guard let tempURL = tempURL else {
                DispatchQueue.main.async {
                    mediaFileItem.downloadState = .failed
                    errorMessage = "Temporary file missing."
                    showErrorAlert = true
                }
                return
            }

            do {
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                DispatchQueue.main.async {
                    mediaFileItem.downloadState = .completed
                    self.openMediaFile(mediaFileItem: mediaFileItem)
                }
            } catch {
                DispatchQueue.main.async {
                    mediaFileItem.downloadState = .failed
                    errorMessage = "File move failed: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }

        // Observe download progress
        let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                mediaFileItem.downloadState = .inProgress(progress: progress.fractionCompleted)
            }
        }

        task.resume()
    }

    func openMediaFile(mediaFileItem: MediaFileItem) {
        let destinationURL = mediaFileItem.getDestinationURL()
        if mediaFileItem.isDownloaded() {
            // Safely set selectedMediaURL with an optional binding
            selectedMediaURL = Constants.TaggedURL(url: destinationURL)
        } else {
            download(mediaFileItem: mediaFileItem)
        }
    }
}

import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager.shared
    @StateObject private var downloadManager = DownloadManager.shared

    @State private var mediaFiles: [MediaFile] = []
    @State private var showDownloadOverlay = false
    @State private var downloadCompleted = false
    @State private var showAudioPlayer = false

    @State private var showPreview = false
    @State private var showVideoPlayer = false
    @State private var previewURL: URL?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            List(mediaFiles) { mediaFile in
                HStack {
                    Image(systemName: iconName(for: mediaFile.type))
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 10)
                    VStack(alignment: .leading) {
                        Text(mediaFile.name)
                            .font(.headline)
                            .lineLimit(1)
                        Text(mediaFile.type.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if isDownloaded(mediaFile: mediaFile) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    openMediaFile(mediaFile: mediaFile)
                }
            }
            .navigationTitle("Media Files")
            .navigationBarItems(trailing:
                Button(action: {
                    batchDownload()
                }) {
                    Text("Batch Grab")
                }
            )
        }
        .onAppear {
            fetchMediaList()
        }
        .overlay(
            downloadOverlay()
        )
        .sheet(isPresented: $showPreview) {
            if let previewURL = previewURL {
                QuickLookPreview(url: previewURL)
            }
        }
        .sheet(isPresented: $showAudioPlayer) {
            if let previewURL = previewURL {
                AudioPlayerView(url: previewURL)
            }
        }
        .fullScreenCover(isPresented: $showVideoPlayer) {
            if let previewURL = previewURL {
                VideoPlayerView(url: previewURL)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    func fetchMediaList() {
        networkManager.fetchMediaList { mediaList in
            if let mediaList = mediaList {
                DispatchQueue.main.async {
                    self.mediaFiles = mediaList
                }
            }
        }
    }

    func batchDownload() {
        downloadManager.downloadProgress = 0.0
        showDownloadOverlay = true
        downloadCompleted = false

        DispatchQueue.global(qos: .background).async {
            downloadManager.batchDownload(mediaFiles: mediaFiles) {_ in 
                DispatchQueue.main.async {
                    downloadCompleted = true
                }
            }
        }
    }

    func isDownloaded(mediaFile: MediaFile) -> Bool {
        let destinationURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(mediaFile.name)
        return FileManager.default.fileExists(atPath: destinationURL.path)
    }

    func openMediaFile(mediaFile: MediaFile) {
        let destinationURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(mediaFile.name)

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            DispatchQueue.main.async {
                self.previewURL = destinationURL
                switch mediaFile.type {
                case "video":
                    self.showVideoPlayer = true
                case "audio":
                    self.showAudioPlayer = true
                default:
                    self.showPreview = true
                }
            }
        } else {
            downloadManager.download(mediaFile: mediaFile) {
                DispatchQueue.main.async {
                    self.previewURL = destinationURL
                    switch mediaFile.type {
                    case "video":
                        self.showVideoPlayer = true
                    case "audio":
                        self.showAudioPlayer = true
                    default:
                        self.showPreview = true
                    }
                }
            }
        }
    }

    func iconName(for type: String) -> String {
        switch type {
        case "video":
            return "video"
        case "audio":
            return "music.note"
        case "image":
            return "photo"
        case "document":
            return "doc"
        default:
            return "questionmark"
        }
    }

    @ViewBuilder
    func downloadOverlay() -> some View {
        if showDownloadOverlay {
            VStack {
                if downloadCompleted {
                    Text("Download Complete")
                        .font(.headline)
                        .padding()
                    Button(action: {
                        showDownloadOverlay = false
                    }) {
                        Text("OK")
                            .padding()
                    }
                } else {
                    Text("Downloading...")
                        .font(.headline)
                        .padding()
                    ProgressView(value: downloadManager.downloadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding()
                }
            }
            .frame(width: 200, height: 150)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}

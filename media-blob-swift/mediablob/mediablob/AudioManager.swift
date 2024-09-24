import SwiftUI
import AVKit
import AVFoundation

struct MediaPlayerView: View {
    let url: URL
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    var body: some View {
        if url.pathExtension.lowercased() == "mp3" {
            AudioPlayerView(audioURL: url)
                .onAppear(perform: setupAudioSession)
        } else {
            VideoPlayerView(player: AVPlayer(url: url))
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.allowsPictureInPicturePlayback = true
        controller.player?.play()
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

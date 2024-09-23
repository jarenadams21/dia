import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Auto-play the video when the view appears
        if uiViewController.player?.currentItem == nil {
            uiViewController.player = AVPlayer(url: url)
            uiViewController.player?.play()
        }
    }
}

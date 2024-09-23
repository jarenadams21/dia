import SwiftUI
import AVKit
import AVFoundation

struct MediaPlayerView: View {
    let url: URL

    var body: some View {
        if url.pathExtension.lowercased() == "mp3" {
            AudioPlayerView(url: url)
        } else {
            VideoPlayer(player: AVPlayer(url: url))
                .edgesIgnoringSafeArea(.all)
        }
    }
}

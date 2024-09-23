import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    let url: URL
    @State private var player: AVAudioPlayer?

    var body: some View {
        VStack {
            Text(url.lastPathComponent)
                .font(.headline)
                .padding()

            Button(action: {
                if player?.isPlaying == true {
                    player?.pause()
                } else {
                    player?.play()
                }
            }) {
                Image(systemName: player?.isPlaying == true ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            .padding()

            Spacer()
        }
        .onAppear(perform: setupPlayer)
        .onDisappear {
            player?.stop()
        }
    }

    func setupPlayer() {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            print("Audio player setup failed: \(error.localizedDescription)")
        }
    }
}

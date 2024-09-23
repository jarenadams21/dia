import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    let url: URL
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var playbackProgress: Double = 0.0
    @State private var playbackTimer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            Text(url.lastPathComponent)
                .font(.custom("Courier", size: 18)) // 90s style monospace font
                .foregroundColor(.neonGreen)
                .padding()

            // Playback slider
            Slider(value: $playbackProgress, in: 0...1, onEditingChanged: sliderChanged)
                .accentColor(.brightPink) // Neon slider color
                .padding()

            HStack(spacing: 40) {
                // Play/Pause button
                Button(action: {
                    if isPlaying {
                        pauseAudio()
                    } else {
                        playAudio()
                    }
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.brightPink)
                }

                // Stop button
                Button(action: stopAudio) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.brightPink)
                }
            }
            
            Spacer()
        }
        .onAppear(perform: setupPlayer)
        .onDisappear {
            player?.stop()
            savePlaybackProgress()
        }
        .background(Color.black.opacity(0.85)) // 90s web background
        .cornerRadius(20) // Boxy retro feel
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.neonGreen, lineWidth: 4) // Neon green border
        )
    }

    func setupPlayer() {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            restorePlaybackProgress()
            startTimer()
        } catch {
            print("Audio player setup failed: \(error.localizedDescription)")
        }
    }

    func playAudio() {
        player?.play()
        isPlaying = true
        startTimer()
    }

    func pauseAudio() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }

    func stopAudio() {
        player?.stop()
        player?.currentTime = 0
        playbackProgress = 0
        isPlaying = false
        stopTimer()
    }

    func sliderChanged(editing: Bool) {
        if !editing {
            player?.currentTime = (player?.duration ?? 0) * playbackProgress
        }
    }

    func startTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = player else { return }
            playbackProgress = player.currentTime / (player.duration)
        }
    }

    func stopTimer() {
        playbackTimer?.invalidate()
    }

    func savePlaybackProgress() {
        let currentTime = player?.currentTime ?? 0
        UserDefaults.standard.set(currentTime, forKey: url.lastPathComponent)
    }

    func restorePlaybackProgress() {
        let savedTime = UserDefaults.standard.double(forKey: url.lastPathComponent)
        player?.currentTime = savedTime
        playbackProgress = savedTime / (player?.duration ?? 1)
    }
}

extension Color {
    static let neonGreen = Color(red: 57 / 255, green: 255 / 255, blue: 20 / 255)
    static let brightPink = Color(red: 255 / 255, green: 105 / 255, blue: 180 / 255)
}

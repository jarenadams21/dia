import SwiftUI
import AVFoundation
import MediaPlayer

struct AudioPlayerView: View {
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var playbackProgress: Double = 0.0
    @State private var playbackTimer: Timer?

    let audioURL: URL

    var body: some View {
        VStack(spacing: 20) {
            Text(audioURL.lastPathComponent)
                .font(.custom("Courier", size: 18))
                .foregroundColor(.neonGreen)
                .padding()

            // Playback slider
            Slider(value: $playbackProgress, in: 0...1, onEditingChanged: sliderChanged)
                .accentColor(.brightPink)
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
            stopAudio()
            savePlaybackProgress()
        }
        .background(Color.black.opacity(0.85))
        .cornerRadius(20)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.neonGreen, lineWidth: 4)
        )
    }

    func setupPlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.prepareToPlay()
            restorePlaybackProgress()
            setupNowPlaying()
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
            playbackProgress = player.currentTime / player.duration
            updateNowPlaying()
        }
    }

    func stopTimer() {
        playbackTimer?.invalidate()
    }

    func savePlaybackProgress() {
        let currentTime = player?.currentTime ?? 0
        UserDefaults.standard.set(currentTime, forKey: audioURL.lastPathComponent)
    }

    func restorePlaybackProgress() {
        let savedTime = UserDefaults.standard.double(forKey: audioURL.lastPathComponent)
        player?.currentTime = savedTime
        playbackProgress = savedTime / (player?.duration ?? 1)
    }

    func setupNowPlaying() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = audioURL.lastPathComponent
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.isPlaying ?? false ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

        UIApplication.shared.beginReceivingRemoteControlEvents()

        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { _ in
            if let player = player, !player.isPlaying {
                player.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { _ in
            if let player = player, player.isPlaying {
                player.pause()
                return .success
            }
            return .commandFailed
        }
    }

    func updateNowPlaying() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.isPlaying ?? false ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

extension Color {
    static let neonGreen = Color(red: 57 / 255, green: 255 / 255, blue: 20 / 255)
    static let brightPink = Color(red: 255 / 255, green: 105 / 255, blue: 180 / 255)
}

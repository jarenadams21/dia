import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let url: URL
    @ObservedObject private var audioManager = AudioManager.shared
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isPlaying = false
    @State private var timeObserverToken: Any?
    
    var body: some View {
        VStack {
            Text(url.lastPathComponent)
                .font(.headline)
                .padding()

            Slider(value: $currentTime, in: 0...duration, onEditingChanged: sliderEditingChanged)
                .padding()

            HStack {
                Text(timeString(from: currentTime))
                Spacer()
                Text(timeString(from: duration))
            }
            .padding(.horizontal)

            HStack {
                Button(action: rewind) {
                    Image(systemName: "gobackward.15")
                        .font(.largeTitle)
                }
                .padding()

                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                }
                .padding()

                Button(action: fastForward) {
                    Image(systemName: "goforward.15")
                        .font(.largeTitle)
                }
                .padding()
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear(perform: cleanupPlayer)
    }

    func setupPlayer() {
        audioManager.playAudio(url: url)
        isPlaying = true
        
        if let duration = audioManager.getDuration() {
            self.duration = CMTimeGetSeconds(duration)
        }

        // Add observer to update current time
        let interval = CMTime(value: 1, timescale: 2)
        timeObserverToken = audioManager.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            self.currentTime = CMTimeGetSeconds(time)
        }
    }

    func cleanupPlayer() {
        if let token = timeObserverToken {
            audioManager.player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    func togglePlayPause() {
        if isPlaying {
            audioManager.pauseAudio()
        } else {
            audioManager.playAudio(url: url)
        }
        isPlaying.toggle()
    }

    func rewind() {
        let newTime = max(currentTime - 15, 0)
        audioManager.seekTo(time: CMTime(seconds: newTime, preferredTimescale: 1))
        currentTime = newTime
    }

    func fastForward() {
        let newTime = min(currentTime + 15, duration)
        audioManager.seekTo(time: CMTime(seconds: newTime, preferredTimescale: 1))
        currentTime = newTime
    }

    func sliderEditingChanged(editingStarted: Bool) {
        if !editingStarted {
            audioManager.seekTo(time: CMTime(seconds: currentTime, preferredTimescale: 1))
        }
    }

    func timeString(from seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds / 60) % 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

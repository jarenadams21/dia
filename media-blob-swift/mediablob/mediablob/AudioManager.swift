import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    var player: AVPlayer?
    
    func playAudio(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        
        // Set audio session for background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func pauseAudio() {
        player?.pause()
    }
    
    func isPlaying() -> Bool {
        return player?.rate != 0 && player?.error == nil
    }
    
    func seekTo(time: CMTime) {
        player?.seek(to: time)
    }
    
    func getCurrentTime() -> CMTime? {
        return player?.currentTime()
    }
    
    func getDuration() -> CMTime? {
        return player?.currentItem?.duration
    }
}

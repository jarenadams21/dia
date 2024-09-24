//
//  mediablobApp.swift
//  mediablob
//
//  Created by jaren adams on 9/22/24.
//

import SwiftUI
import AVFoundation
import MediaPlayer

@main
struct mediablobApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

func setupAudioSession() {
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try AVAudioSession.sharedInstance().setActive(true)
    } catch {
        print("Failed to set up audio session: \(error.localizedDescription)")
    }
}



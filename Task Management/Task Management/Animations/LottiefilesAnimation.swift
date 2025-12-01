//
//  LottiefilesAnimation.swift
//  Task Management
//
//  Created by TrungAnhx on 1/12/25.
//

import SwiftUI
import Lottie
import AVFoundation

struct LottiefilesAnimation: View {
    @Binding var isActive: Bool
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        LottieView(animation: .named("Rocket loader"))
            .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
            .animationDidFinish { completed in
                isActive = false
            }
            .onAppear() {
                playSound("intro", "mp3")
            }
            
    }
    
    func playSound(_ soundName: String, _ type: String) {
        if let path = Bundle.main.path(forResource: soundName, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                
                audioPlayer?.play()
            } catch {
                print("Khong the phat nhac!")
            }
        }
    }
}




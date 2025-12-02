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
                withAnimation(.easeInOut(duration: 1.2)) {
                    isActive = false
                }
            }
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .ignoresSafeArea()
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




//
//  LottiefilesAnimation.swift
//  Task Management
//
//  Created by TrungAnhx on 1/12/25.
//

import SwiftUI
import Lottie

struct LottiefilesAnimation: View {
    var body: some View {
        LottieView(animation: .named("Rocket loader"))
            .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
            
    }
}

#Preview {
    LottiefilesAnimation()
}

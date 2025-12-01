//
//  ContentView.swift
//  Task Management
//
//  Created by TrungAnhx on 8/11/25.
//

import SwiftUI

struct ContentView: View {
    @State var isSplashActive : Bool = true
    var body: some View {
        ZStack {
            Home()
                .opacity(isSplashActive ? 0 : 1)
                .animation(.easeIn(duration: 0.4), value: isSplashActive)
            
            if isSplashActive {
                LottiefilesAnimation(isActive: $isSplashActive)
                    .transition(.opacity.animation(.easeInOut(duration: 0.4)))
            }
            
        }
    }
}

#Preview {
    ContentView()
}

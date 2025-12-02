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
                .scaleEffect(isSplashActive ? 0.9 : 1)
                .opacity(isSplashActive ? 0 : 1)
                .animation(.easeOut(duration: 1.0), value: isSplashActive)
            
            if isSplashActive {
                LottiefilesAnimation(isActive: $isSplashActive)
                    .transition(.opacity)
            }
            
        }
    }
}

#Preview {
    ContentView()
}

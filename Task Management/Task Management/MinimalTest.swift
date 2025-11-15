//
//  MinimalTest.swift
//  Task Management
//
//  Created by TrungAnhx on 8/11/25.
//

import SwiftUI

// Simple test view to verify the app launches without Core Data
struct MinimalTest: View {
    var body: some View {
        VStack {
            Text("Minimal Test View")
                .font(.largeTitle)
                .padding()
            
            Text("If you can see this, the app launches without crashing")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Test Button") {
                print("Button pressed successfully")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

#Preview {
    MinimalTest()
}

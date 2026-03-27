//
//  RootView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/25/26.
//

import SwiftUI

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            LoginView()
                .opacity(showSplash ? 0 : 4)

            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    RootView()
}

#Preview {
    RootView()
}

//ChatGPT 5.3 used to help with generating and organizing some basic UI elements

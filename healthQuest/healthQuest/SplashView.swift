//
//  SplashView.swift
//  healthQuest
//
//  ID 23 – Splash screen UI (color, logo, animations)
//  Cameron
//

import SwiftUI

struct SplashView: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.6
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0
    @State private var dotScale: [CGFloat] = [0.4, 0.4, 0.4]
    @State private var dotOpacity: [Double] = [0, 0, 0]
    
    /// Callback fired when the splash is done so RootView can transition
    var onFinished: (() -> Void)?

    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)
                    .shadow(
                        color: Color("AccentColor").opacity(0.35),
                        radius: 20, x: 0, y: 8
                    )
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color("AccentColor"), lineWidth: 2.5)
                            .opacity(logoOpacity)
                    )
                
                Spacer().frame(height: 28)
                
               
                Text("HealthQuest")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AccentColor"))
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
                
                Spacer().frame(height: 8)
                
                
                Text("Your journey to wellness starts here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .opacity(subtitleOpacity)
                
                Spacer().frame(height: 56)
                
               
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color("AccentColor"))
                            .frame(width: 10, height: 10)
                            .scaleEffect(dotScale[index])
                            .opacity(dotOpacity[index])
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            runAnimations()
        }
    }

    
    private func runAnimations() {
        // 1. Logo fades + scales in
        withAnimation(.spring(response: 1.4, dampingFraction: 0.6).delay(0.2)) {
            logoOpacity = 1
            logoScale = 1
        }
        
        // 2. Title slides up
        withAnimation(.easeOut(duration: 1.0).delay(1.1)) {
            titleOpacity = 1
            titleOffset = 0
        }
        
        // 3. Subtitle fades in
        withAnimation(.easeIn(duration: 0.8).delay(1.7)) {
            subtitleOpacity = 1
        }
        
        // 4. Loading dots cascade in (slower)
        for i in 0..<3 {
            let delay = 2.2 + Double(i) * 0.36   // doubled delay
            withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                dotOpacity[i] = 1
                dotScale[i] = 1
            }
        }
        
        // 5. Pulse dots (starts later)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
            pulseDots()
        }
        
        // 6. Finish splash (now takes ~5.6 seconds total)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.6) {
            onFinished?()
        }
    }

    private func pulseDots() {
        for i in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.9)                    // slower pulse
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.3)
            ) {
                dotScale[i] = dotScale[i] == 1 ? 1.5 : 1
            }
        }
    }
}

#Preview {
    SplashView()
}

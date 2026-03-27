//
//  SplashView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/25/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)

                Text("HealthQuest")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color("AccentColor"))
            }
        }
    }
}

#Preview {
    SplashView()
}

//ChatGPT 5.3 used to help with generating and organizing some basic UI elements

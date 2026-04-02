//
//  healthQuestApp.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/25/26.
//

import SwiftUI
import FirebaseCore

@main
struct healthQuestApp: App {
    @State private var showSplash = true
    @StateObject private var session = SessionViewModel()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
            WindowGroup {
                Group {
                    if showSplash {
                        SplashView()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showSplash = false}
                                }
                            }
                    } else {
                        RootView()
                    }
                }.environmentObject(session)
            }
        }
}


//
//  NavigationView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/31/26.
//

import SwiftUI

struct NavigationBarView: View {
    let firstName: String

    var body: some View {
        TabView {
            HomePageView(firstName: firstName)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            JournalView()
                .tabItem {
                    Label("Journals", systemImage: "book")
                }
            ChatsView()
                .tabItem {
                    Label("Chats", systemImage: "message")
                }
            ProfilePageView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }.tint(Color("AccentColor"))
    }
}

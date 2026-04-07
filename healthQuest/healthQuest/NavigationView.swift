//
//  NavigationView.swift
//  healthQuest
//
//  Role-aware tab navigation — patients and therapists see different tabs
//  Each tab gets its own NavigationStack inside its root view (not here)
//  Cameron
//

import SwiftUI

struct NavigationBarView: View {
    let firstName: String
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        if session.user?.role == "therapist" {
            therapistTabs
        } else {
            patientTabs
        }
    }

    
    // NavigationStack is owned by each tab's root view
    private var patientTabs: some View {
        TabView {
            HomePageView(firstName: firstName)
                .tabItem { Label("Home", systemImage: "house") }

            JournalView(patientId: session.user?.uid)
                .tabItem { Label("Journals", systemImage: "book") }

            ChatsView()
                .tabItem { Label("Chats", systemImage: "message") }

           // TherapistDirectoryView()
             //   .tabItem { Label("Therapists", systemImage: "person.2") }

            ProfilePageView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
        .tint(Color("AccentColor"))
    }

    
    private var therapistTabs: some View {
        TabView {
            HomePageView(firstName: firstName)
                .tabItem { Label("Home", systemImage: "house") }
            
            JournalReviewView()
                .tabItem { Label("Patient Journals", systemImage: "book") }

            ChatsView()
                .tabItem { Label("Clients", systemImage: "bubble.left.and.bubble.right") }

            ProfilePageView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
        .tint(Color("AccentColor"))
    }
}

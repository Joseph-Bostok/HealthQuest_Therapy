//
//  ProfilePageView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/31/26.
//

import SwiftUI
import FirebaseAuth


struct ProfilePageView: View {
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("Display static profile info here")
                Text("Add an 'edit profile' button")
                Text("keep the 'log out' button")
                Button {
                    logOut()
                } label: {
                    Text("Log Out")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentColor"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }.navigationTitle("Profile")
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .padding()
            
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            return
        }
    }
}

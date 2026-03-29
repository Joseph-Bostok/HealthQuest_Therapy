//
//  HomePageView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/28/26.
//

import SwiftUI
import FirebaseAuth


struct HomePageView: View {
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    
    let firstName: String
    var body: some View {
        VStack {
            Text("Welcome, \(firstName)!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color("AccentColor"))
            Spacer()
        }
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
        }.alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .padding()
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

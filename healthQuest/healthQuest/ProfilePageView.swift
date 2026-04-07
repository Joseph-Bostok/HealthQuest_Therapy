//
//  ProfilePageView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/31/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfilePageView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var bio = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // Profile Image
                        VStack(spacing: 12) {
                            Image("AppLogo") // replace with real image later
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color("AccentColor"), lineWidth: 2)
                                )

                            Text("\(firstName) \(lastName)")
                                .font(.title2.bold())
                                .foregroundStyle(Color("AccentColor"))
                        }

                        // Info Card
                        VStack(spacing: 16) {

                            profileRow(title: "Email", value: email)
                            profileRow(title: "Phone", value: phone.isEmpty ? "Not provided" : phone)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("About Me")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(bio.isEmpty ? "No bio yet." : bio)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        NavigationLink {
                            ProfileEditView()
                        } label: {
                            Text("Edit Profile")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundStyle(Color("AccentColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color("AccentColor"), lineWidth: 1.5)
                                )
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
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadProfile()
            }
        }.alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    
    private func profileRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

 
    
    private func loadProfile() {
        guard let uid = session.user?.uid else {
            errorMessage = "Unable to access user account."
            showErrorAlert = true
            return
        }

        guard let role = session.user?.role else {
            errorMessage = "Unable to determine user role."
            showErrorAlert = true
            return
        }
        
        let collectionName: String
        if role == "patient" {
            collectionName = "patients"
        } else {
            collectionName = "therapists"
        }

        let db = Firestore.firestore()
        db.collection(collectionName)
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                }

                guard let data = snapshot?.data() else {
                    errorMessage = "Profile data not found."
                    showErrorAlert = true
                    return
                }

                firstName = data["firstName"] as? String ?? ""
                lastName = data["lastName"] as? String ?? ""
                email = data["email"] as? String ?? ""
                phone = data["phone"] as? String ?? ""
                bio = data["bio"] as? String ?? ""
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



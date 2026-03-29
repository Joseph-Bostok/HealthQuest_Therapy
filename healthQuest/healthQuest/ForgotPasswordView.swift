//
//  ForgotPasswordView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/28/26.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    @State private var successMessage = ""

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                        
                        Text("HealthQuest")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color("AccentColor"))
                        
                        
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Enter your email to continue")
                            .foregroundStyle(.secondary)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        Button {
                            resetPassword()
                        } label: {
                            Text("Reset Password")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }.padding(.horizontal)
                        .alert("Error", isPresented: $showErrorAlert) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text(errorMessage)
                        }
                        .alert("Success", isPresented: $showSuccessAlert) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text(successMessage)
                        }
                    Spacer()
                    
                }
            }
        }
    } // view end
    
    func resetPassword() {
        guard !email.isEmpty else {
                    errorMessage = "Please enter your email address."
                    showErrorAlert = true
                    return
                }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let _ = error {
                        errorMessage = "Error sending reset email"
                        showErrorAlert = true
                    } else {
                        successMessage = "A password reset email has been sent to \(email)."
                        showSuccessAlert = true
                    }
        }
    }
}
    


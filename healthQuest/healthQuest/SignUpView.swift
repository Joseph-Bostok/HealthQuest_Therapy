//
//  SignUpView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/27/26.
//
import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var birthdate = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var therapistID = ""


    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    VStack(spacing: 16) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)

                        Text("Welcome To")
                            .font(.title.bold())
                            .foregroundStyle(Color("AccentColor"))
                        Text("HealthQuest")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color("AccentColor"))

                        Text("Sign up to continue")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                    ScrollView {
                        VStack(spacing: 24) {
                            TextField("First Name", text: $firstName)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                            TextField("Last Name", text: $lastName)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                            TextField("Password", text: $password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                            TextField("Birthdate", text: $birthdate)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                            TextField("Therapist ID", text: $therapistID)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }.padding(.horizontal, 20)
                    }.overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.gray]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 40),
                        alignment: .bottom
                    ).scrollDismissesKeyboard(.interactively)
                    
                    //chatgpt 5.3 used to help with creating the gradient at bottom of scrollable area to look visually cohesive
                    
                    VStack(spacing: 16) {
                        Button {
                            print("Sign Up Tapped")
                        } label: {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
                .padding(.vertical)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    SignUpView()
}

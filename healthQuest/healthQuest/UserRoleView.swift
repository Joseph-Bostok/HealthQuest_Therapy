//
//  UserRoleView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/28/26.
//

import SwiftUI

enum UserRole {
    case therapist
    case patient
}

struct UserRoleView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                Text("Are you a therapist or a patient?")
                    .multilineTextAlignment(.center)
                    .font(.title.bold())
                    .foregroundStyle(Color("AccentColor"))
                    .padding(.horizontal)
                
                NavigationLink(destination: SignUpView(selectedRole: .therapist)) {
                    Text("I am a Therapist")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                NavigationLink(destination: SignUpView(selectedRole: .patient)) {
                    Text("I am a Patient")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding()
        }
    }
    
}

//chatgpt 5.3 used to help organize UI with proper swiftUI techniques

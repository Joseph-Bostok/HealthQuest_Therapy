import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

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

                        Text("Welcome Back")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color("AccentColor"))

                        Text("Log in to continue")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(spacing: 16) {
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

                        HStack {
                            Spacer()

                            Button("Forgot Password?") {
                                print("Forgot password tapped")
                            }
                            .font(.footnote)
                            .foregroundStyle(Color("AccentColor"))
                        }

                        Button {
                            print("Login tapped with email: \(email)")
                        } label: {
                            Text("Log In")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        NavigationLink {
                            SignUpView()
                        } label: {
                            Text("Create Account")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundStyle(Color("AccentColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color("AccentColor"), lineWidth: 1.5)
                                )
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
    LoginView()
}

//ChatGPT 5.3 used to help with generating and organizing some basic UI elements

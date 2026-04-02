import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToHome = false
    @State private var firstName = ""
    @State private var isLoading = false
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

                    VStack(spacing: 16) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)

                        Text("Welcome Back")
                            .font(.title.bold())
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
                            NavigationLink {
                                ForgotPasswordView()
                            } label: {
                                Text("Forgot Password?")
                                    .font(.footnote)
                                    .foregroundStyle(Color("AccentColor"))
                            }
                        }

                        Button {
                            logIn()
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
                            UserRoleView()
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
                    }.alert("Error", isPresented: $showErrorAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(errorMessage)
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
                .padding(.vertical)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    } //view end
    
    
    func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                        return
                    }
                }
    }
    
} // struct end

#Preview {
    LoginView()
}

// ChatGPT 5.3 used to help with generating and organizing some basic UI elements,
// and with understanding how to authenticate users via firebase

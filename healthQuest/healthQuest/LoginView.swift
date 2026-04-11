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

    @State private var emailError: String = ""
    @State private var passwordError: String = ""

    private let fieldBg = Color(red: 0.914, green: 0.941, blue: 0.918)

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
                        validatedField(
                            label: "Email",
                            text: $email,
                            error: emailError,
                            keyboard: .emailAddress,
                            isSecure: false
                        )

                        validatedField(
                            label: "Password",
                            text: $password,
                            error: passwordError,
                            keyboard: .default,
                            isSecure: true
                        )

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
                            if validate() { logIn() }
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
                    }
                    .alert("Error", isPresented: $showErrorAlert) {
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

    @ViewBuilder
    private func validatedField(
        label: String,
        text: Binding<String>,
        error: String,
        keyboard: UIKeyboardType,
        isSecure: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            if isSecure {
                SecureField(label, text: text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(fieldBg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(error.isEmpty ? Color.clear : Color.red, lineWidth: 1.5)
                    )
            } else {
                TextField(label, text: text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(fieldBg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(error.isEmpty ? Color.clear : Color.red, lineWidth: 1.5)
                    )
            }

            if !error.isEmpty {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
            }
        }
    }

    @discardableResult
    private func validate() -> Bool {
        var valid = true

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let emailRegex = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/
        if trimmedEmail.isEmpty {
            emailError = "Email is required."
            valid = false
        } else if (try? emailRegex.wholeMatch(in: trimmedEmail)) == nil {
            emailError = "Enter a valid email address."
            valid = false
        } else {
            emailError = ""
        }

        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            passwordError = "Password is required."
            valid = false
        } else {
            passwordError = ""
        }

        return valid
    }

    func logIn() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)

        Auth.auth().signIn(withEmail: trimmedEmail, password: trimmedPassword) { result, error in
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

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    let selectedRole: UserRole

    @State private var email = ""
    @State private var password = ""
    @State private var referralCode = ""
    @State private var birthdate = Date()
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var medicalLicenseNum = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showErrorAlert = false

    // FIX: Removed showSuccessAlert/successMessage — navigation now happens
    // automatically via SessionViewModel's auth listener, same as login.
    // Showing a success alert and then doing nothing was a UX dead-end.

    @State private var firstNameError: String = ""
    @State private var lastNameError: String = ""
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var referralCodeError: String = ""
    @State private var licenseError: String = ""

    private let fieldBg = Color(red: 0.914, green: 0.941, blue: 0.918)

    var body: some View {
        // FIX: Removed NavigationStack from here. SignUpView is always pushed
        // inside UserRoleView's NavigationStack. Nesting NavigationStacks
        // causes undefined behavior and crashes on iOS 16+.
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

                // Scrollable Form + Gradient
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack(spacing: 20) {

                            validatedField(
                                label: "First Name",
                                text: $firstName,
                                error: firstNameError,
                                keyboard: .default,
                                isSecure: false,
                                capitalization: .words
                            )

                            validatedField(
                                label: "Last Name",
                                text: $lastName,
                                error: lastNameError,
                                keyboard: .default,
                                isSecure: false,
                                capitalization: .words
                            )

                            validatedField(
                                label: "Email",
                                text: $email,
                                error: emailError,
                                keyboard: .emailAddress,
                                isSecure: false,
                                capitalization: .never
                            )

                            validatedField(
                                label: "Password",
                                text: $password,
                                error: passwordError,
                                keyboard: .default,
                                isSecure: true,
                                capitalization: .never
                            )

                            if selectedRole == .patient {
                                DatePicker("Birthdate", selection: $birthdate, displayedComponents: .date)
                            }

                            if selectedRole == .patient {
                                validatedField(
                                    label: "Referral Code",
                                    text: $referralCode,
                                    error: referralCodeError,
                                    keyboard: .default,
                                    isSecure: false,
                                    capitalization: .never
                                )
                            }

                            if selectedRole == .therapist {
                                validatedField(
                                    label: "Medical License #",
                                    text: $medicalLicenseNum,
                                    error: licenseError,
                                    keyboard: .default,
                                    isSecure: false,
                                    capitalization: .never
                                )
                            }

                            // FIX: Button now shows spinner for both roles, and is
                            // disabled during the async operation.
                            Button {
                                if validate() { signUp() }
                            } label: {
                                Group {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Sign Up")
                                    }
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .disabled(isLoading)
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    .scrollDismissesKeyboard(.interactively)

                    LinearGradient(
                        colors: [Color.clear, Color("AppBackground")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 40)
                    .allowsHitTesting(false)
                }

                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.vertical)
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    } // view ends here

    @ViewBuilder
    private func validatedField(
        label: String,
        text: Binding<String>,
        error: String,
        keyboard: UIKeyboardType,
        isSecure: Bool,
        capitalization: TextInputAutocapitalization = .never
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
                    .textInputAutocapitalization(capitalization)
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

        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            firstNameError = "First name is required."
            valid = false
        } else { firstNameError = "" }

        if lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            lastNameError = "Last name is required."
            valid = false
        } else { lastNameError = "" }

        let emailRegex = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if trimmedEmail.isEmpty {
            emailError = "Email is required."
            valid = false
        } else if (try? emailRegex.wholeMatch(in: trimmedEmail)) == nil {
            emailError = "Enter a valid email address."
            valid = false
        } else { emailError = "" }

        // FIX: Added 6-character minimum to match Firebase's requirement,
        // giving the user a clear inline message instead of a Firebase error.
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
        if trimmedPassword.isEmpty {
            passwordError = "Password is required."
            valid = false
        } else if trimmedPassword.count < 6 {
            passwordError = "Password must be at least 6 characters."
            valid = false
        } else { passwordError = "" }

        if selectedRole == .patient {
            if !isAtLeast18(birthdateEntered: birthdate) {
                errorMessage = "Must be at least 18 to sign up."
                showErrorAlert = true
                valid = false
            }

            if referralCode.trimmingCharacters(in: .whitespaces).isEmpty {
                referralCodeError = "Referral code is required."
                valid = false
            } else { referralCodeError = "" }
        }

        if selectedRole == .therapist {
            let trimmedLicense = medicalLicenseNum.trimmingCharacters(in: .whitespaces)
            if trimmedLicense.isEmpty {
                licenseError = "License number is required."
                valid = false
            } else if !isValidLicenseNum(licenseNumEntered: trimmedLicense) {
                licenseError = "License number provided is invalid."
                valid = false
            } else { licenseError = "" }
        }

        return valid
    }

    func isAtLeast18(birthdateEntered: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthdateEntered, to: now)
        return (ageComponents.year ?? 0) >= 18
    }

    func isValidLicenseNum(licenseNumEntered: String) -> Bool {
        let licensePrefixes = [
            "PSY-", "LP-", "PY-",                      // Psychologist
            "LPC-", "LCPC-", "LMHC-", "LCMHC-",       // Counselors
            "LCSW-", "LMSW-", "CSW-",                  // Social Workers
            "LMFT-", "MFT-",                            // Marriage & Family Therapists
            "CADC-", "LCAS-", "LADC-"                   // Addiction Counselors
        ]
        return licensePrefixes.contains { licenseNumEntered.uppercased().hasPrefix($0) }
    }

    func signUp() {
        firstName = firstName.trimmingCharacters(in: .whitespaces)
        lastName = lastName.trimmingCharacters(in: .whitespaces)
        email = email.trimmingCharacters(in: .whitespaces)
        referralCode = referralCode.trimmingCharacters(in: .whitespaces)
        medicalLicenseNum = medicalLicenseNum.trimmingCharacters(in: .whitespaces)

        // FIX: isLoading is now set for both roles before any async work begins.
        isLoading = true

        if selectedRole == .patient {
            signUpPatient()
        } else {
            signUpTherapist()
        }
    } // sign up function ends here

    func signUpPatient() {
        let db = Firestore.firestore()
        let ref = db.collection("referralCodes").document(referralCode)

        ref.getDocument { document, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                isLoading = false
                return
            }

            guard let document = document, document.exists else {
                errorMessage = "Invalid referral code."
                showErrorAlert = true
                isLoading = false
                return
            }

            let used = document.get("used") as? Bool ?? false
            let therapistId = document.get("therapistId") as? String ?? ""

            if used {
                errorMessage = "This referral code has already been used."
                showErrorAlert = true
                isLoading = false
                return
            }

            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    isLoading = false
                    return
                }

                guard let user = result?.user else {
                    errorMessage = "Could not create account."
                    showErrorAlert = true
                    isLoading = false
                    return
                }

                let uid = user.uid

                // FIX: Use a WriteBatch so all Firestore writes succeed or fail together.
                // This prevents the broken half-created state where a Firebase Auth
                // account exists but Firestore data is missing.
                let batch = db.batch()

                let patientData: [String: Any] = [
                    "firstName": firstName,
                    "lastName": lastName,
                    "email": email,
                    "birthdate": Timestamp(date: birthdate),
                    "createdAt": Timestamp(),
                    "active": true,
                    "therapistID": therapistId,
                    "bio": ""
                ]
                batch.setData(patientData, forDocument: db.collection("patients").document(uid))

                batch.updateData(
                    ["patients": FieldValue.arrayUnion([uid])],
                    forDocument: db.collection("therapists").document(therapistId)
                )

                let aiWelcomeMessage = "Welcome to HealthQuest! I am your chat assistant! Feel free to send me a message whenever you are ready! I am here to help!"
                let aiMessageRef = db.collection("ai_chats").document(uid).collection("messages").document()
                batch.setData([
                    "content": aiWelcomeMessage,
                    "flagged": false,
                    "riskscore": 0,
                    "sender": "AI",
                    "timestamp": Timestamp(),
                    "read": false
                ], forDocument: aiMessageRef)

                batch.setData([
                    "clientName": firstName + " " + lastName,
                    "lastMessage": aiWelcomeMessage,
                    "sender": "AI",
                    "lastMessageAt": Timestamp(),
                    "read": false
                ], forDocument: db.collection("ai_chats").document(uid))

                let therapistWelcomeMessage = "Thank you for creating your account \(firstName)! I am looking forward to getting to know you as my newest patient! Send me a message about anything I may need to know in order to better assist you as you start your HealthQuest Therapy Journey :)"
                let therapistMessageRef = db.collection("therapist_chats").document(uid).collection("messages").document()
                batch.setData([
                    "content": therapistWelcomeMessage,
                    "sender": therapistId,
                    "timestamp": Timestamp(),
                    "read": false
                ], forDocument: therapistMessageRef)

                batch.setData([
                    "lastMessage": therapistWelcomeMessage,
                    "sender": therapistId,
                    "clientName": firstName + " " + lastName,
                    "therapistID": therapistId,
                    "lastMessageAt": Timestamp(),
                    "read": false
                ], forDocument: db.collection("therapist_chats").document(uid))

                batch.updateData(["used": true], forDocument: ref)

                batch.commit { error in
                    isLoading = false

                    if let error = error {
                        // FIX: If the batch fails, delete the Firebase Auth user
                        // so the account doesn't exist in a broken state.
                        user.delete { _ in }
                        errorMessage = "Account setup failed. Please try again.\n\n(\(error.localizedDescription))"
                        showErrorAlert = true
                    }
                    // On success, SessionViewModel's auth listener fires automatically
                    // and RootView navigates to the home screen — no manual navigation needed.
                }
            }
        }
    }

    func signUpTherapist() {
        let db = Firestore.firestore()

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                isLoading = false
                return
            }

            guard let user = result?.user else {
                errorMessage = "Could not create account."
                showErrorAlert = true
                isLoading = false
                return
            }

            let uid = user.uid
            let data: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "licenseNumber": medicalLicenseNum,
                "createdAt": Timestamp(),
                "patients": [],
                "bio": ""
            ]

            db.collection("therapists").document(uid).setData(data) { error in
                isLoading = false

                if let error = error {
                    // FIX: Delete the Auth user if the Firestore write fails,
                    // so the account isn't left in a broken state.
                    user.delete { _ in }
                    errorMessage = "Account setup failed. Please try again.\n\n(\(error.localizedDescription))"
                    showErrorAlert = true
                }
                // On success, SessionViewModel's auth listener fires automatically
                // and RootView navigates to the home screen — no manual navigation needed.
            }
        }
    }

} // struct end

// used chatgpt 5.3 to help with research on implementing firebase into a SwiftUI application

#Preview("Patient") {
    SignUpView(selectedRole: .patient)
}

#Preview("Therapist") {
    SignUpView(selectedRole: .therapist)
}

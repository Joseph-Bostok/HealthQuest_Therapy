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
    @State private var showSuccessAlert = false
    @State private var successMessage = ""

    @State private var firstNameError: String = ""
    @State private var lastNameError: String = ""
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var referralCodeError: String = ""
    @State private var licenseError: String = ""

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

                                Button(isLoading ? "Creating Account..." : "Sign Up") {
                                    if validate() { signUp() }
                                }
                                .disabled(isLoading)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
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
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(successMessage)
            }
        }
    } //view ends here

    //chatgpt 5.3 used to help with restructuring UI here and fixing issues with device compatibility

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

        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            passwordError = "Password is required."
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
                return
            }

            guard let document = document, document.exists else {
                errorMessage = "Invalid referral code."
                showErrorAlert = true
                return
            }

            let used = document.get("used") as? Bool ?? false
            let therapistId = document.get("therapistId") as? String ?? ""

            if used {
                errorMessage = "This referral code has already been used."
                showErrorAlert = true
                return
            }

            isLoading = true

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
                    "birthdate": Timestamp(date: birthdate),
                    "createdAt": Timestamp(),
                    "active": true,
                    "therapistID": therapistId,
                    "bio": ""
                ]

                db.collection("patients").document(uid).setData(data) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                        isLoading = false
                        return
                    }
                }

                db.collection("therapists").document(therapistId).updateData([
                    "patients": FieldValue.arrayUnion([uid])
                ]) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                        isLoading = false
                        return
                    }
                }

                db.collection("ai_chats").document(uid).collection("messages")
                    .document().setData([
                        "content": "Welcome to HealthQuest! I am your chat assistant! Feel free to send me a message whenever you are ready! I am here to help!",
                        "flagged": false,
                        "riskscore": 0,
                        "sender": "AI",
                        "timestamp": Timestamp(),
                        "read": false
                    ]) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                            isLoading = false
                            return
                        }
                    }

                db.collection("ai_chats").document(uid)
                    .setData([
                        "clientName": firstName + " " + lastName,
                        "lastMessage": "Welcome to HealthQuest! I am your chat assistant! Feel free to send me a message whenever you are ready! I am here to help!",
                        "sender": "AI",
                        "lastMessageAt": Timestamp(),
                        "read": false
                    ]) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                            isLoading = false
                            return
                        }
                    }

                db.collection("therapist_chats").document(uid).collection("messages")
                    .document().setData([
                        "content": "Thank you for creating your account " + firstName + "! I am looking forward to getting to know you as my newest patient! Send me a message about anything I may need to know in order to better assist you as you start your HealthQuest Therapy Journey :)",
                        //\"sender\": \"therapist\",
                        "sender": therapistId,
                        //\"clientName\": firstName + \" \" + lastName,
                        "timestamp": Timestamp(),
                        "read": false
                    ]) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                            isLoading = false
                            return
                        }
                    }

                db.collection("therapist_chats").document(uid)
                    .setData([
                        "lastMessage": "Thank you for creating your account " + firstName + "! I am looking forward to getting to know you as my newest patient! Send me a message about anything I may need to know in order to better assist you as you start your HealthQuest Therapy Journey :)",
                        "sender": therapistId,
                        "clientName": firstName + " " + lastName,
                        "therapistID": therapistId,
                        "lastMessageAt": Timestamp(),
                        "read": false
                    ]) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                            isLoading = false
                            return
                        }
                    }

                ref.updateData(["used": true]) { error in
                    isLoading = false
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    } else {
                        successMessage = "Patient Account Created and linked to Therapist!"
                        showSuccessAlert = true
                    }
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
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                } else {
                    successMessage = "Therapist Account Created!"
                    showSuccessAlert = true
                }
            }
        }
    }

} //struct end here
// used chatgpt 5.3 to help with research on implementing firebase into a SwiftUI application

#Preview("Patient") {
    SignUpView(selectedRole: .patient)
}

#Preview("Therapist") {
    SignUpView(selectedRole: .therapist)
}

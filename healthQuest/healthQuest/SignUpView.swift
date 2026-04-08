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
                            VStack(spacing: 24) {
                                
                                TextField("First Name", text: $firstName)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                
                                TextField("Last Name", text: $lastName)
                                    .textInputAutocapitalization(.words)
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
                                
                                SecureField("Password", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                
                                if selectedRole == .patient {
                                    DatePicker("Birthdate", selection: $birthdate, displayedComponents: .date)
                                }
                                
                                if selectedRole == .patient {
                                    TextField("Referral Code", text: $referralCode)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .padding()
                                        .background(Color.white.opacity(0.9))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                
                                if selectedRole == .therapist {
                                    TextField("Medical License #", text: $medicalLicenseNum)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .padding()
                                        .background(Color.white.opacity(0.9))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                
                                Button(isLoading ? "Creating Account..." : "Sign Up") {
                                    signUp()
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
                            colors: [
                                Color.clear,
                                Color("AppBackground")
                            ],
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
    }//view ends here
    
        //chatgpt 5.3 used to help with restructuring UI here and fixing issues with device compatibility
    
    
    func isAtLeast18(birthdateEntered: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        let ageComponents = calendar.dateComponents([.year], from: birthdateEntered, to: now)
        return (ageComponents.year ?? 0) >= 18
    }
    
    func isValidLicenseNum(licenseNumEntered: String) -> Bool {
        let licensePrefixes = [
            "PSY-", "LP-", "PY-",          // Psychologist
            "LPC-", "LCPC-", "LMHC-", "LCMHC-",  // Counselors
            "LCSW-", "LMSW-", "CSW-",     // Social Workers
            "LMFT-", "MFT-",             // Marriage & Family Therapists
            "CADC-", "LCAS-", "LADC-"     // Addiction Counselors
        ]
        
        let hasPrefix = licensePrefixes.contains { licenseNumEntered.uppercased().hasPrefix($0) }
        
        return hasPrefix
    }
    
    func signUp() {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all required fields."
            showErrorAlert = true
            return
        }
        
        if selectedRole == .therapist && medicalLicenseNum.isEmpty {
            errorMessage = "Please fill in all required fields."
            showErrorAlert = true
            return
        }
        
        if selectedRole == .therapist && !isValidLicenseNum(licenseNumEntered: medicalLicenseNum) {
            errorMessage = "License number provided is invalid."
            showErrorAlert = true
            return
        }
        
        if selectedRole == .patient && !isAtLeast18(birthdateEntered: birthdate) {
            errorMessage = "Must be at least 18 to sign up."
            showErrorAlert = true
            return
        }
        
        if selectedRole == .patient && referralCode.isEmpty {
            errorMessage = "Must have active referral code."
            showErrorAlert = true
            return
        }
        
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
                        "riskscore":0,
                        "sender": "AI",
                        "timestamp":Timestamp()
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
                        "lastMessage": "Welcome to HealthQuest! I am your chat assistant! Feel free to send me a message whenever you are ready! I am here to help!",
                        "sender": "AI",
                        "lastMessageAt": Timestamp()
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
                        "sender": "therapist",
                        "therapistID": therapistId,
                        "clientName": firstName + " " + lastName,
                        "timestamp": Timestamp()
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
                        "sender": "therapist",
                        "lastMessageAt": Timestamp()
                ]) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                        isLoading = false
                        return
                    }
                }
                
                ref.updateData([
                    "used": true
                ]) { error in
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
    
}    //struct end here
    // used chatgpt 5.3 to help with research on implementing firebase into a SwiftUI application

    
    #Preview("Patient") {
        SignUpView(selectedRole: .patient)
    }
    
    #Preview("Therapist") {
        SignUpView(selectedRole: .therapist)
    }
    


//
//  SignUpView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/27/26.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    //helps open patient or therapist sign up
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
                        
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .padding(.vertical)
            }.alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(successMessage)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    } //view ends here
    
    
    func isAtLeast18(birthdateEntered: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        let ageComponents = calendar.dateComponents([.year], from: birthdateEntered, to: now)
        return (ageComponents.year ?? 0) >= 18
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
                    "therapistID": therapistId
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
                "patients": [] 
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
    


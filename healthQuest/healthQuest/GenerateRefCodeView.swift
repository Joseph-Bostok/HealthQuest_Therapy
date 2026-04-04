//
//  ProfilePageView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/31/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct GenerateReferralCode: View {
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @EnvironmentObject var session: SessionViewModel
    @State private var generatedCode = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if session.user?.role == "therapist" {
                                Button("Generate Referral Code") {
                                    if let uid = session.user?.uid {
                                        createUniqueReferralCode(for: uid)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                    HStack{
                        TextField("Referral Code", text: $generatedCode)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .disabled(true)
                        Button {
                                UIPasteboard.general.string = generatedCode
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .foregroundStyle(Color("AccentColor"))
                            }
                            .disabled(generatedCode.isEmpty)
                    }
                    
                            }
            }.navigationTitle("Generate Referral Code")
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .padding()
            
        }
    }
    
    func createUniqueReferralCode(for therapistId: String) {
        let db = Firestore.firestore()

        let characters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let code = String((0..<10).compactMap { _ in characters.randomElement() })

        let globalRef = db.collection("referralCodes").document(code)
        let therapistRef = db.collection("therapists").document(therapistId)

        db.runTransaction({ transaction, errorPointer in
            do {
                let existingDoc = try transaction.getDocument(globalRef)

                if existingDoc.exists {
                    return false
                }

                transaction.setData([
                    "code": code,
                    "therapistId": therapistId,
                    "used": false
                ], forDocument: globalRef)

                transaction.updateData([
                    "referralCodes": FieldValue.arrayUnion([code])
                ], forDocument: therapistRef)

                return true
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
        }) { result, error in
            if let error = error {
                let nsError = error as NSError

                if nsError.domain == FirestoreErrorDomain {
                    createUniqueReferralCode(for: therapistId)
                    return
                }

                errorMessage = error.localizedDescription
                showErrorAlert = true
                return
            }

            if let success = result as? Bool, success {
                generatedCode = code
            } else {
                createUniqueReferralCode(for: therapistId)
            }
        }
    }

    
}

//used chatgpt 5.3 to aid in programming the code generation 

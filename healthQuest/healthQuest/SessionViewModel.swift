import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class SessionViewModel: ObservableObject {
    @Published var user: AppUser?
    @Published var isLoading = false

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenForAuthChanges()
    }

    func listenForAuthChanges() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }

            if let firebaseUser = firebaseUser {
                self.loadUserData(uid: firebaseUser.uid)
            } else {
                self.user = nil
            }
        }
    }

    func loadUserData(uid: String) {
        let db = Firestore.firestore()
        isLoading = true

        db.collection("patients").document(uid).getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let document = document, document.exists {
                var firstName = document.get("firstName") as? String ?? ""
                var lastName = document.get("lastName") as? String ?? ""
                let email = document.get("email") as? String ?? ""

                self.user = AppUser(
                    uid: uid,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    role: "patient"
                )

                self.isLoading = false
            } else {
                db.collection("therapists").document(uid).getDocument { [weak self] document, error in
                    guard let self = self else { return }

                    if let document = document, document.exists {
                        var firstName = document.get("firstName") as? String ?? ""
                        var lastName = document.get("lastName") as? String ?? ""
                        let email = document.get("email") as? String ?? ""

                        self.user = AppUser(
                            uid: uid,
                            firstName: firstName,
                            lastName: lastName,
                            email: email,
                            role: "therapist"
                        )
                    } else {
                        self.user = nil
                    }

                    self.isLoading = false
                }
            }
        }
    }
    
    deinit {
        if let authHandle = authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }
}

//used chatgpt 5.3 to generate persistent session view model to be reused in all pages

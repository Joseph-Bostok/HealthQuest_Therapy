import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RootView: View {
    @State private var isLoggedIn = Auth.auth().currentUser != nil
    @State private var firstName = ""
    @State private var isLoadingUserData = false

    var body: some View {
        Group {
            if isLoggedIn {
                if isLoadingUserData {
                    ProgressView("Loading...")
                } else {
                    HomePageView(firstName: firstName)
                }
            } else {
                LoginView()
            }
        }
        .onAppear {
            Auth.auth().addStateDidChangeListener { _, user in
                if let user = user {
                    isLoggedIn = true
                    loadUserData(uid: user.uid)
                } else {
                    isLoggedIn = false
                    firstName = ""
                }
            }
        }
    }

    func loadUserData(uid: String) {
        let db = Firestore.firestore()
        isLoadingUserData = true

        db.collection("patients").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                firstName = document.get("firstName") as? String ?? "User"
                isLoadingUserData = false
            } else {
                db.collection("therapists").document(uid).getDocument { document, error in
                    if let document = document, document.exists {
                        firstName = document.get("firstName") as? String ?? "User"
                    } else {
                        firstName = "User"
                    }
                    isLoadingUserData = false
                }
            }
        }
    }
}

//used chatGpt 5.3 to get basic firebase authentication code for signing in

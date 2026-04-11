//
//  TherapistDirectoryView.swift
//  healthQuest
//
//  Page to view available therapists
//  TherapistProfileView pushed via NavigationLink (tab bar stays visible)
//  EnterReferralView uses .sheet (intentionally modal)
//  Cameron
//

import SwiftUI
import FirebaseFirestore


struct TherapistProfile: Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let bio: String


    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String { "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased() }
}


struct TherapistDirectoryView: View {

    @EnvironmentObject var session: SessionViewModel

    @State private var therapists: [TherapistProfile] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var showReferralSheet = false

    private let db = Firestore.firestore()

    var filteredTherapists: [TherapistProfile] {
        if searchText.isEmpty { return therapists }
        return therapists.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText) ||
            
            $0.bio.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                if isLoading {
                    ProgressView("Finding therapists...")
                        .tint(Color("AccentColor"))
                } else if filteredTherapists.isEmpty {
                    emptyState
                } else {
                    List(filteredTherapists) { therapist in
                        // NavigationLink pushes profile — tab bar stays visible
                        NavigationLink(destination: TherapistProfileView(therapist: therapist)) {
                            TherapistCard(therapist: therapist)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .searchable(text: $searchText, prompt: "Search by name or specialty…")
                }
            }
            .navigationTitle("Find a Therapist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if session.user?.role == "patient" {
                     ToolbarItem(placement: .topBarTrailing) {
                       Button {
                          showReferralSheet = true
                       } label: {
                           Label("Referral Code", systemImage: "ticket")
                               .font(.caption)
                       }
                     }
                }
            }
            .onAppear(perform: loadTherapists)
            // Referral code entry is intentionally a sheet (focused modal task)
            .sheet(isPresented: $showReferralSheet) {
                EnterReferralView()
                    .environmentObject(session)
            }
        }
    }

    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3")
                .font(.system(size: 70))
                .foregroundStyle(Color("AccentColor").opacity(0.35))
            Text("No therapists found")
                .font(.title2.bold())
            Text("Try adjusting your search or check back later.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    
    private func loadTherapists() {
        isLoading = true
        db.collection("therapists").getDocuments { snapshot, _ in
            isLoading = false
            guard let docs = snapshot?.documents else { return }
            self.therapists = docs.compactMap { doc in
                let data = doc.data()
                if session.user?.uid == doc.documentID {return nil}
                return TherapistProfile(
                    id: doc.documentID,
                    firstName: data["firstName"] as? String ?? "",
                    lastName: data["lastName"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    bio: data["bio"] as? String ?? "No bio provided.",
                )
            }
        }
    }
}


struct TherapistCard: View {
    @EnvironmentObject var session: SessionViewModel
    let therapist: TherapistProfile

    private let accentColors: [Color] = [Color("AccentColor"), .teal, .indigo, .purple, .mint]
    private var cardColor: Color { accentColors[abs(therapist.id.hashValue) % accentColors.count] }

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(cardColor.opacity(0.15))
                .frame(width: 58, height: 58)
                .overlay(
                    Text(therapist.initials)
                        .font(.title3.bold())
                        .foregroundStyle(cardColor)
                )

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Dr. \(therapist.fullName)").font(.headline)
                    Spacer()
                    
                    if session.user?.role == "patient" {
                        Label("Open", systemImage: "checkmark.circle.fill")
                            .font(.caption2.bold()).foregroundStyle(.green)
                    }
                }

                

                if !therapist.bio.isEmpty {
                    Text(therapist.bio)
                        .font(.caption).foregroundStyle(.tertiary).lineLimit(1)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


// Pushed via NavigationLink — tab bar remains visible
struct TherapistProfileView: View {
    let therapist: TherapistProfile
    @EnvironmentObject var session: SessionViewModel
    @State private var showReferralAlert = false
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @State private var goToChats = false
    
    @State private var chatRoom = ChatRoom(id: "", clientName: "", lastMessage: "", lastMessageAt: Date())

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Hero
                    VStack(spacing: 14) {
                        Circle()
                            .fill(Color("AccentColor").opacity(0.12))
                            .frame(width: 90, height: 90)
                            .overlay(
                                Text(therapist.initials)
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(Color("AccentColor"))
                            )

                        VStack(spacing: 4) {
                            Text("Dr. \(therapist.fullName)").font(.title2.bold())
                            Text(therapist.email).font(.subheadline).foregroundStyle(.secondary)
                        }

                        if session.user?.role == "patient" {
                               Label("Accepting New Clients", systemImage: "checkmark.circle.fill")
                                     .font(.caption.bold()).foregroundStyle(.green)
                                    .padding(.horizontal, 14).padding(.vertical, 6)
                                   .background(Color.green.opacity(0.1)).clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Bio
                    if !therapist.bio.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("About", systemImage: "person.text.rectangle")
                                .font(.headline).foregroundStyle(Color("AccentColor"))
                            Text(therapist.bio)
                                .font(.body).foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(Color.white.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                  

                    // CTA
                    if session.user?.role == "therapist" {
                        Button {
                            startProviderChat()
                        } label: {
                            Label("Send a Message", systemImage: "person.badge.plus")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                   
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }.alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationDestination(isPresented: $goToChats) {
            
            ChatDetailView(chatType: "providers", chatRoom: chatRoom)
        }
        .navigationTitle("Therapist Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func startProviderChat() {
        let db = Firestore.firestore()
        let name = (session.user?.firstName ?? "") + " " + (session.user?.lastName ?? "")
        let uid = session.user?.uid ?? ""
        
        //make sure the chat doesnt already exist
        db.collection("provider_chats")
            .whereField("therapist1", isEqualTo: uid)
            .whereField("therapist2", isEqualTo: therapist.id)
            .getDocuments { snapshot, error in
                if let doc = snapshot?.documents.first {
                    chatRoom = ChatRoom(id: doc.documentID, clientName: therapist.fullName, lastMessage: "", lastMessageAt: Date())
                    goToChats = true
                } else {
                    db.collection("provider_chats")
                        .whereField("therapist1", isEqualTo: therapist.id)
                        .whereField("therapist2", isEqualTo: uid)
                        .getDocuments { snapshot, error in
                            if let doc = snapshot?.documents.first {
                                chatRoom = ChatRoom(id: doc.documentID, clientName: therapist.fullName, lastMessage: "", lastMessageAt: Date())
                                goToChats = true
                            } else {
                                let docRef = db.collection("provider_chats").document()
                                docRef.setData([
                                        "therapist1": session.user?.uid ?? "",
                                        "therapist1name": name,
                                        "therapist2": therapist.id,
                                        "therapist2name": therapist.fullName,
                                        "timestamp": Timestamp()
                                ]) { error in
                                    if let error = error {
                                        errorMessage = error.localizedDescription
                                        showErrorAlert = true
                                        return
                                    } else {
                                        chatRoom = ChatRoom(id: docRef.documentID, clientName: therapist.fullName, lastMessage: "", lastMessageAt: Date())
                                        goToChats = true
                                    }
                                }
                            }
                        }
                }
            }
    }
}


struct EnterReferralView: View {
    @EnvironmentObject var session: SessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""
    @State private var isVerifying = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    Image(systemName: "ticket.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(Color("AccentColor").opacity(0.7))

                    VStack(spacing: 8) {
                        Text("Enter Referral Code").font(.title2.bold())
                        Text("Your therapist should have given you a unique code to connect.")
                            .font(.subheadline).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center).padding(.horizontal, 20)
                    }

                    VStack(spacing: 12) {
                        TextField("XXXXXXXXXX", text: $code)
                            .multilineTextAlignment(.center)
                            .font(.system(.title3, design: .monospaced, weight: .bold))
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal, 20)

                        if !errorMessage.isEmpty {
                            Text(errorMessage).font(.caption).foregroundStyle(.red)
                        }
                        if !successMessage.isEmpty {
                            Label(successMessage, systemImage: "checkmark.circle.fill")
                                .font(.caption.bold()).foregroundStyle(.green)
                        }
                    }

                    Button {
                        verifyCode()
                    } label: {
                        Group {
                            if isVerifying { ProgressView().tint(.white) }
                            else { Text("Connect with Therapist").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(code.isEmpty ? Color.secondary.opacity(0.4) : Color("AccentColor"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(code.isEmpty || isVerifying)
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle("Referral Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
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
    }

    private func verifyCode() {
        let referralCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !referralCode.isEmpty, let uid = session.user?.uid else { return }
        isVerifying = true
        errorMessage = ""
        
        let firstName = session.user?.firstName ?? ""
        let lastName = session.user?.lastName ?? ""
        let fullName = firstName + " " + lastName
        let welcomeMessage = "Hi " + firstName + "! I am looking forward to getting to know you as my newest patient! Send me a message about anything I may need to know in order to better assist you as you start your HealthQuest Therapy Journey :)"
        
        let db = Firestore.firestore()
        let referralRef = db.collection("referralCodes").document(referralCode)
        let chatRef = db.collection("therapist_chats").document(uid)
        let messagesRef = chatRef.collection("messages")
        let patientRef = db.collection("patients").document(uid)
        
        referralRef.getDocument { document, error in
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
            
            referralRef.updateData([
                "used": true
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
            
            chatRef.getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    let oldTherapistId = data["therapistID"] as? String ?? ""
                    
                    db.collection("therapists").document(oldTherapistId).updateData([
                        "patients": FieldValue.arrayRemove([uid])
                    ]) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                            return
                        }
                    }
                } else {
                    errorMessage = "There is an error with your account"
                    showErrorAlert = true
                }
            }
            
            db.collection("therapists").document(therapistId).updateData([
                "patients": FieldValue.arrayUnion([uid])
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                }
            }
            
            patientRef.updateData([
                "therapistID": therapistId
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                }
            }
            
            deleteMessages(for: uid) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                }
                
                
                messagesRef.document().setData([
                    "content": welcomeMessage,
                    "sender": therapistId,
                    "therapistID": therapistId,
                    //"clientName": fullName,
                    "timestamp": Timestamp(),
                    "read": false
                ]) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                        return
                    }
                }
                
                chatRef.setData([
                    "lastMessage": welcomeMessage,
                    "sender": therapistId,
                    "therapistID": therapistId,
                    "clientName": fullName,
                    "lastMessageAt": Timestamp(),
                    "read": false
                ]) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                        return
                    } else {
                        isVerifying = false
                        successMessage = "New therapist assigned!"
                        dismiss()
                        showSuccessAlert = true
                    }
                }
            }
            
        }
        
    }
    
    func deleteMessages(for uid: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let messagesRef = db.collection("therapist_chats")
            .document(uid)
            .collection("messages")

        messagesRef.getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion(nil)
                return
            }

            let batch = db.batch()

            for doc in documents {
                batch.deleteDocument(doc.reference)
            }

            batch.commit { error in
                completion(error)
            }
        }
    }

    }


#Preview {
    TherapistDirectoryView()
        .environmentObject(SessionViewModel())
}

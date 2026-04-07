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
    let specialties: [String]
    let bio: String
    let acceptingClients: Bool

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
            $0.specialties.joined().localizedCaseInsensitiveContains(searchText) ||
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showReferralSheet = true
                    } label: {
                        Label("Referral Code", systemImage: "ticket")
                            .font(.caption)
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
                return TherapistProfile(
                    id: doc.documentID,
                    firstName: data["firstName"] as? String ?? "",
                    lastName: data["lastName"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    specialties: data["specialties"] as? [String] ?? [],
                    bio: data["bio"] as? String ?? "No bio provided.",
                    acceptingClients: data["acceptingClients"] as? Bool ?? true
                )
            }
        }
    }
}


struct TherapistCard: View {
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
                    if therapist.acceptingClients {
                        Label("Open", systemImage: "checkmark.circle.fill")
                            .font(.caption2.bold()).foregroundStyle(.green)
                    } else {
                        Label("Full", systemImage: "xmark.circle.fill")
                            .font(.caption2.bold()).foregroundStyle(.secondary)
                    }
                }

                Text(therapist.specialties.isEmpty
                     ? "General Therapy"
                     : therapist.specialties.prefix(3).joined(separator: " · "))
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)

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

                        if therapist.acceptingClients {
                            Label("Accepting New Clients", systemImage: "checkmark.circle.fill")
                                .font(.caption.bold()).foregroundStyle(.green)
                                .padding(.horizontal, 14).padding(.vertical, 6)
                                .background(Color.green.opacity(0.1)).clipShape(Capsule())
                        } else {
                            Label("Not Accepting New Clients", systemImage: "xmark.circle.fill")
                                .font(.caption.bold()).foregroundStyle(.secondary)
                                .padding(.horizontal, 14).padding(.vertical, 6)
                                .background(Color.secondary.opacity(0.1)).clipShape(Capsule())
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

                    // Specialties
                    if !therapist.specialties.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Specialties", systemImage: "star.fill")
                                .font(.headline).foregroundStyle(Color("AccentColor"))
                            // Simple wrapped tags
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                ForEach(therapist.specialties, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Color("AccentColor").opacity(0.1))
                                        .foregroundStyle(Color("AccentColor"))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(Color.white.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // CTA
                    Button {
                        showReferralAlert = true
                    } label: {
                        Label("Request to Connect", systemImage: "person.badge.plus")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(therapist.acceptingClients ? Color("AccentColor") : Color.secondary.opacity(0.5))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(!therapist.acceptingClients)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Therapist Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Request a Referral Code", isPresented: $showReferralAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Ask Dr. \(therapist.fullName) for a referral code to connect with them in HealthQuest.")
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
        }
    }

    private func verifyCode() {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty, let patient = session.user else { return }
        isVerifying = true
        errorMessage = ""

        let codeRef = db.collection("referralCodes").document(trimmed)
        codeRef.getDocument { document, _ in
            isVerifying = false
            guard let doc = document, doc.exists else {
                errorMessage = "Invalid or expired referral code."; return
            }
            guard let used = doc.data()?["used"] as? Bool, !used else {
                errorMessage = "This code has already been used."; return
            }
            guard let therapistId = doc.data()?["therapistId"] as? String else {
                errorMessage = "Something went wrong. Please try again."; return
            }

            let patientName = "\(patient.firstName) \(patient.lastName)"
            let chatId = "\(therapistId)_\(patient.uid)"
            let batch = db.batch()

            batch.updateData(["used": true, "usedBy": patient.uid], forDocument: codeRef)
            batch.updateData([
                "therapistId": therapistId,
                "assignedPatients": FieldValue.arrayUnion([patient.uid])
            ], forDocument: db.collection("patients").document(patient.uid))
            batch.setData([
                "therapistId": therapistId,
                "clientId": patient.uid,
                "clientName": patientName,
                "lastMessage": "",
                "lastMessageAt": Timestamp(date: Date()),
                "unreadCount": 0
            ], forDocument: db.collection("chats").document(chatId))

            batch.commit { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    successMessage = "Connected successfully!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    TherapistDirectoryView()
        .environmentObject(SessionViewModel())
}

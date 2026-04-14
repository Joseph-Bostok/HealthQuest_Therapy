//
//  Untitled.swift
//  healthQuest
//
//  Created by Lauren Simineau on 4/4/26.
//

import SwiftUI
import FirebaseFirestore

struct TherapistClient: Identifiable, Hashable {
    let active: Bool
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let bio: String
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    var flagged: Bool
}

struct JournalReviewView: View {
    @EnvironmentObject var session: SessionViewModel

    @State private var clients: [TherapistClient] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var showErrorAlert = false

    private let db = Firestore.firestore()

    var filteredClients: [TherapistClient] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return clients
        }

        return clients.filter { client in
            client.fullName.localizedCaseInsensitiveContains(searchText) ||
            client.email.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                if isLoading {
                    ProgressView("Loading clients...")
                        .tint(Color("AccentColor"))
                } else if filteredClients.isEmpty {
                    emptyState
                } else {
                    List(filteredClients) { client in
                        NavigationLink(
                            destination: JournalView(patientId: client.id)
                        ) {
                            clientRow(client)
                        }
                        //TO DO: change color here
                        .listRowBackground(client.flagged ? Color.red.opacity(0.2) : .clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .searchable(text: $searchText, prompt: "Search clients")
                }
            }
            .navigationTitle("My Clients")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadClients)
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2")
                .font(.system(size: 70))
                .foregroundStyle(Color("AccentColor").opacity(0.35))

            Text(searchText.isEmpty ? "No clients yet" : "No matching clients")
                .font(.title2.bold())

            Text(searchText.isEmpty
                 ? "When patients connect to your account, they’ll appear here."
                 : "Try a different name or email.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func clientRow(_ client: TherapistClient) -> some View {
        HStack(spacing: 14) {
            if client.active {
                Circle()
                    .fill(Color("AccentColor").opacity(0.15))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(client.firstName.prefix(1).uppercased())
                            .font(.title3.bold())
                            .foregroundStyle(Color("AccentColor"))
                        
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(client.fullName)
                        .font(.headline)
                    
                    Text(client.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } else {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(client.firstName.prefix(1).uppercased())
                            .font(.title3.bold())
                            .foregroundStyle(Color.gray)
                        
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("INACTIVE: " + client.fullName)
                        .font(.headline)
                    
                    Text(client.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func loadClients() {
        guard let therapistId = session.user?.uid else {
            errorMessage = "Unable to access therapist account."
            showErrorAlert = true
            isLoading = false
            return
        }

        isLoading = true

        db.collection("therapists")
            .document(therapistId)
            .getDocument { snapshot, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    isLoading = false
                    return
                }

                guard let data = snapshot?.data() else {
                    errorMessage = "Therapist profile not found."
                    showErrorAlert = true
                    isLoading = false
                    return
                }

                let patientIds = data["patients"] as? [String] ?? []

                if patientIds.isEmpty {
                    clients = []
                    isLoading = false
                    return
                }

                loadPatientDocuments(patientIds: patientIds)
            }
    }
    
    private func checkforFlags(id: String, completion: @escaping (Bool) -> Void) {
        db.collection("journals")
            .document(id)
            .collection("journalEntries")
            .whereField("flagged", isEqualTo: true)
            .getDocuments { snap, error in
                if error != nil {
                    completion(false)
                    return
                }

                let isFlagged = !(snap?.documents.isEmpty ?? true)
                completion(isFlagged)
            }
    }

    private func loadPatientDocuments(patientIds: [String]) {
        let group = DispatchGroup()
        var loadedClients: [TherapistClient] = []
        var firstError: String?

        for patientId in patientIds {
            group.enter()

            db.collection("patients")
                .document(patientId)
                .getDocument { snapshot, error in
                    if let error = error {
                        if firstError == nil {
                            firstError = error.localizedDescription
                        }
                        group.leave()
                        return
                    }

                    guard let data = snapshot?.data() else {
                        group.leave()
                        return
                    }

                    var client = TherapistClient(
                        active: data["active"] as? Bool ?? true,
                        id: patientId,
                        firstName: data["firstName"] as? String ?? "",
                        lastName: data["lastName"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        bio: data["bio"] as? String ?? "",
                        flagged: false
                    )

                    checkforFlags(id: patientId) { isFlagged in
                        client.flagged = isFlagged
                        loadedClients.append(client)
                        group.leave()
                    }
                }
        }

        group.notify(queue: .main) {
            self.isLoading = false

            if let firstError = firstError {
                self.errorMessage = firstError
                self.showErrorAlert = true
            }

            self.clients = loadedClients.sorted {
                $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending
            }
        }
    }
    
    //used chatgpt 5.3 to help w asynchronous logic
}

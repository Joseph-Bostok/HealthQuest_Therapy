//
//  ChatsView.swift
//  healthQuest
//
//  Therapist chats list + Patient chat view
//  Role-aware: therapists see all clients, patients see their assigned therapist
//  ChatDetailView is pushed via NavigationLink (stays inside tab bar)
//  Cameron
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TherapistChatsView: View {
    
    let chatType: String
    
    @EnvironmentObject var session: SessionViewModel
    @State private var chatRooms: [ChatRoom] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    
    @State private var providerListener1: ListenerRegistration?
    @State private var providerListener2: ListenerRegistration?

    private let db = Firestore.firestore()
   

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                if isLoading {
                    ProgressView("Loading conversations...")
                        .tint(Color("AccentColor"))
                } else if chatRooms.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 85))
                            .foregroundStyle(.secondary)
                        Text("No clients yet")
                            .font(.title2.bold())
                        Text("Once patients use your referral code,\ntheir chats will appear here.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 40)
                } else {
                    List(chatRooms) { room in
                        NavigationLink(destination: ChatDetailView(chatType: chatType, chatRoom: room)) {
                            ChatRoomRow(room: room, isTherapistAIView: (chatType == "ai"))
                        }
                        .listRowBackground(
                            room.flagged
                            ? Color.red.opacity(0.2)
                            : Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: loadChatRooms) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear(perform: loadChatRooms)
            .onDisappear {
                providerListener1?.remove()
                providerListener2?.remove()
            }
        }.alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadChatRooms() {
        if chatType == "clients" {
            loadChatRoomsCLIENTS()
        }
        if chatType == "providers" {
            loadChatRoomsPROVIDERS()
        }
        if chatType == "ai" {
            loadChatRoomsAI()
        }
    }

    private func loadChatRoomsCLIENTS() {
        guard let therapistId = session.user?.uid else {
            errorMessage = "therapist ID mismatch"
            showErrorAlert = true
            isLoading = false
            return
        }
            
        guard session.user?.role == "therapist" else {
            errorMessage = "therapist role mismatch"
            showErrorAlert = true
            isLoading = false
            return
        }

        isLoading = true

        db.collection("therapist_chats")
                .whereField("therapistID", isEqualTo: therapistId)
                .addSnapshotListener { snapshot, error in
                    isLoading = false

                    if let error = error {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                        chatRooms = []
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        errorMessage = "no chats found"
                        showErrorAlert = true
                        chatRooms = []
                        return
                    }

                    let rooms = documents.map { doc -> ChatRoom in
                        let data = doc.data()

                        return ChatRoom(
                            id: doc.documentID,
                            clientName: data["clientName"] as? String ?? "",
                            lastMessage: data["lastMessage"] as? String ?? "",
                            lastMessageAt: (data["lastMessageAt"] as? Timestamp)?.dateValue() ?? Date.distantPast,
                            read: data["read"] as? Bool ?? false,
                            sender: data["sender"] as? String ?? "",
                            flagged: false
                        )
                    }

                    chatRooms = rooms.sorted { $0.lastMessageAt > $1.lastMessageAt }
                }
        }

    private func loadChatRoomsPROVIDERS() {
        guard let therapistId = session.user?.uid else {
            errorMessage = "Therapist ID mismatch"
            showErrorAlert = true
            isLoading = false
            return
        }

        isLoading = true

        providerListener1?.remove()
        providerListener2?.remove()

        var chatsAsTherapist1: [ChatRoom] = []
        var chatsAsTherapist2: [ChatRoom] = []

        func updateCombinedRooms() {
            let combined = chatsAsTherapist1 + chatsAsTherapist2
            
            let uniqueRooms = Dictionary(grouping: combined, by: { $0.id })
                .compactMap { $0.value.first }
            
            chatRooms = uniqueRooms.sorted { $0.lastMessageAt > $1.lastMessageAt }
            isLoading = false
        }

        providerListener1 = db.collection("provider_chats")
            .whereField("therapist1", isEqualTo: therapistId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    chatsAsTherapist1 = []
                    updateCombinedRooms()
                    return
                }

                guard let documents = snapshot?.documents else {
                    chatsAsTherapist1 = []
                    updateCombinedRooms()
                    return
                }

                chatsAsTherapist1 = documents.map { doc -> ChatRoom in
                    let data = doc.data()

                    return ChatRoom(
                        id: doc.documentID,
                        clientName: data["therapist2name"] as? String ?? "Unknown Provider",
                        lastMessage: data["lastMessage"] as? String ?? "",
                        lastMessageAt: (data["lastMessageAt"] as? Timestamp)?.dateValue() ?? Date.distantPast,
                        read: data["read"] as? Bool ?? false,
                        sender: data["sender"] as? String ?? "",
                        flagged: false
                    )
                }

                updateCombinedRooms()
            }

        providerListener2 = db.collection("provider_chats")
            .whereField("therapist2", isEqualTo: therapistId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    chatsAsTherapist2 = []
                    updateCombinedRooms()
                    return
                }

                guard let documents = snapshot?.documents else {
                    chatsAsTherapist2 = []
                    updateCombinedRooms()
                    return
                }

                chatsAsTherapist2 = documents.map { doc -> ChatRoom in
                    let data = doc.data()

                    return ChatRoom(
                        id: doc.documentID,
                        clientName: data["therapist1name"] as? String ?? "Unknown Provider",
                        lastMessage: data["lastMessage"] as? String ?? "",
                        lastMessageAt: (data["lastMessageAt"] as? Timestamp)?.dateValue() ?? Date.distantPast,
                        read: data["read"] as? Bool ?? false,
                        sender: data["sender"] as? String ?? "",
                        flagged: false
                    )
                }

                updateCombinedRooms()
            }
    }
    
    //used chatgpt5.3 to generate the logic to find therapists on both ids, originally my logic only looked one direction, needed help figuring out how to merge results without overwriting
    
    private func loadChatRoomsAI() {
        guard let therapistId = session.user?.uid else {
            errorMessage = "therapist ID mismatch"
            showErrorAlert = true
            isLoading = false
            return
        }
        
        guard session.user?.role == "therapist" else {
            errorMessage = "therapist role mismatch"
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
                    chatRooms = []
                    isLoading = false
                    return
                }
                
                loadAIChats(patientIds: patientIds)
            }
    }
    
    func loadAIChats(patientIds: [String]) {
            
        guard session.user?.role == "therapist" else {
            errorMessage = "therapist role mismatch"
            showErrorAlert = true
            isLoading = false
            return
        }

        isLoading = true

        var loadedRooms: [ChatRoom] = []
            let group = DispatchGroup()

            for patientId in patientIds {
                group.enter()

                db.collection("ai_chats")
                    .document(patientId)
                    .getDocument { snapshot, error in
                        defer { group.leave() }

                        if let error = error {
                            print("Error loading AI chat for \(patientId): \(error.localizedDescription)")
                            return
                        }

                        guard let snapshot = snapshot, snapshot.exists,
                              let data = snapshot.data() else {
                            return
                        }

                        let room = ChatRoom(
                            id: snapshot.documentID,
                            clientName: data["clientName"] as? String ?? "Unknown Client",
                            lastMessage: data["lastMessage"] as? String ?? "",
                            lastMessageAt: (data["lastMessageAt"] as? Timestamp)?.dateValue() ?? Date.distantPast,
                            read: data["read"] as? Bool ?? false,
                            sender: data["sender"] as? String ?? "",
                            flagged: data["flagged"] as? Bool ?? false
                        )

                        loadedRooms.append(room)
                    }
            }

            group.notify(queue: .main) {
                self.chatRooms = loadedRooms.sorted { $0.lastMessageAt > $1.lastMessageAt }
                self.isLoading = false

                if self.chatRooms.isEmpty {
                    self.errorMessage = "No AI chats found"
                    self.showErrorAlert = true
                }
            }
        
        //used chat gpt 5.3 to generate listener to find all patients (even as they are added)
    }

       
}


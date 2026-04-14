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


struct ChatRoom: Identifiable, Equatable {
    let id: String
    let clientName: String
    let lastMessage: String
    let lastMessageAt: Date
    let read: Bool
    let sender: String
    let flagged: Bool
}

struct PatientChatsView: View {

    @EnvironmentObject var session: SessionViewModel
    @State private var chatRooms: [ChatRoom] = []
    @State private var isLoading = true

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
                        Text("No chats yet")
                            .font(.title2.bold())
                    }
                    .padding(.horizontal, 40)
                } else {
                    List(chatRooms) { room in
                        NavigationLink(destination: ChatDetailView(chatType: room.id, chatRoom: room)) {
                            ChatRoomRow(room: room, isTherapistAIView: false)
                        }
                        .listRowBackground(
                            room.flagged
                            ? Color.red.opacity(0.2)
                            : Color.clear
                        )
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
                    Button(action: loadPatientChats) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear(perform: loadPatientChats)
        }
    }

    private func loadPatientChats() {
            guard let patientId = session.user?.uid,
                  session.user?.role == "patient" else {
                isLoading = false
                return
            }

            isLoading = true

            var aiRoom: ChatRoom?
            var therapistRoom: ChatRoom?

            func updateRooms() {
                var rooms: [ChatRoom] = []

                if let aiRoom = aiRoom {
                    rooms.append(aiRoom)
                }

                if let therapistRoom = therapistRoom {
                    rooms.append(therapistRoom)
                }

                chatRooms = rooms.sorted { $0.lastMessageAt > $1.lastMessageAt }
                isLoading = false
            }

            db.collection("ai_chats")
                .document(patientId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error loading AI chat: \(error.localizedDescription)")
                        aiRoom = nil
                        updateRooms()
                        return
                    }

                    guard let data = snapshot?.data() else {
                        aiRoom = nil
                        updateRooms()
                        return
                    }

                    aiRoom = ChatRoom(
                        id: "ai",
                        clientName: "HealthQuest AI",
                        lastMessage: data["lastMessage"] as? String ?? "",
                        lastMessageAt: (data["lastMessageAt"] as? Timestamp)?.dateValue() ?? Date.distantPast,
                        read: data["read"] as? Bool ?? false,
                        sender: data["sender"] as? String ?? "",
                        flagged: data["flagged"] as? Bool ?? false
                        
                    )

                    updateRooms()
                }

            db.collection("therapist_chats")
                .document(patientId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error loading therapist chat: \(error.localizedDescription)")
                        therapistRoom = nil
                        updateRooms()
                        return
                    }

                    guard let data = snapshot?.data() else {
                        therapistRoom = nil
                        updateRooms()
                        return
                    }

                    therapistRoom = ChatRoom(
                        id: "clients",
                        clientName: "My Therapist",
                        lastMessage: data["lastMessage"] as? String ?? "",
                        lastMessageAt: (data["lastMessageAt"] as? Timestamp)?.dateValue() ?? Date.distantPast,
                        read: data["read"] as? Bool ?? false,
                        sender: data["sender"] as? String ?? "",
                        flagged: false
                    )

                    updateRooms()
                }
        }
}

// used chatgpt 5.3 for logic to load patient and client chat data into array

struct ChatRoomRow: View {
    let room: ChatRoom
    let isTherapistAIView: Bool
    @EnvironmentObject var session: SessionViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color("AccentColor").opacity(0.15))
                .frame(width: 52, height: 52)
                .overlay(
                    Text(room.clientName.prefix(1).uppercased())
                        .font(.title2.bold())
                        .foregroundStyle(Color("AccentColor"))
                )

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(room.clientName)
                        .font(.headline)
                        .fontWeight(
                            (!room.read && room.sender != session.user?.uid && !isTherapistAIView)
                            ? .bold
                            : .regular
                        )
                    Spacer()
                    Text(timeAgoString(from: room.lastMessageAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if !room.read && room.sender != session.user?.uid && !isTherapistAIView{
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }
                }

                Text(room.lastMessage)
                    .lineLimit(1)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func timeAgoString(from date: Date) -> String {
        if date == Date.distantPast { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}


// Pushed via NavigationLink — tab bar remains visible


#Preview {
    PatientChatsView()
        .environmentObject(SessionViewModel())
}

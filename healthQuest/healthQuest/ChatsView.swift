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

// MARK: - Models
struct ChatRoom: Identifiable, Equatable {
    let id: String
    let clientId: String
    let clientName: String
    let therapistId: String
    let lastMessage: String
    let lastMessageAt: Date
    let unreadCount: Int
    let hasMessages: Bool

    var isUnread: Bool { unreadCount > 0 }
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    let senderId: String
    let senderName: String
    let text: String
    let timestamp: Date
    let isFromTherapist: Bool

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - ChatsView (role-aware router)
struct ChatsView: View {
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        if session.user?.role == "therapist" {
            TherapistChatsView()
        } else {
            PatientChatsView()
        }
    }
}

// MARK: - Therapist Chats List
struct TherapistChatsView: View {

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
                        Text("No clients yet")
                            .font(.title2.bold())
                        Text("Once patients use your referral code,\ntheir chats will appear here.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 40)
                } else {
                    List(chatRooms) { room in
                        NavigationLink(destination: ChatDetailView(chatRoom: room)) {
                            ChatRoomRow(room: room, isTherapistView: true)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Clients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: loadChatRooms) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear(perform: loadChatRooms)
        }
    }

    private func loadChatRooms() {
        guard let therapistId = session.user?.uid, session.user?.role == "therapist" else { return }
        isLoading = true

        db.collection("chats")
            .whereField("therapistId", isEqualTo: therapistId)
            .addSnapshotListener { snapshot, _ in
                isLoading = false
                guard let documents = snapshot?.documents else { return }

                let rooms = documents.compactMap { doc -> ChatRoom? in
                    let data = doc.data()
                    let lastMsg = data["lastMessage"] as? String ?? ""
                    return ChatRoom(
                        id: doc.documentID,
                        clientId: data["clientId"] as? String ?? "",
                        clientName: data["clientName"] as? String ?? "Unknown Client",
                        therapistId: data["therapistId"] as? String ?? "",
                        lastMessage: lastMsg,
                        lastMessageAt: (data["lastMessageAt"] as? Timestamp)?.dateValue() ?? Date.distantPast,
                        unreadCount: data["unreadCount"] as? Int ?? 0,
                        hasMessages: !lastMsg.isEmpty
                    )
                }
                self.chatRooms = rooms.sorted { $0.lastMessageAt > $1.lastMessageAt }
            }
    }
}

// MARK: - Patient Chats View
struct PatientChatsView: View {

    @EnvironmentObject var session: SessionViewModel
    @State private var chatRoom: ChatRoom? = nil
    @State private var isLoading = true

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                if isLoading {
                    ProgressView("Loading your chat...")
                        .tint(Color("AccentColor"))
                } else if let room = chatRoom {
                    List {
                        NavigationLink(destination: ChatDetailView(chatRoom: room)) {
                            ChatRoomRow(room: room, isTherapistView: false)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                } else {
                    noTherapistState
                }
            }
            .navigationTitle("My Therapist")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadPatientChat)
        }
    }

    private var noTherapistState: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            Text("No therapist yet")
                .font(.title2.bold())
            Text("Connect with a therapist using their referral code to start chatting.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            NavigationLink(destination: TherapistDirectoryView()) {
                Label("Find a Therapist", systemImage: "magnifyingglass")
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color("AccentColor"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func loadPatientChat() {
        guard let patientId = session.user?.uid, session.user?.role == "patient" else { return }
        isLoading = true

        db.collection("chats")
            .whereField("clientId", isEqualTo: patientId)
            .limit(to: 1)
            .addSnapshotListener { snapshot, _ in
                isLoading = false
                guard let doc = snapshot?.documents.first else {
                    chatRoom = nil
                    return
                }
                let data = doc.data()
                let lastMsg = data["lastMessage"] as? String ?? ""
                chatRoom = ChatRoom(
                    id: doc.documentID,
                    clientId: data["clientId"] as? String ?? "",
                    clientName: data["clientName"] as? String ?? "",
                    therapistId: data["therapistId"] as? String ?? "",
                    lastMessage: lastMsg,
                    lastMessageAt: (data["lastMessageAt"] as? Timestamp)?.dateValue() ?? Date.distantPast,
                    unreadCount: data["unreadCount"] as? Int ?? 0,
                    hasMessages: !lastMsg.isEmpty
                )
            }
    }
}

// MARK: - Chat Room Row
struct ChatRoomRow: View {
    let room: ChatRoom
    let isTherapistView: Bool

    var displayName: String {
        isTherapistView ? room.clientName : "My Therapist"
    }

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color("AccentColor").opacity(0.15))
                .frame(width: 52, height: 52)
                .overlay(
                    Text(displayName.prefix(1).uppercased())
                        .font(.title2.bold())
                        .foregroundStyle(Color("AccentColor"))
                )

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(displayName)
                        .font(.headline)
                    Spacer()
                    Text(timeAgoString(from: room.lastMessageAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(room.hasMessages ? room.lastMessage : "Tap to start conversation")
                    .lineLimit(1)
                    .font(.subheadline)
                    .foregroundStyle(room.hasMessages ? .secondary : .tertiary)
                    .italic(!room.hasMessages)
            }

            if room.isUnread {
                ZStack {
                    Circle()
                        .fill(Color("AccentColor"))
                        .frame(width: 22, height: 22)
                    Text("\(room.unreadCount)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                }
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

// MARK: - Chat Detail View
// Pushed via NavigationLink — tab bar remains visible
struct ChatDetailView: View {

    let chatRoom: ChatRoom
    @EnvironmentObject var session: SessionViewModel

    @State private var messages: [ChatMessage] = []
    @State private var newMessageText: String = ""

    private let db = Firestore.firestore()

    private var isTherapist: Bool { session.user?.role == "therapist" }
    private var displayName: String { isTherapist ? chatRoom.clientName : "My Therapist" }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 0) {
                if messages.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        Text("No messages yet")
                            .font(.title3.bold())
                        Text("Send the first message to start the conversation.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { msg in
                                    MessageBubble(
                                        message: msg,
                                        isCurrentUser: msg.senderId == session.user?.uid
                                    )
                                    .id(msg.id)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                        }
                        .onChange(of: messages) { _, _ in
                            if let last = messages.last {
                                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                        .onAppear {
                            if let last = messages.last {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Message input bar
                HStack(spacing: 12) {
                    TextField("Message…", text: $newMessageText, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 22))

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(
                                newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color.secondary.opacity(0.4)
                                    : Color("AccentColor")
                            )
                    }
                    .disabled(newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color("AppBackground"))
            }
        }
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            listenToMessages()
            if chatRoom.hasMessages { markAsRead() }
        }
    }

    private func listenToMessages() {
        db.collection("chats")
            .document(chatRoom.id)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.messages = docs.compactMap { try? $0.data(as: ChatMessage.self) }
            }
    }

    private func markAsRead() {
        let field = isTherapist ? "unreadCount" : "patientUnreadCount"
        db.collection("chats").document(chatRoom.id).updateData([field: 0])
    }

    private func sendMessage() {
        let trimmed = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let user = session.user else { return }

        let message = ChatMessage(
            id: UUID().uuidString,
            senderId: user.uid,
            senderName: user.firstName,
            text: trimmed,
            timestamp: Date(),
            isFromTherapist: isTherapist
        )

        do {
            try db.collection("chats")
                .document(chatRoom.id)
                .collection("messages")
                .document(message.id)
                .setData(from: message)

            var updateData: [String: Any] = [
                "lastMessage": trimmed,
                "lastMessageAt": Timestamp(date: Date())
            ]
            if isTherapist {
                updateData["patientUnreadCount"] = FieldValue.increment(Int64(1))
            } else {
                updateData["unreadCount"] = FieldValue.increment(Int64(1))
            }
            db.collection("chats").document(chatRoom.id).updateData(updateData)
            newMessageText = ""
        } catch {
            print("Error sending message: \(error)")
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isCurrentUser
                            ? Color("AccentColor")
                            : Color.white.opacity(0.95)
                    )
                    .foregroundStyle(isCurrentUser ? .white : .primary)
                    .clipShape(
                        RoundedCornerShape(
                            radius: 18,
                            corners: isCurrentUser
                                ? [.topLeft, .topRight, .bottomLeft]
                                : [.topLeft, .topRight, .bottomRight]
                        )
                    )

                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if !isCurrentUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Rounded Corner Shape
struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ChatsView()
        .environmentObject(SessionViewModel())
}

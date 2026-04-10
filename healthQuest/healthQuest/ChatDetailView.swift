//
//  ChatDetailView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 4/10/26.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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

struct ChatDetailView: View {

    let chatRoom: ChatRoom
    @EnvironmentObject var session: SessionViewModel

    @State private var messages: [ChatMessage] = []
    @State private var newMessageText: String = ""

    private let db = Firestore.firestore()

    private var isTherapist: Bool { session.user?.role == "therapist" }
    //private var displayName: String { isTherapist ? chatRoom.clientName : "My Therapist" }

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
        .navigationTitle(chatRoom.clientName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            listenToMessages()
            //if chatRoom.hasMessages { markAsRead() }
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

        //private func markAsRead() {
      //  let field = isTherapist ? "unreadCount" : "patientUnreadCount"
       // db.collection("chats").document(chatRoom.id).updateData([field: 0])
   // }

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

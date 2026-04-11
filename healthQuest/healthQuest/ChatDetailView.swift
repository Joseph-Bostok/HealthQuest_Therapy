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
    @DocumentID var id: String?
    let content: String
    let sender: String
    let timestamp: Date
    let read: Bool
    
    let flagged: Bool?
    let riskscore: Int?

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

struct ChatDetailView: View {
    let chatType: String
    let chatRoom: ChatRoom
    @EnvironmentObject var session: SessionViewModel
    @State private var messages: [ChatMessage] = []
    @State private var newMessageText: String = ""
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private let db = Firestore.firestore()

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
                                    if chatType == "AI" {
                                        MessageBubble(
                                            message: msg,
                                            isCurrentUser: !(msg.sender == "AI")
                                        )
                                        .id(msg.id)
                                    } else {
                                        MessageBubble(
                                            message: msg,
                                            isCurrentUser: msg.sender == session.user?.uid
                                        )
                                        .id(msg.id)
                                    }
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
                if !(session.user?.role == "therapist" && chatType == "ai"){
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
                    }.padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color("AppBackground"))
                }
                
            }
        }.alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationTitle(chatRoom.clientName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            listenToMessages()
        }
    }

    private func listenToMessages() {
        if chatType == "ai" {
            if session.user?.role == "patient" {
                db.collection("ai_chats")
                    .document(session.user?.uid ?? "")
                    .collection("messages")
                    .order(by: "timestamp", descending: false)
                    .addSnapshotListener { snapshot, _ in
                        guard let docs = snapshot?.documents else { return }
                        self.messages = docs.compactMap { try? $0.data(as: ChatMessage.self) }
                    }
            } else {
                db.collection("ai_chats")
                    .document(chatRoom.id)
                    .collection("messages")
                    .order(by: "timestamp", descending: false)
                    .addSnapshotListener { snapshot, _ in
                        guard let docs = snapshot?.documents else { return }
                        self.messages = docs.compactMap { try? $0.data(as: ChatMessage.self) }
                    }
            }
        }
        if chatType == "providers" {
            db.collection("provider_chats")
                .document(chatRoom.id)
                .collection("messages")
                .order(by: "timestamp", descending: false)
                .addSnapshotListener { snapshot, _ in
                    guard let docs = snapshot?.documents else { return }
                    self.messages = docs.compactMap { try? $0.data(as: ChatMessage.self) }
                }
        }
        if chatType == "clients" {
            if session.user?.role == "patient" {
                db.collection("therapist_chats")
                    .document(session.user?.uid ?? "")
                    .collection("messages")
                    .order(by: "timestamp", descending: false)
                    .addSnapshotListener { snapshot, _ in
                        guard let docs = snapshot?.documents else { return }
                        self.messages = docs.compactMap { try? $0.data(as: ChatMessage.self) }
                    }
            } else {
                db.collection("therapist_chats")
                    .document(chatRoom.id)
                    .collection("messages")
                    .order(by: "timestamp", descending: false)
                    .addSnapshotListener { snapshot, _ in
                        guard let docs = snapshot?.documents else { return }
                        self.messages = docs.compactMap { try? $0.data(as: ChatMessage.self) }
                    }
            }
        }

    }


    private func sendMessage() {
        if session.user?.role == "patient" {
            sendMessageClient()
        } else {
            sendMessageTherapist()
        }
    }
    
    private func sendMessageClient() {
        let trimmed = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let db = Firestore.firestore()
        guard let uid = session.user?.uid else {
            return
        }
        if chatType == "ai" {
            CHECKFORFLAG()
            db.collection("ai_chats").document(uid).collection("messages")
                .document().setData([
                    "content": newMessageText,
                    "sender": uid,
                    "flagged": false,
                    "riskscore": 0,
                    "timestamp": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                } else {
                    SENDAIPROMPT()
                }
            }
            
            db.collection("ai_chats").document(uid)
                .updateData([
                    "lastMessage": newMessageText,
                    "sender": uid,
                    "lastMessageAt": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                } else {
                    newMessageText = ""
                }
            }
        }
        if chatType == "clients" {
            db.collection("therapist_chats").document(uid).collection("messages")
                .document().setData([
                    "content": newMessageText,
                    "sender": uid,
                    "timestamp": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                }
            }
            
            db.collection("therapist_chats").document(uid)
                .updateData([
                    "lastMessage": newMessageText,
                    "sender": uid,
                    "lastMessageAt": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                } else {
                    newMessageText = ""
                }
            }
        }
        
    }
    
    
    private func sendMessageTherapist() {
        let trimmed = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let db = Firestore.firestore()
        guard let uid = session.user?.uid else {
            return
        }
        if chatType == "providers" {
            db.collection("provider_chats").document(chatRoom.id).collection("messages")
                .document().setData([
                    "content": newMessageText,
                    "sender": uid,
                    "timestamp": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                }
            }
            db.collection("provider_chats").document(chatRoom.id)
                .updateData([
                    "lastMessage": newMessageText,
                    "sender": uid,
                    "lastMessageAt": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                } else {
                    newMessageText = ""
                }
            }
        }
        if chatType == "clients" {
            db.collection("therapist_chats").document(chatRoom.id).collection("messages")
                .document().setData([
                    "content": newMessageText,
                    "sender": uid,
                    "timestamp": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                }
            }
            db.collection("therapist_chats").document(chatRoom.id)
                .updateData([
                    "lastMessage": newMessageText,
                    "sender": uid,
                    "lastMessageAt": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                } else {
                    newMessageText = ""
                }
            }
        }
    }
    
    private func CHECKFORFLAG() {
        //TO DO: check for bad keywords
    }
    
    private func SENDAIPROMPT() {
        //TO DO: send logic for AI reply
    }
    
    private func MARKASREAD() {
        //TO DO: mark as read
    }
}


struct MessageBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 3) {
                Text(message.content)
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

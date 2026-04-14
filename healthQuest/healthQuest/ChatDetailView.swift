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
    @State var chatRoom: ChatRoom
    @EnvironmentObject var session: SessionViewModel
    @State private var messages: [ChatMessage] = []
    @State private var newMessageText: String = ""
    
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private let db = Firestore.firestore()

    var body: some View {
        ZStack {
            (chatRoom.flagged ? Color.red.opacity(0.08) : Color("AppBackground"))
                .ignoresSafeArea()

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
                                    if chatType == "ai" {
                                        MessageBubble(
                                            message: msg,
                                            isCurrentUser: !(msg.sender == "AI")
                                        )
                                    } else {
                                        MessageBubble(
                                            message: msg,
                                            isCurrentUser: msg.sender == session.user?.uid
                                        )
                                    }
                                }

                                Color.clear
                                    .frame(height: 1)
                                    .id("BOTTOM")
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                        }
                        .onAppear {
                            DispatchQueue.main.async {
                                proxy.scrollTo("BOTTOM", anchor: .bottom)
                            }
                        }
                        .onChange(of: messages.count) { _ in
                            DispatchQueue.main.async {
                                withAnimation {
                                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                                }
                            }
                        }
                    }
                    .id(chatRoom.id)
                }
                if !(session.user?.role == "therapist" && chatType == "ai") {
                    if !chatRoom.flagged {
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
                } else {
                        if chatRoom.flagged {
                            if session.user?.role == "therapist" {
                            Button {
                                removeFlag()
                            } label: {
                                Label("Remove Flag", systemImage: "flag.slash")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundStyle(Color.red)
                                    .background(Color.red.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                            }
                        }
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
            Text(errorMessage)
        }
        .navigationTitle(chatRoom.clientName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            listenToMessages()
            MARKASREAD()
        }
    }
    
    private func removeFlag() {
            let db = Firestore.firestore()
            db.collection("ai_chats")
            .document(chatRoom.id)
                .updateData([
                    "flagged": false
                ]) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    } else {
                        errorMessage = "Flag Removed"
                        showSuccessAlert = true
                        chatRoom.flagged = false
                    }
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
        let text = newMessageText
        if chatType == "ai" {
        let text = newMessageText
        newMessageText = ""

    // CHANGED (Joey): CHECKFORFLAG is now async — it queries callAndResponse,
    // finds the matching category, and returns the flag status + preloaded response.
    // the user's message is saved inside the completion so we have the flag value first.
    CHECKFORFLAG(text) { isFlagged, severity, matchedResponse in

        // CHANGED (Joey): flagged and riskscore now come from the actual
        // callAndResponse severity instead of being hardcoded
        let riskscore: Int
        switch severity {
        case "critical": riskscore = 3
        case "high":     riskscore = 2
        case "medium":   riskscore = 1
        default:         riskscore = 0
        }

        db.collection("ai_chats").document(uid).collection("messages")
            .document().setData([
                "content":   text,
                "sender":    uid,
                "flagged":   isFlagged,       // CHANGED (Joey): was hardcoded false
                "riskscore": riskscore,        // CHANGED (Joey): was hardcoded 0
                "timestamp": Timestamp(),
                "read":      false
        ]) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                return
            } else {
                // CHANGED (Joey): pass the preloaded response directly
                if !isFlagged {
                    SENDAIPROMPT(responseText: matchedResponse)
                } else {
                    SENDFLAGGEDAIPROMPT()
                    
                }
                
            }
        }

        db.collection("ai_chats").document(uid)
            .updateData([
                "lastMessage":   text,
                "sender":        uid,
                "lastMessageAt": Timestamp(),
                "read":          false,
                "flagged":   isFlagged
        ]) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                return
            }
        }
    }
}
        if chatType == "clients" {
            newMessageText = ""
            db.collection("therapist_chats").document(uid).collection("messages")
                .document().setData([
                    "content": text,
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
                    "lastMessage": text,
                    "sender": uid,
                    "lastMessageAt": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                } else {

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
        let text = newMessageText
        
        
        if chatType == "providers" {
            newMessageText = ""
            db.collection("provider_chats").document(chatRoom.id).collection("messages")
                .document().setData([
                    "content": text,
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
                    "lastMessage": text,
                    "sender": uid,
                    "lastMessageAt": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                } else {
                    
                }
            }
        }
        if chatType == "clients" {
            newMessageText = ""
            db.collection("therapist_chats").document(chatRoom.id).collection("messages")
                .document().setData([
                    "content": text,
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
                    "lastMessage": text,
                    "sender": uid,
                    "lastMessageAt": Timestamp(),
                    "read": false
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    return
                } else {
                    
                }
            }
        }
    }
    
// CHANGED (Joey): CHECKFORFLAG now queries the callAndResponse collection to find
// a matching keyword category. Returns via completion handler because the Firestore
// query is async. provides:
//   - isFlagged: Bool (true if severity is "high" or "critical")
//   - severity: String 
//   - matchedResponse: String (the preloaded response)
private func CHECKFORFLAG(_ text: String, completion: @escaping (Bool, String, String) -> Void) {
    let lowered = text.lowercased()

    db.collection("callAndResponse")
        .getDocuments { snapshot, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                return
            }

            guard let docs = snapshot?.documents else { return }

            // ADDED (Joey): track the fallback doc ("no-keywords-found") separately
            var fallbackResponse = "I'm here to listen. What's on your mind today?"
            var fallbackSeverity = "none"

            // ADDED (Joey): iterate through each callAndResponse document
            // looking for a keyword match in the user's message
            for doc in docs {
                let data = doc.data()

                // Handle the fallback/default document
                if doc.documentID == "no-keywords-found" {
                    fallbackResponse = data["response"] as? String ?? fallbackResponse
                    fallbackSeverity = data["severity"] as? String ?? "none"
                    continue
                }

                // ADDED (Joey): the collection uses both "keywords" (plural) and
                // "keyword" (singular) as field names across different documents,
                // so we check for both
                let keywords: [String]
                if let kw = data["keywords"] as? [String] {
                    keywords = kw
                } else if let kw = data["keyword"] as? [String] {
                    keywords = kw
                } else {
                    continue
                }

                // ADDED (Joey): check if any keyword from this doc appears in the message
                for keyword in keywords {
                    if keyword.isEmpty { continue }
                    if lowered.contains(keyword.lowercased()) {
                        let severity = data["severity"] as? String ?? "none"
                        let response = data["response"] as? String ?? fallbackResponse
                        let isFlagged = (severity == "high" || severity == "critical")

                        // ADDED (Joey): if flagged, write to the "flags" collection
                        // so the therapist dashboard can surface it
                        if isFlagged, let uid = session.user?.uid {
                            db.collection("flags").addDocument(data: [
                                "patientId": uid,
                                "source":    "ai_chat",
                                "category":  data["category"] as? String ?? "unknown",
                                "keyword":   keyword,
                                "content":   text,
                                "severity":  severity,
                                "timestamp": Timestamp(),
                                "resolved":  false
                            ])
                        }

                        completion(isFlagged, severity, response)
                        return  // stop at first match
                    }
                }
            }

            // ADDED (Joey): no keyword matched — use the fallback document
            let isFlagged = (fallbackSeverity == "high" || fallbackSeverity == "critical")
            completion(isFlagged, fallbackSeverity, fallbackResponse)
        }
}
    
// CHANGED (Joey): SENDAIPROMPT no longer queries callAndResponse itself.
// It receives the preloaded response from CHECKFORFLAG and saves it as
// an AI message in the conversation.
    private func SENDAIPROMPT(responseText: String) {
        guard let uid = session.user?.uid else { return }
    
        // ADDED (Joey): save the preloaded response as a new AI message
        let aiMessageData: [String: Any] = [
            "content":   responseText,
            "sender":    "AI",
            "flagged":   false,
            "riskscore": 0,
            "timestamp": Timestamp(),
            "read":      false
        ]

    db.collection("ai_chats")
        .document(uid)
        .collection("messages")
        .addDocument(data: aiMessageData) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                }
            }

    // ADDED (Joey): update chat room metadata so the chat list
    // shows the AI's reply as the most recent message
    db.collection("ai_chats")
        .document(uid)
        .updateData([
            "lastMessage":   responseText,
            "sender":        "AI",
            "lastMessageAt": Timestamp(),
            "read":          false,
            "flagged": false
            ])
    }
    
    private func SENDFLAGGEDAIPROMPT() {
        guard let uid = session.user?.uid else { return }
        let flaggedResponse = "This chat has been flagged for possible harmful phrasing. Your therapist will contact you shortly. Chat is temporarily disabled."
        // ADDED (Joey): save the preloaded response as a new AI message
        let aiMessageData: [String: Any] = [
            "content":   flaggedResponse,
            "sender":    "AI",
            "flagged":   false,
            "riskscore": 0,
            "timestamp": Timestamp(),
            "read":      false
        ]

    db.collection("ai_chats")
        .document(uid)
        .collection("messages")
        .addDocument(data: aiMessageData) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                }
            }

    // ADDED (Joey): update chat room metadata so the chat list
    // shows the AI's reply as the most recent message
    db.collection("ai_chats")
        .document(uid)
        .updateData([
            "lastMessage":   flaggedResponse,
            "sender":        "AI",
            "lastMessageAt": Timestamp(),
            "read":          false,
            "flagged": true
            ])
    }
    
    private func MARKASREAD() {
        let db = Firestore.firestore()
        
        let uid = session.user?.uid ?? ""
        if !chatRoom.read && !(chatRoom.sender == uid) {
            if session.user?.role == "patient" {
                if chatType == "ai" {
                    db.collection("ai_chats").document(uid)
                        .updateData([
                            "read": true
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
                    db.collection("therapist_chats").document(uid)
                        .updateData([
                            "read": true
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
            } else {
                if chatType == "clients" {
                    db.collection("therapist_chats").document(chatRoom.id)
                        .updateData([
                            "read": true
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
                if chatType == "providers" {
                    db.collection("provider_chats").document(chatRoom.id)
                        .updateData([
                            "read": true
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

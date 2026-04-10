import SwiftUI

struct TherapistChatOptionsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    
                    NavigationLink(destination: TherapistChatsView(chatType: "clients")) {
                        ChatOptionCard(title: "Clients")
                    }

                    NavigationLink(destination: TherapistChatsView(chatType: "providers")) {
                        ChatOptionCard(title: "Providers")
                    }

                    NavigationLink(destination: TherapistChatsView(chatType: "ai")) {
                        ChatOptionCard(title: "AI Chats")
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChatOptionCard: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

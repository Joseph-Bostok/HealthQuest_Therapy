//
//  HomePageView.swift
//  healthQuest
//
//  Homepage with role-aware content
//  Lives inside TabView — no NavigationStack wrapper here (NavigationBarView provides it per-tab)
//  Cameron
//

import SwiftUI
import FirebaseFirestore


struct PatientSummary {
    var recentMood: String = "😐"
    var streakDays: Int = 0
    var weeklyEntries: Int = 0
}


struct TherapistSummary {
    var clients: Int = 0
    var unread: Int = 0
    var reviews: Int = 0
    var avgRating: Double = 0.0
    var flags: Int = 0 // new flag added (joey)
}


struct HomePageView: View {

    @EnvironmentObject var session: SessionViewModel

    @State private var summary = PatientSummary()
    @State private var summary2 = TherapistSummary()
    @State private var isLoadingStats = true

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerCard
                        if session.user?.role == "patient" {
                            patientContent
                        } else {
                            therapistContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if session.user?.role == "patient" { loadPatientStats() }
                if session.user?.role == "therapist" { loadTherapistStats() }
            }
        }
    }


    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(timeGreeting())
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if session.user?.role == "patient" {
                Text("Hello, \(session.user?.firstName ?? "")! 👋")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(Color("AccentColor"))
            } else {
                Text("Hello, Dr. \(session.user?.lastName ?? "")! 👋")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(Color("AccentColor"))
            }
            Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }


    private var patientContent: some View {
        VStack(spacing: 20) {
            HStack(spacing: 14) {
                statCard(icon: "flame.fill",    iconColor: .orange,           value: "\(summary.streakDays)",   label: "Day Streak")
                statCard(icon: "book.fill",     iconColor: Color("AccentColor"), value: "\(summary.weeklyEntries)", label: "This Week")
                statCard(icon: "face.smiling",  iconColor: .yellow,           value: summary.recentMood,        label: "Last Mood")
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundStyle(Color("AccentColor"))

                HStack(spacing: 12) {
                    NavigationLink(destination: PatientChatsView()) {
                        quickActionCard(icon: "bubble.left.and.bubble.right.fill", title: "Active Chats", subtitle: "View conversations", color: Color("AccentColor"))
                    }
                    NavigationLink(destination: JournalView(patientId: session.user?.uid)) {
                        quickActionCard(icon: "books.vertical.fill",       title: "My Journal", subtitle: "View past entries",    color: .teal)
                    }
                }
            }

            tipCard
        }
    }


    private var therapistContent: some View {
        VStack(spacing: 20) {
            HStack(spacing: 14) {
                statCard(icon: "person.2.fill",iconColor: Color("AccentColor"),value: "\(summary2.clients)", label: "Clients")
                //TO DO JOEY: fix this so it displays accurate number of flags per user 
                //ADDED (JOEY): has live flag count, swapped icon to flag.fill
                statCard(icon: "flag.fill",     iconColor: .red,                 value: "\(summary2.flags)",   label: "Flags")
                statCard(icon: "checkmark.seal.fill", iconColor: .green,         value: "\(summary2.avgRating)", label: "Rating")
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundStyle(Color("AccentColor"))

                HStack(spacing: 12) {
                    NavigationLink(destination: TherapistChatOptionsView()) {
                        quickActionCard(icon: "bubble.left.and.bubble.right.fill", title: "Client Chats", subtitle: "View conversations", color: Color("AccentColor"))
                    }
                    NavigationLink(destination: GenerateReferralCode()) {
                        quickActionCard(icon: "person.badge.plus", title: "Add Client", subtitle: "Generate referral code", color: .teal)
                    }
                }
            }
        }
    }


    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundStyle(iconColor)
            Text(value).font(.system(.title2, design: .rounded, weight: .bold))
            Text(label).font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }


    private func quickActionCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: icon).foregroundStyle(color).font(.title3)
            }
            Spacer()
            Text(title).font(.subheadline.bold()).foregroundStyle(.primary)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }


    private var tipCard: some View {
        let tips: [(String, String)] = [
            ("lightbulb.fill", "Journaling for just 5 minutes a day can significantly improve emotional regulation over time."),
            ("moon.zzz.fill",  "Getting 7–9 hours of sleep helps consolidate memories and supports emotional health."),
            ("drop.fill",      "Staying hydrated can reduce fatigue and improve concentration throughout your day."),
            ("figure.walk",    "Even a short walk can boost your mood and reduce anxiety."),
        ]
        let tip = tips[Calendar.current.component(.day, from: Date()) % tips.count]

        return HStack(alignment: .top, spacing: 14) {
            Image(systemName: tip.0).font(.title2).foregroundStyle(Color("AccentColor")).frame(width: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text("Wellness Tip").font(.caption.bold()).foregroundStyle(Color("AccentColor"))
                Text(tip.1).font(.subheadline).foregroundStyle(.primary).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .background(Color("AccentColor").opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("AccentColor").opacity(0.25), lineWidth: 1))
    }


    private func timeGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:       return "Good evening"
        }
    }

    private func loadPatientStats() {
        guard let uid = session.user?.uid else { return }
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        db.collection("journals").document(uid)
            .collection("journalEntries")
            .whereField("date", isGreaterThan: Timestamp(date: weekAgo))
            .order(by: "date", descending: true)
            .getDocuments { snapshot, _ in
                isLoadingStats = false
                guard let docs = snapshot?.documents else { return }
                summary.weeklyEntries = docs.count
                let entries: [Date] = docs.compactMap {
                                ($0.data()["date"] as? Timestamp)?.dateValue()
                            }
                summary.streakDays = calculateStreak(from: entries)
                if let latest = docs.first {
                    let mood = latest.data()["mood"] as? String ?? "Neutral"
                    summary.recentMood = moodEmoji(mood)
                }
            }
    }
    
    private func loadTherapistStats() {
        //TO DO JOEY: load the flag value in this function (done!
        //ADDED (Joey): after fetching the patients array, we fan out one query pet patient to count
        //journal entries where flagged == true using dispatch to sync
        guard let uid = session.user?.uid else { return }
        db.collection("therapists")
            .document(uid)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data(),
                      let patients = data["patients"] as? [String] else { return }

                summary2.clients = patients.count

                // ADDED (Joey): fan-out flag counting across all patients
                var totalFlags = 0
                let group = DispatchGroup()

                for patientId in patients {
                    group.enter()
                    db.collection("journals").document(patientId)
                        .collection("journalEntries")
                        .whereField("flagged", isEqualTo: true)
                        .getDocuments { snap, _ in
                            if let docs = snap?.documents {
                                totalFlags += docs.count
                            }
                            group.leave()
                        }
                }
                //ADDED (Joey): update UI on main thread 
                group.notify(queue: .main) {
                    summary2.flags = totalFlags
                }
            }
        //load ratings (not changed)
        db.collection("reviews")
            .document(uid).collection("userReviews")
            .addSnapshotListener { snapshot, error in
                if let _ = error {
                    summary2.avgRating = 0
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    summary2.avgRating = 0
                    return
                }
                
                let ratings: [Double] = docs.compactMap { doc in
                    let data = doc.data()
                    
                    if let rating = data["rating"] as? Double {
                        return rating
                    } else if let rating = data["rating"] as? Int {
                        return Double(rating)
                    } else {
                        return nil
                    }
                }
                
                summary2.reviews = ratings.count
                
                if ratings.isEmpty {
                    summary2.avgRating = 0.0
                } else {
                    let total = ratings.reduce(0, +)
                    summary2.avgRating = total / Double(ratings.count)
                }
            }
        
    }
    
    //used chatgpt 5.3 to generate behavior for calculating streak
    private func calculateStreak(from dates: [Date]) -> Int {
        let calendar = Calendar.current

        let uniqueDays = Set(dates.map { calendar.startOfDay(for: $0) })
        let sortedDays = uniqueDays.sorted(by: >)

        guard !sortedDays.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        guard sortedDays[0] == today || sortedDays[0] == yesterday else {
            return 0
        }

        var streak = 1
        var currentDay = sortedDays[0]

        for nextDay in sortedDays.dropFirst() {
            guard let expectedPreviousDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                break
            }

            if calendar.isDate(nextDay, inSameDayAs: expectedPreviousDay) {
                streak += 1
                currentDay = nextDay
            } else if calendar.isDate(nextDay, inSameDayAs: currentDay) {
                continue
            } else {
                break
            }
        }

        return streak
    }

    private func moodEmoji(_ mood: String) -> String {
        switch mood {
        case "Terrible": return "😞"
        case "Bad":      return "😕"
        case "Good":     return "🙂"
        case "Great":    return "😄"
        default:          return "😐"
        }
    }
}

#Preview {
    HomePageView()
        .environmentObject(SessionViewModel())
}

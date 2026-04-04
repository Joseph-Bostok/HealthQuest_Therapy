//
//  JournalView.swift
//  healthQuest
//
//  Page to display all journal entries
//  JournalEntryDetailView is pushed via NavigationLink (tab bar stays visible)
//  New entry form uses .sheet (intentionally modal)
//  Cameron
//

import SwiftUI
import FirebaseFirestore

// MARK: - Journal Entry Summary Model
struct JournalEntrySummary: Identifiable {
    let id: String
    let date: Date
    let mood: String
    let moodEmoji: String
    let dailyThoughts: String
    let gratitude: String
    let waterGlasses: Int
    let sleepHours: Double
    let exerciseMinutes: Int
    let mealsEaten: Int
}

// MARK: - JournalView
struct JournalView: View {

    @EnvironmentObject var session: SessionViewModel

    @State private var entries: [JournalEntrySummary] = []
    @State private var isLoading = true
    @State private var showNewEntry = false
    @State private var searchText = ""
    @State private var selectedMoodFilter: String? = nil

    private let db = Firestore.firestore()
    private let moodFilters = ["All", "😄", "🙂", "😐", "😕", "😞"]

    var filteredEntries: [JournalEntrySummary] {
        var result = entries
        if let mood = selectedMoodFilter {
            result = result.filter { $0.moodEmoji == mood }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.dailyThoughts.localizedCaseInsensitiveContains(searchText) ||
                $0.gratitude.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                VStack(spacing: 0) {
                    moodFilterBar
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color("AppBackground"))

                    if isLoading {
                        Spacer()
                        ProgressView("Loading entries...")
                            .tint(Color("AccentColor"))
                        Spacer()
                    } else if filteredEntries.isEmpty {
                        emptyState
                    } else {
                        List(filteredEntries) { entry in
                            // NavigationLink pushes detail — tab bar stays visible
                            NavigationLink(destination: JournalEntryDetailView(entry: entry)) {
                                JournalEntryRow(entry: entry)
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .searchable(text: $searchText, prompt: "Search entries…")
                    }
                }
            }
            .navigationTitle("My Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewEntry = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .onAppear(perform: loadEntries)
            // New entry is intentionally a sheet (full modal compose experience)
            .sheet(isPresented: $showNewEntry, onDismiss: loadEntries) {
                JournalEntryView()
            }
        }
    }

    // MARK: - Mood Filter Bar
    private var moodFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(moodFilters, id: \.self) { filter in
                    let isSelected = filter == "All"
                        ? selectedMoodFilter == nil
                        : selectedMoodFilter == filter

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedMoodFilter = (filter == "All") ? nil : filter
                        }
                    } label: {
                        Text(filter)
                            .font(filter == "All" ? .caption.bold() : .body)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                isSelected
                                    ? Color("AccentColor")
                                    : Color.white.opacity(0.9)
                            )
                            .foregroundStyle(isSelected ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "book.closed")
                .font(.system(size: 70))
                .foregroundStyle(Color("AccentColor").opacity(0.35))
            Text(searchText.isEmpty ? "No entries yet" : "No results found")
                .font(.title2.bold())
            Text(searchText.isEmpty
                 ? "Tap + to write your first journal entry."
                 : "Try a different search or mood filter.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            if searchText.isEmpty {
                Button("Write First Entry") { showNewEntry = true }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("AccentColor"))
            }
            Spacer()
        }
    }

    // MARK: - Load Entries
    private func loadEntries() {
        guard let uid = session.user?.uid else { return }
        isLoading = true

        db.collection("patients").document(uid)
            .collection("journalEntries")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, _ in
                isLoading = false
                guard let docs = snapshot?.documents else { return }

                self.entries = docs.compactMap { doc in
                    let data = doc.data()
                    let moodLabel = data["mood"] as? String ?? "Neutral"
                    return JournalEntrySummary(
                        id: doc.documentID,
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        mood: moodLabel,
                        moodEmoji: emojiFor(moodLabel),
                        dailyThoughts: data["dailyThoughts"] as? String ?? "",
                        gratitude: data["gratitude"] as? String ?? "",
                        waterGlasses: data["waterGlasses"] as? Int ?? 0,
                        sleepHours: data["sleepHours"] as? Double ?? 0,
                        exerciseMinutes: data["exerciseMinutes"] as? Int ?? 0,
                        mealsEaten: data["mealsEaten"] as? Int ?? 0
                    )
                }
            }
    }

    private func emojiFor(_ mood: String) -> String {
        switch mood {
        case "Terrible": return "😞"
        case "Bad":      return "😕"
        case "Good":     return "🙂"
        case "Great":    return "😄"
        default:          return "😐"
        }
    }
}

// MARK: - Journal Entry Row
struct JournalEntryRow: View {
    let entry: JournalEntrySummary

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(entry.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption2.bold())
                    .foregroundStyle(Color("AccentColor"))
                Text(entry.date.formatted(.dateTime.day()))
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .frame(width: 42)

            Divider().frame(height: 44)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(entry.date.formatted(.dateTime.weekday(.wide)))
                        .font(.subheadline.bold())
                    Spacer()
                    Text(entry.moodEmoji)
                        .font(.title3)
                }
                if !entry.dailyThoughts.isEmpty {
                    Text(entry.dailyThoughts)
                        .lineLimit(2)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Journal Entry Detail View
// Pushed via NavigationLink — tab bar remains visible at the bottom
struct JournalEntryDetailView: View {
    let entry: JournalEntrySummary

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                                .font(.title3.bold())
                            Text("Mood: \(entry.moodEmoji) \(entry.mood)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    if !entry.dailyThoughts.isEmpty {
                        detailCard(icon: "text.alignleft", title: "Daily Thoughts", content: entry.dailyThoughts)
                    }
                    if !entry.gratitude.isEmpty {
                        detailCard(icon: "heart.text.clipboard", title: "Gratitude", content: entry.gratitude)
                    }

                    wellnessSummary
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailCard(icon: String, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color("AccentColor"))
            Text(content)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var wellnessSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wellness Check-In")
                .font(.headline)
                .foregroundStyle(Color("AccentColor"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                wellnessTile(icon: "drop.fill",    color: .blue,   label: "Water",    value: "\(entry.waterGlasses) glasses")
                wellnessTile(icon: "moon.zzz.fill", color: .indigo, label: "Sleep",   value: String(format: "%.1f hrs", entry.sleepHours))
                wellnessTile(icon: "figure.run",   color: .orange, label: "Exercise", value: "\(entry.exerciseMinutes) min")
                wellnessTile(icon: "fork.knife",   color: .green,  label: "Meals",    value: "\(entry.mealsEaten) meals")
            }
        }
    }

    private func wellnessTile(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.subheadline.bold())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    JournalView()
        .environmentObject(SessionViewModel())
}

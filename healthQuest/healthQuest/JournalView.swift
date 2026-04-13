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


struct JournalEntrySummary: Identifiable, Hashable {
    let id: String
    let date: Date
    let mood: String
    let moodEmoji: String
    let dailyThoughts: String
    let waterGlasses: Int
    let sleepHours: Double
    let exerciseMinutes: Int
    let mealsEaten: Int
    let comments: String
    let flagged: Bool
}


struct JournalView: View {
    let patientId: String?

    @EnvironmentObject var session: SessionViewModel

    @State private var entries: [JournalEntrySummary] = []
    @State private var isLoading = true
    @State private var showNewEntry = false
    @State private var searchText = ""
    @State private var selectedMoodFilter: String? = nil
    @State private var todaysEntry: JournalEntrySummary? = nil
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
   

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
                $0.comments.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                VStack(spacing: 0) {
                   // moodFilterBar
                   //     .padding(.vertical, 10)
                   //     .padding(.horizontal)
                  //      .background(Color("AppBackground"))

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
                            NavigationLink(destination: JournalEntryDetailView(patientId: patientId, entry: entry)) {
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
            .navigationTitle("Patient Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    
                    if session.user?.role == "patient" {
                        Button {
                            guard !isLoading else { return }
                            
                            if let entry = todaysEntryIfExists() {
                                errorMessage = "Journal already created today. Edit the existing journal :)"
                                showErrorAlert = true
                                todaysEntry = entry
                            } else {
                                showNewEntry = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .onAppear(perform: loadEntries)
            .sheet(isPresented: $showNewEntry, onDismiss: loadEntries) {
                JournalEntryView()
            }
            //used chatgpt 5.3 to help with pushing to existing journal entry if entry already exists for a given day
            .navigationDestination(item: $todaysEntry) { entry in
                JournalEntryDetailView(patientId: patientId, entry: entry)
            }
        }.alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        
    }

    // MARK: - Mood Filter Bar
 //   private var moodFilterBar: some View {
 //       ScrollView(.horizontal, showsIndicators: false) {
 //           HStack(spacing: 8) {
 //               ForEach(moodFilters, id: \.self) { filter in
  //                  let isSelected = filter == "All"
  //                      ? selectedMoodFilter == nil
  //                      : selectedMoodFilter == filter
//
//Button {
        //                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
           //                 selectedMoodFilter = (filter == "All") ? nil : filter
        //                }
        //            } label: {
        //                Text(filter)
        //                    .font(filter == "All" ? .caption.bold() : .body)
       //                     .padding(.horizontal, 14)
        //                    .padding(.vertical, 7)
        //                    .background(
        //                        isSelected
             //                       ? Color("AccentColor")
               //                     : Color.white.opacity(0.9)
           //                 )
         //                   .foregroundStyle(isSelected ? .white : .primary)
       //                     .clipShape(Capsule())
     //               }
   //             }
  //          }
  //      }
  //  }

    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "book.closed")
                .font(.system(size: 70))
                .foregroundStyle(Color("AccentColor").opacity(0.35))
            Text(searchText.isEmpty ? "No entries yet" : "No results found")
                .font(.title2.bold())
            Text(searchText.isEmpty
                 ? "No Entries Found."
                 : "Try a different search or mood filter.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            if searchText.isEmpty {
                if session.user?.role == "patient" {
                    Button("Write First Entry") { showNewEntry = true }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("AccentColor"))
                }
            }
            Spacer()
        }
    }

    
    private func loadEntries() {
       
        
        isLoading = true

        db.collection("journals").document(patientId ?? "")
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
                        waterGlasses: data["waterGlasses"] as? Int ?? 0,
                        sleepHours: data["sleepHours"] as? Double ?? 0,
                        exerciseMinutes: data["exerciseMinutes"] as? Int ?? 0,
                        mealsEaten: data["mealsEaten"] as? Int ?? 0,
                        comments: data["comments"] as? String ?? "",
                        flagged: data["flagged"] as? Bool ?? false
                    )
                }
            }
        
    }
    
    private func todaysEntryIfExists() -> JournalEntrySummary? {
        let calendar = Calendar.current
        return entries.first { entry in
            calendar.isDateInToday(entry.date)
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


struct JournalEntryRow: View {
    let entry: JournalEntrySummary
    
    private var rowColor: Color {
            entry.flagged ? .red : Color("AccentColor")
        }
        
    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(entry.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption2.bold())
                    .foregroundStyle(rowColor)
                Text(entry.date.formatted(.dateTime.day()))
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .foregroundStyle(rowColor)
            }
            .frame(width: 42)

            Divider().frame(height: 44)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(entry.date.formatted(.dateTime.weekday(.wide)))
                        .font(.subheadline.bold())
                        .foregroundStyle(rowColor)
                    Spacer()
                    Text(entry.moodEmoji)
                        .font(.title3)
                }
                if !entry.dailyThoughts.isEmpty {
                    Text(entry.dailyThoughts)
                        .lineLimit(2)
                        .font(.caption)
                        .foregroundStyle(entry.flagged ? .red : .secondary)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}


// Pushed via NavigationLink — tab bar remains visible at the bottom
struct JournalEntryDetailView: View {
    let patientId: String?
    
    let entry: JournalEntrySummary
    @EnvironmentObject var session: SessionViewModel
    @State private var editableComment: String = ""
    // Error message
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    

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
                    } else {
                        detailCard(icon: "text.alignleft", title: "Daily Thoughts", content: "No journal data yet")
                    }
                    
                    if session.user?.role == "therapist" {
                        detailCardEditable(icon: "heart.text.clipboard", title: "Comments", text: $editableComment)
                    } else {
                        detailCard(
                            icon: "heart.text.clipboard",
                            title: "Comments",
                            content: editableComment.isEmpty ? "Add a comment..." : editableComment
                        )
                    }

                    wellnessSummary
                    if session.user?.role == "patient" {
                        NavigationLink(destination: JournalEntryView(entryToEdit: entry)) {
                            Text("Edit Journal")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .padding(.top, 8)
                        }
                    } else {
                        Button {
                            addComment()
                        } label: {
                            Text("Add Comment")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
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
            .onAppear() {
                
                    editableComment = entry.comments
                
            }
        }
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    private func addComment() {
        if editableComment != entry.comments {
            let db = Firestore.firestore()
            db.collection("journals")
                .document(patientId ?? "")
                .collection("journalEntries")
                .document(entry.id)
                .updateData([
                    "comments": editableComment
                ]) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    } else {
                        errorMessage = "Comment added successfully"
                        showSuccessAlert = true
                    }
                    }
            
        }
        
        
        
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
    
    private func detailCardEditable(icon: String, title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color("AccentColor"))
            TextEditor(text: text)
                .frame(minHeight: 90, maxHeight: 200)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color(red: 0.914, green: 0.941, blue: 0.918))
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
                wellnessTile(icon: "drop.fill",    color: .blue,   label: "Water",    value: "\(entry.waterGlasses) ounces")
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



//
//  JournalEntryView.swift
//  healthQuest
//
//  ID 9 – Journal page UI
//  Cameron
//

import SwiftUI

// MARK: – Mood enum
enum Mood: String, CaseIterable, Identifiable {
    //TO DO: These are not currently functional
    case terrible = "😞"
    case bad      = "😕"
    case neutral  = "😐"
    case good     = "🙂"
    case great    = "😄"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .terrible: return "Terrible"
        case .bad:      return "Bad"
        case .neutral:  return "Neutral"
        case .good:     return "Good"
        case .great:    return "Great"
        }
    }
}

// MARK: – View
struct JournalEntryView: View {

    // Journal text
    @State private var dailyThoughts:    String = ""
    @State private var gratitude:        String = ""

    // Wellness metrics
    @State private var waterGlasses:     Double = 0
    @State private var sleepHours:       Double = 7
    @State private var exerciseMinutes:  Double = 0
    @State private var selectedMood:     Mood   = .neutral
    @State private var mealsEaten:       Int    = 3

    // UI state
    @State private var entryDate:        Date   = Date()
    @State private var isSubmitting:     Bool   = false
    @State private var showSuccess:      Bool   = false
    @State private var showDatePicker:   Bool   = false

    // Light gray matching AppBackground-adjacent cards
    private let fieldBg = Color(red: 0.914, green: 0.941, blue: 0.918)

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        dateSelectorRow
                        journalSection(
                            icon: "text.alignleft",
                            title: "Daily Thoughts",
                            placeholder: "How are you feeling today? What's on your mind?",
                            text: $dailyThoughts
                        )
                        journalSection(
                            icon: "heart.text.clipboard",
                            title: "Gratitude",
                            placeholder: "What are you grateful for today?",
                            text: $gratitude
                        )
                        wellnessSection
                        submitButton

                        if showSuccess {
                            Label("Entry saved!", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                                .font(.footnote.bold())
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Journal Entry")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: – Date selector row
    private var dateSelectorRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    showDatePicker.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color("AccentColor"))
                    Text(entryDate.formatted(date: .long, time: .omitted))
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            if showDatePicker {
                DatePicker(
                    "Entry Date",
                    selection: $entryDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color("AccentColor"))
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: – Journal text section
    @ViewBuilder
    private func journalSection(
        icon: String,
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color("AccentColor"))

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(Color(.placeholderText))
                        .font(.body)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                        .allowsHitTesting(false)
                }
                TextEditor(text: text)
                    .frame(minHeight: 110, maxHeight: 200)
                    .scrollContentBackground(.hidden)
                    .padding(6)
            }
            .background(fieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Text("\(text.wrappedValue.count) characters")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: – Wellness section
    private var wellnessSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wellness Check-In")
                .font(.headline)
                .foregroundStyle(Color("AccentColor"))

            VStack(spacing: 18) {

                // Mood picker
                VStack(alignment: .leading, spacing: 8) {
                    Label("Mood", systemImage: "face.smiling")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color("AccentColor"))

                    HStack(spacing: 0) {
                        ForEach(Mood.allCases) { mood in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    selectedMood = mood
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(mood.rawValue).font(.title2)
                                    Text(mood.label)
                                        .font(.caption2)
                                        .foregroundStyle(
                                            selectedMood == mood
                                            ? Color("AccentColor") : .secondary
                                        )
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    selectedMood == mood
                                    ? Color("AccentColor").opacity(0.12) : fieldBg
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            selectedMood == mood
                                            ? Color("AccentColor") : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                                .scaleEffect(selectedMood == mood ? 1.08 : 1)
                            }
                        }
                    }
                }

                Divider()

                // Water
                metricSlider(
                    icon: "drop.fill",
                    iconColor: .blue,
                    title: "Water",
                    value: $waterGlasses,
                    range: 0...12,
                    step: 1,
                    format: { "\(Int($0)) glass\(Int($0) == 1 ? "" : "es")" }
                )

                Divider()

                // Sleep
                metricSlider(
                    icon: "moon.zzz.fill",
                    iconColor: .indigo,
                    title: "Sleep",
                    value: $sleepHours,
                    range: 0...12,
                    step: 0.5,
                    format: { String(format: "%.1f hr%@", $0, $0 == 1 ? "" : "s") }
                )

                Divider()

                // Exercise
                metricSlider(
                    icon: "figure.run",
                    iconColor: .orange,
                    title: "Exercise",
                    value: $exerciseMinutes,
                    range: 0...120,
                    step: 5,
                    format: { "\(Int($0)) min" }
                )

                Divider()

                // Meals eaten
                VStack(alignment: .leading, spacing: 8) {
                    Label("Meals Eaten", systemImage: "fork.knife")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.green)

                    HStack(spacing: 8) {
                        ForEach(0...6, id: \.self) { count in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                                    mealsEaten = count
                                }
                            } label: {
                                Text("\(count)")
                                    .font(.system(.body, design: .rounded, weight: .semibold))
                                    .frame(maxWidth: .infinity, minHeight: 36)
                                    .background(
                                        mealsEaten == count
                                        ? Color("AccentColor") : fieldBg
                                    )
                                    .foregroundStyle(
                                        mealsEaten == count ? .white : .primary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                mealsEaten == count
                                                ? Color("AccentColor") : Color.clear,
                                                lineWidth: 1.5
                                            )
                                    )
                                    .scaleEffect(mealsEaten == count ? 1.08 : 1)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: – Metric slider helper
    @ViewBuilder
    private func metricSlider(
        icon: String,
        iconColor: Color,
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        format: @escaping (Double) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(iconColor)
                Spacer()
                Text(format(value.wrappedValue))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color("AccentColor"))
            }
            Slider(value: value, in: range, step: step)
                .tint(Color("AccentColor"))
        }
    }

    // MARK: – Submit button
    private var submitButton: some View {
        Button { submitEntry() } label: {
            Group {
                if isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Label("Submit Entry", systemImage: "paperplane.fill")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("AccentColor"))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isSubmitting)
    }

    // MARK: – Submit
    private func submitEntry() {
        isSubmitting = true

        // TODO (Lauren): pass to Firestore
        let entryData: [String: Any] = [
            "date":            entryDate,
            "dailyThoughts":   dailyThoughts,
            "gratitude":       gratitude,
            "mood":            selectedMood.label,
            "waterGlasses":    Int(waterGlasses),
            "sleepHours":      sleepHours,
            "exerciseMinutes": Int(exerciseMinutes),
            "mealsEaten":      mealsEaten
            // TODO (Lauren): add therapist comments as an array
        ]
        print("📓 Entry ready:", entryData)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSubmitting = false
            withAnimation { showSuccess = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { showSuccess = false }
            }
        }
    }
}

#Preview { JournalEntryView() }

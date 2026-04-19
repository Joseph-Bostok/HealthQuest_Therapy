//
//  verifyClientJournalEntry.swift
//  healthQuestUITests
//
//  Created by Alexander Mesa on 4/16/26.
//  Codex AI Generated This Code from reading these test cases in Test Cases Doc file: Client Submitting and Editing Journal

// Precondition: Make sure there aren't any journal entries of that client from today
// Condition: Run testJournalSubmit() before testJournalEdit()

import XCTest

// Note: Swift UI struggles to scroll to the right value, so buttons were added only in this test instance to choose the right values in the journal entries
final class verifyClientJournalEntry: XCTestCase {

    private let patientEmail = "patient@gmail.com"
    private let patientPassword = "123456"

    private let journalThoughts = "I ran 5 miles."
    private let updatedSleepDisplay = "8.5 hrs"
    private let initialSleepDisplay = "8.0 hrs"
    private let waterDisplay = "64 ounces"
    private let exerciseDisplay = "60 min"
    private let mealsDisplay = "3 meals"
    private let goodMoodEmoji = "🙂"
    private let greatMoodEmoji = "😄"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeTab() throws {
        let app = makeApp()
        app.launch()

        loginAsPatient(app)
        openTab("Home", app: app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Day Streak"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["This Week"].exists)
        XCTAssertTrue(app.staticTexts["Last Mood"].exists)
        XCTAssertTrue(app.staticTexts["Active Chats"].exists)
        XCTAssertTrue(app.staticTexts["My Journal"].exists)
        XCTAssertTrue(app.staticTexts["Wellness Tip"].exists)
    }

    func testJournalSubmit() throws {
        let app = makeApp()
        app.launch()

        loginAsPatient(app)
        openTab("Home", app: app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        let initialDayStreak = try XCTUnwrap(homeStatValue(for: "Day Streak", app: app))
        let initialThisWeek = try XCTUnwrap(homeStatValue(for: "This Week", app: app))

        openTab("Journals", app: app)

        XCTAssertTrue(app.navigationBars["Patient Journal"].waitForExistence(timeout: 5))
        openNewJournalEntry(app)
        assertJournalEntryFormIsVisible(app)

        populateJournalForm(
            app,
            thoughts: journalThoughts,
            mood: "Good",
            waterOunces: 64,
            sleepHours: 8.0,
            exerciseMinutes: 60,
            mealsEaten: 3
        )
        submitJournalEntry(app)

        XCTAssertTrue(app.navigationBars["Patient Journal"].waitForExistence(timeout: 5))
        openMostRecentJournalEntry(app)
        assertJournalDetail(app, expectedMoodLine: "Mood: \(goodMoodEmoji) Good", expectedSleep: initialSleepDisplay)

        tapBackButton(app)
        openTab("Home", app: app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        let updatedDayStreak = try XCTUnwrap(homeStatValue(for: "Day Streak", app: app))
        let updatedThisWeek = try XCTUnwrap(homeStatValue(for: "This Week", app: app))
        XCTAssertEqual(updatedDayStreak, initialDayStreak + 1, "Day Streak should increase by one after submitting a journal entry")
        XCTAssertEqual(updatedThisWeek, initialThisWeek + 1, "This Week should increase by one after submitting a journal entry")
        XCTAssertEqual(homeMoodValue(app), goodMoodEmoji, "Last Mood should match the most recent journal mood")

        logOut(app)
        assertLoginScreen(app)
    }

    func testJournalEdit() throws {
        let app = makeApp()
        app.launch()

        loginAsPatient(app)
        openTab("Home", app: app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        let initialDayStreak = try XCTUnwrap(homeStatValue(for: "Day Streak", app: app))
        let initialThisWeek = try XCTUnwrap(homeStatValue(for: "This Week", app: app))

        prepareTodaysJournalEntryForEditing(app)

        XCTAssertTrue(app.navigationBars["Journal Entry"].waitForExistence(timeout: 5))
        populateJournalForm(
            app,
            thoughts: nil,
            mood: "Great",
            waterOunces: 64,
            sleepHours: 8.5,
            exerciseMinutes: 60,
            mealsEaten: 3
        )
        submitJournalEntry(app)

        XCTAssertTrue(app.navigationBars["Journal Entry"].waitForExistence(timeout: 5))
        
        assertJournalDetail(app, expectedMoodLine: "Mood: \(greatMoodEmoji) Great", expectedSleep: updatedSleepDisplay)

        tapBackButton(app)
        XCTAssertTrue(app.navigationBars["Patient Journal"].waitForExistence(timeout: 5))
        openMostRecentJournalEntry(app)
        assertJournalDetail(app, expectedMoodLine: "Mood: \(greatMoodEmoji) Great", expectedSleep: updatedSleepDisplay)

        tapBackButton(app)
        openTab("Home", app: app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        let updatedDayStreak = try XCTUnwrap(homeStatValue(for: "Day Streak", app: app))
        let updatedThisWeek = try XCTUnwrap(homeStatValue(for: "This Week", app: app))
        XCTAssertEqual(updatedDayStreak, initialDayStreak, "Day Streak should not change after editing an existing journal entry")
        XCTAssertEqual(updatedThisWeek, initialThisWeek, "This Week should not change after editing an existing journal entry")
        XCTAssertTrue(app.staticTexts["Last Mood"].exists)
        XCTAssertEqual(homeMoodValue(app), greatMoodEmoji, "Last Mood should match the most recent journal mood")

        logOut(app)
        assertLoginScreen(app)
    }

    private func loginAsPatient(_ app: XCUIApplication) {
        if app.tabBars.firstMatch.waitForExistence(timeout: 5) {
            return
        }

        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 15), "Email field not found")
        emailField.tap()
        emailField.typeText(patientEmail)

        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5), "Password field not found")
        passwordField.tap()
        passwordField.typeText(patientPassword)

        let loginButton = app.buttons["Log In"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Log In button not found")
        loginButton.tap()
        
        dismissSavePasswordPromptIfNeeded(app)

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15), "Tab bar did not appear after login")
    }

    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("UI-TESTING")
        return app
    }

    private func openTab(_ name: String, app: XCUIApplication) {
        let tab = app.tabBars.buttons[name]
        XCTAssertTrue(tab.waitForExistence(timeout: 5), "\(name) tab not found")
        tab.tap()
    }

    private func openNewJournalEntry(_ app: XCUIApplication) {
        let plusButton = app.buttons["plus"]
        let writeFirstEntryButton = app.buttons["Write First Entry"]

        if plusButton.waitForExistence(timeout: 5) {
            plusButton.tap()
        } else {
            XCTAssertTrue(writeFirstEntryButton.waitForExistence(timeout: 5), "Journal creation control not found")
            writeFirstEntryButton.tap()
        }
    }

    private func assertJournalEntryFormIsVisible(_ app: XCUIApplication) {
        XCTAssertTrue(app.navigationBars["Journal Entry"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Daily Thoughts"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Therapist Comments"].exists)
        XCTAssertTrue(app.staticTexts["Wellness Check-In"].exists)
        XCTAssertTrue(app.staticTexts["Mood"].exists)
        XCTAssertTrue(app.staticTexts["Water"].exists)
        XCTAssertTrue(app.staticTexts["Sleep"].exists)
        XCTAssertTrue(app.staticTexts["Exercise"].exists)
        XCTAssertTrue(app.staticTexts["Meals Eaten"].exists)
        XCTAssertTrue(app.buttons["Submit Entry"].exists)
    }

    private func populateJournalForm(
        _ app: XCUIApplication,
        thoughts: String?,
        mood: String,
        waterOunces: Int,
        sleepHours: Double,
        exerciseMinutes: Int,
        mealsEaten: Int
    ) {
        if let thoughts {
            let thoughtsEditor = app.textViews["dailyThoughtsEditor"]
            scrollToElement(thoughtsEditor, in: app)
            XCTAssertTrue(thoughtsEditor.waitForExistence(timeout: 5), "Daily thoughts editor not found")
            replaceText(in: thoughtsEditor, with: thoughts)
        }

        let moodButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", mood)).firstMatch
        scrollToElement(moodButton, in: app)
        XCTAssertTrue(moodButton.waitForExistence(timeout: 5), "\(mood) mood button not found")
        moodButton.tap()

        let waterSlider = app.sliders["waterSlider"]
        scrollToElement(waterSlider, in: app)
        XCTAssertTrue(waterSlider.waitForExistence(timeout: 5), "Water slider not found")
        setMetricValue(
            app,
            slider: waterSlider,
            valueLabel: app.staticTexts["waterValue"],
            targetValue: Double(waterOunces),
            decrementButton: app.buttons["waterDecrement"],
            incrementButton: app.buttons["waterIncrement"],
            maxValue: 128,
            step: 1,
            expectedLabel: "\(waterOunces) ounces"
        )

        let sleepSlider = app.sliders["sleepSlider"]
        scrollToElement(sleepSlider, in: app)
        XCTAssertTrue(sleepSlider.waitForExistence(timeout: 5), "Sleep slider not found")
        setMetricValue(
            app,
            slider: sleepSlider,
            valueLabel: app.staticTexts["sleepValue"],
            targetValue: sleepHours,
            decrementButton: app.buttons["sleepDecrement"],
            incrementButton: app.buttons["sleepIncrement"],
            maxValue: 24.0,
            step: 0.5,
            expectedLabel: String(format: "%.1f hrs", sleepHours)
        )

        let exerciseSlider = app.sliders["exerciseSlider"]
        scrollToElement(exerciseSlider, in: app)
        XCTAssertTrue(exerciseSlider.waitForExistence(timeout: 5), "Exercise slider not found")
        setMetricValue(
            app,
            slider: exerciseSlider,
            valueLabel: app.staticTexts["exerciseValue"],
            targetValue: Double(exerciseMinutes),
            decrementButton: app.buttons["exerciseDecrement"],
            incrementButton: app.buttons["exerciseIncrement"],
            maxValue: 240,
            step: 5,
            expectedLabel: "\(exerciseMinutes) min"
        )

        let mealsButton = app.buttons["\(mealsEaten)"]
        scrollToElement(mealsButton, in: app)
        XCTAssertTrue(mealsButton.waitForExistence(timeout: 5), "Meals button for \(mealsEaten) not found")
        mealsButton.tap()

        XCTAssertTrue(app.staticTexts["\(waterOunces) ounces"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["\(exerciseMinutes) min"].exists)
    }

    private func submitJournalEntry(_ app: XCUIApplication) {
        let submitButton = app.buttons["Submit Entry"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 5), "Submit Entry button not found")
        submitButton.tap()
        XCTAssertTrue(app.staticTexts["Entry saved!"].waitForExistence(timeout: 10))
    }

    private func openMostRecentJournalEntry(_ app: XCUIApplication) {
        let row = app.descendants(matching: .cell).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), "No journal entry row found")
        row.tap()
        XCTAssertTrue(app.navigationBars["Journal Entry"].waitForExistence(timeout: 5))
    }

    private func assertJournalDetail(_ app: XCUIApplication, expectedMoodLine: String, expectedSleep: String) {
        XCTAssertTrue(app.navigationBars["Journal Entry"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[journalThoughts].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[expectedMoodLine].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[waterDisplay].exists)
        XCTAssertTrue(app.staticTexts[expectedSleep].exists)
        XCTAssertTrue(app.staticTexts[exerciseDisplay].exists)
        XCTAssertTrue(app.staticTexts[mealsDisplay].exists)
        XCTAssertTrue(app.buttons["Edit Journal"].exists)
    }

    private func prepareTodaysJournalEntryForEditing(_ app: XCUIApplication) {
        openTab("Journals", app: app)
        XCTAssertTrue(app.navigationBars["Patient Journal"].waitForExistence(timeout: 5))

        openMostRecentJournalEntry(app)
        XCTAssertTrue(app.buttons["Edit Journal"].waitForExistence(timeout: 5))
        app.buttons["Edit Journal"].tap()
        assertJournalEntryFormIsVisible(app)
    }

    private func tapBackButton(_ app: XCUIApplication) {
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button not found")
        backButton.tap()
    }

    private func replaceText(in element: XCUIElement, with text: String) {
        element.tap()

        if let currentValue = element.value as? String, !currentValue.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            element.typeText(deleteString)
        }

        element.typeText(text)
    }

    private func homeStatValue(for label: String, app: XCUIApplication) -> Int? {
        let labelElement = app.staticTexts[label]
        guard labelElement.waitForExistence(timeout: 5) else { return nil }

        let labelFrame = labelElement.frame
        let candidates = app.staticTexts.allElementsBoundByIndex.compactMap { element -> (XCUIElement, Int)? in
            guard element.exists,
                  let text = element.label.split(separator: "\n").first.map(String.init),
                  let value = Int(text)
            else {
                return nil
            }

            let frame = element.frame
            let isAboveLabel = frame.maxY <= labelFrame.minY + 12
            let isSameColumn = abs(frame.midX - labelFrame.midX) < max(labelFrame.width, 80)
            return (isAboveLabel && isSameColumn) ? (element, value) : nil
        }

        return candidates
            .sorted { $0.0.frame.maxY > $1.0.frame.maxY }
            .first?
            .1
    }

    private func homeMoodValue(_ app: XCUIApplication) -> String? {
        let labelElement = app.staticTexts["Last Mood"]
        guard labelElement.waitForExistence(timeout: 5) else { return nil }

        let labelFrame = labelElement.frame
        let emojiCandidates = app.staticTexts.allElementsBoundByIndex.compactMap { element -> String? in
            guard element.exists else { return nil }

            let text = element.label.trimmingCharacters(in: .whitespacesAndNewlines)
            guard text.count <= 4, text != "Last Mood" else { return nil }

            let frame = element.frame
            let isAboveLabel = frame.maxY <= labelFrame.minY + 12
            let isSameColumn = abs(frame.midX - labelFrame.midX) < max(labelFrame.width, 80)
            return (isAboveLabel && isSameColumn) ? text : nil
        }

        return emojiCandidates.first
    }

    private func normalizedSliderPosition(for value: Double, maxValue: Double) -> CGFloat {
        CGFloat(value / maxValue)
    }

    private func setMetricValue(
        _ app: XCUIApplication,
        slider: XCUIElement,
        valueLabel: XCUIElement,
        targetValue: Double,
        decrementButton: XCUIElement,
        incrementButton: XCUIElement,
        maxValue: Double,
        step: Double,
        expectedLabel: String,
        maxAttempts: Int = 80
    ) {
        XCTAssertTrue(valueLabel.waitForExistence(timeout: 5), "Slider value label not found for \(slider.identifier)")

        slider.adjust(toNormalizedSliderPosition: normalizedSliderPosition(for: targetValue, maxValue: maxValue))

        for _ in 0..<maxAttempts {
            let settledLabel = settledSliderLabel(for: valueLabel)

            if settledLabel == expectedLabel {
                return
            }

            guard let currentValue = numericValue(from: settledLabel) else { break }
            let delta = targetValue - currentValue

            if abs(delta) < 0.01 {
                return
            }

            if decrementButton.exists && incrementButton.exists {
                let button = delta.sign == .minus ? decrementButton : incrementButton
                scrollToElement(button, in: app)
                button.tap()
            } else {
                let nextValue = currentValue + (delta.sign == .minus ? -step : step)
                moveSlider(
                    slider,
                    fromValue: currentValue,
                    toValue: nextValue,
                    maxValue: maxValue
                )
            }
        }

        XCTAssertEqual(settledSliderLabel(for: valueLabel), expectedLabel, "Slider \(slider.identifier) did not settle on \(expectedLabel)")
    }

    private func numericValue(from label: String) -> Double? {
        let allowedCharacters = Set("0123456789.")
        let numericPortion = String(label.filter { allowedCharacters.contains($0) })
        return Double(numericPortion)
    }

    private func settledSliderLabel(for valueLabel: XCUIElement, polls: Int = 8, interval: TimeInterval = 0.2) -> String {
        var currentLabel = valueLabel.label

        for _ in 0..<polls {
            RunLoop.current.run(until: Date().addingTimeInterval(interval))
            let updatedLabel = valueLabel.label

            if updatedLabel == currentLabel {
                return updatedLabel
            }

            currentLabel = updatedLabel
        }

        return currentLabel
    }

    private func moveSlider(
        _ slider: XCUIElement,
        fromValue currentValue: Double,
        toValue value: Double,
        maxValue: Double
    ) {
        let currentPosition = normalizedSliderPosition(for: currentValue, maxValue: maxValue)
        let targetPosition = normalizedSliderPosition(for: min(max(value, 0), maxValue), maxValue: maxValue)

        let start = slider.coordinate(withNormalizedOffset: CGVector(dx: currentPosition, dy: 0.5))
        let end = slider.coordinate(withNormalizedOffset: CGVector(dx: targetPosition, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 6) {
        if element.exists && element.isHittable {
            return
        }

        for _ in 0..<maxSwipes {
            app.swipeUp()
            if element.exists && element.isHittable {
                return
            }
        }

        for _ in 0..<maxSwipes {
            app.swipeDown()
            if element.exists && element.isHittable {
                return
            }
        }
    }

    private func logOut(_ app: XCUIApplication) {
        openTab("Profile", app: app)

        let logoutButton = app.buttons["Log Out"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "Log Out button not found")
        logoutButton.tap()
    }

    private func assertLoginScreen(_ app: XCUIApplication) {
        XCTAssertTrue(app.textFields["Email"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.secureTextFields["Password"].exists)
        XCTAssertTrue(app.buttons["Log In"].exists)
    }
    
    private func dismissSavePasswordPromptIfNeeded(_ app: XCUIApplication) {
        let appNotNowButton = app.buttons["Not Now"]
        if appNotNowButton.waitForExistence(timeout: 2) {
            appNotNowButton.tap()
            return
        }

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let springboardNotNowButton = springboard.buttons["Not Now"]
        if springboardNotNowButton.waitForExistence(timeout: 2) {
            springboardNotNowButton.tap()
        }
    }
}

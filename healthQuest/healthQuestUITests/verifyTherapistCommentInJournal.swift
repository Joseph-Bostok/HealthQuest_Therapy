//
//  verifyTherapistCommentInJournal.swift
//  healthQuestUITests
//
//  Created by Alexander Mesa on 4/17/26.
//  Codex AI Generated This Code from reading these test cases in Test Cases Doc file: Therapist Adding Comment to Client Journal Entry

import XCTest

/* Preconditions:
    Run the two tests in verifyClientJournalEntry before this test
    The most recent journal entry from the client should be empty
*/

final class verifyTherapistCommentInJournal: XCTestCase {

    private let clientName = "Jane Doe"
    private let clientEmail = "patient@gmail.com"
    private let clientPassword = "123456"
    private let therapistName = "John Smith"
    private let therapistEmail = "therapy@gmail.com"
    private let therapistPassword = "123456"
    private let therapistComment = "Great Run!"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testTherapistCommentInJournal() throws {
        let app = makeApp()
        app.launch()

        login(email: therapistEmail, password: therapistPassword, app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        openTab("Patient Journals", app: app)
        
        XCTAssertTrue(app.navigationBars["My Clients"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[clientName].waitForExistence(timeout: 10))
        
        app.staticTexts[clientName].tap()
        
        XCTAssertTrue(app.navigationBars["Patient Journal"].waitForExistence(timeout: 5))
        
        // Click on the most recent journal entry then add comment
        openMostRecentJournalEntry(app)
        assertJournalDetail(app, expectsEditButton: false)
        addTherapistComment(app)

        logOut(app)
        assertLoginScreen(app)

        login(email: clientEmail, password: clientPassword, app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 10))

        openPatientJournalsTab(app)
        
        // Click on the most recent journal entry then check comment from therapist
        openMostRecentJournalEntry(app)
        assertJournalDetail(app, expectsEditButton: true)
        XCTAssertTrue(app.staticTexts[therapistComment].waitForExistence(timeout: 5))

        logOut(app)
        assertLoginScreen(app)
    }
    
    private func assertJournalDetail(_ app: XCUIApplication, expectsEditButton: Bool) {
        // Expected Journal Details of Client from Recent Journal Edit in verifyClientJournalEntry test
        let journalThoughts = "I ran 5 miles."
        let greatMoodEmoji = "😄"
        let moodLine = "Mood: \(greatMoodEmoji) Great"
        let waterDisplay = "64 ounces"
        let sleep = "8.5 hrs"
        let exerciseDisplay = "60 min"
        let mealsDisplay = "3 meals"
        
        XCTAssertTrue(app.navigationBars["Journal Entry"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[journalThoughts].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[moodLine].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[waterDisplay].exists)
        XCTAssertTrue(app.staticTexts[sleep].exists)
        XCTAssertTrue(app.staticTexts[exerciseDisplay].exists)
        XCTAssertTrue(app.staticTexts[mealsDisplay].exists)
        XCTAssertEqual(app.buttons["Edit Journal"].exists, expectsEditButton)
    }

    private func addTherapistComment(_ app: XCUIApplication) {
        let addCommentButton = app.buttons["Add Comment"]
        XCTAssertTrue(addCommentButton.waitForExistence(timeout: 5), "Add Comment button not found")

        addCommentButton.tap()
        XCTAssertFalse(app.alerts["Success"].waitForExistence(timeout: 2), "Success alert should not appear when comment box is empty")

        let commentEditor = app.textViews.firstMatch
        XCTAssertTrue(commentEditor.waitForExistence(timeout: 5), "Comment editor not found")
        commentEditor.tap()
        commentEditor.typeText(therapistComment)

        XCTAssertEqual(commentEditor.value as? String, therapistComment, "Comment text was not entered")

        addCommentButton.tap()

        let successAlert = app.alerts["Success"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 5), "Success alert did not appear after adding comment")
        XCTAssertTrue(successAlert.staticTexts["Comment added successfully"].exists)

        let okButton = successAlert.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5), "OK button not found on success alert")
        okButton.tap()
    }
    
    private func login(email: String, password: String, _ app: XCUIApplication) {
        if app.tabBars.firstMatch.waitForExistence(timeout: 5) {
            return
        }
        
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 15), "Email field not found")
        emailField.tap()
        emailField.typeText(email)

        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5), "Password field not found")
        passwordField.tap()
        passwordField.typeText(password)

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

        if tab.isHittable {
            tab.tap()
        } else {
            let coordinate = tab.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            coordinate.tap()
        }
    }

    private func openPatientJournalsTab(_ app: XCUIApplication, attempts: Int = 4) {
        let patientJournalNav = app.navigationBars["Patient Journal"]
        if patientJournalNav.exists {
            return
        }

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Tab bar not found")

        for _ in 0..<attempts {
            let journalsTab = tabBar.buttons["Journals"]
            XCTAssertTrue(journalsTab.waitForExistence(timeout: 5), "Journals tab not found")

            if journalsTab.isHittable {
                journalsTab.tap()
            } else {
                let coordinate = journalsTab.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                coordinate.tap()
            }

            if patientJournalNav.waitForExistence(timeout: 3) {
                return
            }

            let secondTabCoordinate = tabBar.coordinate(withNormalizedOffset: CGVector(dx: 0.375, dy: 0.5))
            secondTabCoordinate.tap()

            if patientJournalNav.waitForExistence(timeout: 3) {
                return
            }
        }

        XCTAssertTrue(patientJournalNav.waitForExistence(timeout: 2), "Failed to open Patient Journal tab")
    }
    
    private func openMostRecentJournalEntry(_ app: XCUIApplication) {
        let row = app.descendants(matching: .cell).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), "No journal entry row found")
        row.tap()
        XCTAssertTrue(app.navigationBars["Journal Entry"].waitForExistence(timeout: 5))
    }

    private func tapBackButton(expectedTitle: String, app: XCUIApplication) {
        let backButton = app.navigationBars[expectedTitle].buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button not found for \(expectedTitle)")
        backButton.tap()
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
}

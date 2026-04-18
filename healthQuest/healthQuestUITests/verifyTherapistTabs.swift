//
//  verifyTherapistTabs.swift
//  healthQuestUITests
//
//  Created by Alexander Mesa on 4/16/26.
//  Codex AI Generated This Code from reading these test cases in Test Cases Doc file: Verify Tabs of Therapist Profile

import XCTest

final class verifyTherapistTabs: XCTestCase {

    private let therapistEmail = "therapy@gmail.com"
    private let therapistPassword = "123456"
    private let therapistGreeting = "Hello, Dr. Smith! 👋"
    private let therapistProfileEmail = "therapy@gmail.com"
    private let knownClientName = "Jane Doe"
    private let knownProviderName = "Dr. Sharie Finch"
    private let knownProviderChatName = "Sharie Finch"
    private let knownProviderEmail = "SharieFinch@horizontherapy.com"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeTab() throws {
        let app = XCUIApplication()
        app.launch()

        loginAsTherapist(app)
        
        openTab("Home", app: app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[therapistGreeting].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Clients"].exists)
        XCTAssertTrue(app.staticTexts["Flags"].exists)
        XCTAssertTrue(app.staticTexts["Rating"].exists)
        XCTAssertTrue(app.staticTexts["Client Chats"].exists)
        XCTAssertTrue(app.staticTexts["Add Client"].exists)
    }

    func testPatientJournalsTab() throws {
        let app = XCUIApplication()
        app.launch()

        loginAsTherapist(app)
        
        openTab("Patient Journals", app: app)

        XCTAssertTrue(app.navigationBars["My Clients"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[knownClientName].waitForExistence(timeout: 10))
        
        app.staticTexts[knownClientName].tap()
        
        let backButton = app.navigationBars["Patient Journal"].buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button not found on therapist profile")
        backButton.tap()
        
        XCTAssertTrue(app.navigationBars["My Clients"].waitForExistence(timeout: 5))
    }

    func testChatsTab() throws {
        let app = XCUIApplication()
        app.launch()

        loginAsTherapist(app)

        openTab("Chats", app: app)

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Clients"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Providers"].exists)
        XCTAssertTrue(app.staticTexts["AI Chats"].exists)

        verifyChatSelection(
            "Clients",
            expectedConversationName: knownClientName,
            app: app
        )
        verifyChatSelection(
            "Providers",
            expectedConversationName: knownProviderChatName,
            app: app
        )
        verifyChatSelection(
            "AI Chats",
            expectedConversationName: knownClientName,
            app: app
        )
    }
    
    func testProvidersTab() throws {
        let app = XCUIApplication()
        app.launch()

        loginAsTherapist(app)

        openTab("Providers", app: app)

        XCTAssertTrue(app.navigationBars["Find a Therapist"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[knownProviderName].waitForExistence(timeout: 10))

        app.staticTexts[knownProviderName].tap()

        XCTAssertTrue(app.navigationBars["Therapist Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[knownProviderName].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[knownProviderEmail].exists)
        XCTAssertTrue(app.staticTexts["About"].exists)

        let backButton = app.navigationBars["Therapist Profile"].buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button not found on therapist profile")
        backButton.tap()

        XCTAssertTrue(app.navigationBars["Find a Therapist"].waitForExistence(timeout: 5))
    }

    func testProfileTab() throws {
        let app = XCUIApplication()
        app.launch()

        loginAsTherapist(app)

        openTab("Profile", app: app)

        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Email"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[therapistProfileEmail].exists)
        XCTAssertTrue(app.staticTexts["Phone"].exists)
        XCTAssertTrue(app.staticTexts["About Me"].exists)
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Log Out"].exists)

        app.buttons["Log Out"].tap()

        XCTAssertTrue(app.textFields["Email"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.secureTextFields["Password"].exists)
        XCTAssertTrue(app.buttons["Log In"].exists)
    }

    private func loginAsTherapist(_ app: XCUIApplication) {
        if app.tabBars.firstMatch.waitForExistence(timeout: 5) {
            return
        }
        
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 15), "Email field not found")
        emailField.tap()
        emailField.typeText(therapistEmail)

        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5), "Password field not found")
        passwordField.tap()
        passwordField.typeText(therapistPassword)

        let loginButton = app.buttons["Log In"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Log In button not found")
        loginButton.tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15), "Tab bar did not appear after login")
    }

    private func openTab(_ name: String, app: XCUIApplication) {
        let tab = app.tabBars.buttons[name]
        XCTAssertTrue(tab.waitForExistence(timeout: 5), "\(name) tab not found")
        tab.tap()
    }

    private func verifyChatSelection(
        _ selectionName: String,
        expectedConversationName: String,
        app: XCUIApplication
    ) {
        let selection = app.staticTexts[selectionName]
        XCTAssertTrue(selection.waitForExistence(timeout: 5), "\(selectionName) selection not found")
        selection.tap()

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["arrow.clockwise"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[expectedConversationName].waitForExistence(timeout: 10))

        app.staticTexts[expectedConversationName].tap()

        XCTAssertTrue(app.navigationBars[expectedConversationName].waitForExistence(timeout: 5))

        let backButton = app.navigationBars[expectedConversationName].buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button not found for \(selectionName) chat detail")
        backButton.tap()

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))
        
        let backButton2 = app.navigationBars["Chats"].buttons.firstMatch
        XCTAssertTrue(backButton2.waitForExistence(timeout: 5), "Back button not found for \(selectionName) chat detail")
        backButton2.tap()
        
        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))
    }
}

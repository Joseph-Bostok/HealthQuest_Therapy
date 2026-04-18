//
//  verifyClientTabs.swift
//  healthQuestUITests
//
//  Created by Alexander Mesa on 4/11/26.
// Codex AI Generated This Code
// Codex AI Prompt:
/*
 I am working on a test case to verify the client tabs in healthQuestUITests/verifyClientTabs. The tabs are: Home, Journals, Chats, Profile. In verifyClientTabs, there's a function for checking each tab. First, I need to login with patient@gmail.com email. Next, I need to check that those tabs have the right title name and elements. How can we write the code to accomplish this?
 */

import XCTest

final class verifyClientTabs: XCTestCase {

    private let patientEmail = "patient@gmail.com"
    private let patientPassword = "123456"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeTab() throws {
        let app = XCUIApplication()
        app.launch()

        loginAsPatient(app)
        
        openTab("Home", app: app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Quick Actions"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Wellness Tip"].exists)
    }

    func testJournalsTab() throws {
        let app = XCUIApplication()
        app.launch()

        loginAsPatient(app)
        
        openTab("Journals", app: app)

        XCTAssertTrue(app.navigationBars["Patient Journal"].waitForExistence(timeout: 5))

        let plusButton = app.buttons["plus"]
        let writeFirstEntryButton = app.buttons["Write First Entry"]

        XCTAssertTrue(
            plusButton.exists || writeFirstEntryButton.exists,
            "Expected journal creation control was not found"
        )
    }

    func testChatsTab() throws {
        let app = XCUIApplication()
        app.launch()
        
        loginAsPatient(app)

        openTab("Chats", app: app)

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["HealthQuest AI"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["My Therapist"].exists)
        XCTAssertTrue(app.buttons["arrow.clockwise"].exists)
    }

    func testProfileTab() throws {
        let app = XCUIApplication()
        app.launch()
        
        loginAsPatient(app)

        openTab("Profile", app: app)

        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Rate my Therapist"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Change my Therapist"].exists)
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Log Out"].exists)
        
        app.buttons["Log Out"].tap()

        XCTAssertTrue(app.textFields["Email"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.secureTextFields["Password"].exists)
        XCTAssertTrue(app.buttons["Log In"].exists)
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

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15), "Tab bar did not appear after login")
    }

    private func openTab(_ name: String, app: XCUIApplication) {
        let tab = app.tabBars.buttons[name]
        XCTAssertTrue(tab.waitForExistence(timeout: 5), "\(name) tab not found")
        tab.tap()
    }

    /*
    private func verifyHomeTab(_ app: XCUIApplication) {
        openTab("Home", app: app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Quick Actions"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Wellness Tip"].exists)
    }

    private func verifyJournalsTab(_ app: XCUIApplication) {
        openTab("Journals", app: app)

        XCTAssertTrue(app.navigationBars["Patient Journal"].waitForExistence(timeout: 5))

        let plusButton = app.buttons["plus"]
        let writeFirstEntryButton = app.buttons["Write First Entry"]

        XCTAssertTrue(
            plusButton.exists || writeFirstEntryButton.exists,
            "Expected journal creation control was not found"
        )
    }

    private func verifyChatsTab(_ app: XCUIApplication) {
        openTab("Chats", app: app)

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["arrow.clockwise"].exists)
    }

    private func verifyProfileTab(_ app: XCUIApplication) {
        openTab("Profile", app: app)

        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Rate my Therapist"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Change my Therapist"].exists)
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Log Out"].exists)
    }
    */
}

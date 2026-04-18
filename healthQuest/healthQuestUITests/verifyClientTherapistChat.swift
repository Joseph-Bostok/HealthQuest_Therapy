//
//  verifyClientTherapistChat.swift
//  healthQuestUITests
//
//  Created by Alexander Mesa on 4/17/26.
//  Codex AI Generated This Code from reading this test case in Test Cases Doc file: Client Chatting With Therapist and Therapist Chatting With Therapist

import XCTest

// Note: These tests are flaky because Swift UI struggles to type messages in a text field, which means the test will sometimes break when trying to send the message
final class verifyClientTherapistChat: XCTestCase {

    private let clientName = "Jane Doe"
    private let clientEmail = "patient@gmail.com"
    private let clientPassword = "123456"
    private let clientChatName = "My Therapist"
    private let clientMessage = "Hello!"
    private let therapistName = "John Smith"
    private let therapistEmail = "therapy@gmail.com"
    private let therapistPassword = "123456"
    private let therapistMessage = "Checking in!"
    private let therapistName2 = "Sharie Finch"
    private let therapistEmail2 = "SharieFinch@horizontherapy.com"
    private let therapistPassword2 = "123456"
    private let therapistMessage2 = "Hello, Dr. Smith"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testClientToTherapistChat() throws {
        let app = makeApp()
        app.launch()

        login(email: clientEmail, password: clientPassword, app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        openTab("Chats", app: app)

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["arrow.clockwise"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts[clientChatName].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["HealthQuest AI"].exists)

        refreshChats(app)
        openChat(named: clientChatName, app: app)
        sendMessage(clientMessage, app: app)
        assertMessageVisible(clientMessage, app: app)

        tapBackButton(expectedTitle: clientChatName, app: app)
        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))

        logOut(app)
        assertLoginScreen(app)

        login(email: therapistEmail, password: therapistPassword, app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        openTab("Chats", app: app)

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Clients"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Providers"].exists)
        XCTAssertTrue(app.staticTexts["AI Chats"].exists)

        openChatSelection("Clients", app: app)
        refreshChats(app)
        openChat(named: clientName, app: app)
        assertMessageVisible(clientMessage, app: app)

        logOut(app)
        assertLoginScreen(app)
    }

    func testTherapistToClientChat() throws {
        let app = makeApp()
        app.launch()

        login(email: therapistEmail, password: therapistPassword, app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        openTab("Chats", app: app)

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Clients"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Providers"].exists)
        XCTAssertTrue(app.staticTexts["AI Chats"].exists)

        openChatSelection("Clients", app: app)
        refreshChats(app)
        openChat(named: clientName, app: app)
        sendMessage(therapistMessage, app: app)
        assertMessageVisible(therapistMessage, app: app)

        tapBackButton(expectedTitle: clientName, app: app)
        let chatSelectionBackButton = app.navigationBars["Chats"].buttons.firstMatch
        XCTAssertTrue(chatSelectionBackButton.waitForExistence(timeout: 5), "Back button not found on therapist chat list")
        chatSelectionBackButton.tap()
        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))

        logOut(app)
        assertLoginScreen(app)

        login(email: clientEmail, password: clientPassword, app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        openTab("Chats", app: app)

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["arrow.clockwise"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[clientChatName].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["HealthQuest AI"].exists)

        refreshChats(app)
        openChat(named: clientChatName, app: app)
        assertMessageVisible(therapistMessage, app: app)

        logOut(app)
        assertLoginScreen(app)
    }
    
    func testTherapistToTherapistChat() throws {
        let app = makeApp()
        app.launch()

        login(email: therapistEmail2, password: therapistPassword2, app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        openTab("Chats", app: app)

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Clients"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Providers"].exists)
        XCTAssertTrue(app.staticTexts["AI Chats"].exists)
        
        openChatSelection("Providers", app: app)
        refreshChats(app)
        openChat(named: therapistName, app: app)
        sendMessage(therapistMessage2, app: app)
        assertMessageVisible(therapistMessage2, app: app)

        tapBackButton(expectedTitle: therapistName, app: app)
        let providerSelectionBackButton = app.navigationBars["Chats"].buttons.firstMatch
        XCTAssertTrue(providerSelectionBackButton.waitForExistence(timeout: 5), "Back button not found on provider chat list")
        providerSelectionBackButton.tap()
        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))

        logOut(app)
        assertLoginScreen(app)

        login(email: therapistEmail, password: therapistPassword, app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        openTab("Chats", app: app)

        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Clients"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Providers"].exists)
        XCTAssertTrue(app.staticTexts["AI Chats"].exists)

        openChatSelection("Providers", app: app)
        refreshChats(app)
        openChat(named: therapistName2, app: app)
        assertMessageVisible(therapistMessage2, app: app)

        logOut(app)
        assertLoginScreen(app)
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
        tab.tap()
    }

    private func refreshChats(_ app: XCUIApplication) {
        let refreshButton = app.buttons["arrow.clockwise"]
        XCTAssertTrue(refreshButton.waitForExistence(timeout: 5), "Refresh button not found")
        refreshButton.tap()
    }

    private func openChatSelection(_ name: String, app: XCUIApplication) {
        let selection = app.staticTexts[name]
        XCTAssertTrue(selection.waitForExistence(timeout: 5), "\(name) selection not found")
        selection.tap()
        XCTAssertTrue(app.navigationBars["Chats"].waitForExistence(timeout: 5))
    }

    private func openChat(named name: String, app: XCUIApplication) {
        let chat = app.staticTexts[name]
        XCTAssertTrue(chat.waitForExistence(timeout: 10), "\(name) chat not found")
        chat.tap()
        XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 5))
    }

    private func sendMessage(_ message: String, app: XCUIApplication) {
        let messageField = app.textFields["Message…"].firstMatch
        let messageEditor = app.textViews["Message…"].firstMatch
        let composer = messageField.waitForExistence(timeout: 5) ? messageField : messageEditor
        XCTAssertTrue(composer.waitForExistence(timeout: 5), "Message field not found")
        composer.tap()
        composer.typeText(message)

        let sendButton = app.buttons["arrow.up.circle.fill"]
        XCTAssertTrue(sendButton.waitForExistence(timeout: 5), "Send button not found")
        sendButton.tap()
    }

    private func assertMessageVisible(_ message: String, app: XCUIApplication) {
        XCTAssertTrue(
            app.staticTexts[message].waitForExistence(timeout: 10),
            "Expected message '\(message)' not found"
        )
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

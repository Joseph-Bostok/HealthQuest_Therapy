//
//  verifyClientChangingTherapist.swift
//  healthQuestUITests
//
//  Created by Alexander Mesa on 4/18/26.
//  Codex AI Generated This Code from reading this test cases in Test Cases Doc file: Client Changing Therapist

// Precondition: Client FJ@jenkins.com should be assigned to therapist forrestK@pathways.com
// Condition: Run the testTherapistChange() before the other two tests

import XCTest

final class verifyClientChangingTherapist: XCTestCase {
    
    private let clientName = "Francis Jenkins"
    private let clientEmail = "FJ@jenkins.com"
    private let clientPassword = "123456"
    private let oldTherapistName = "Forrest Kriznev"
    private let oldTherapistEmail = "forrestK@pathways.com"
    private let oldTherapistPassword = "123456"
    private let newTherapistName = "John Smith"
    private let newTherapistEmail = "therapy@gmail.com"
    private let newTherapistPassword = "123456"
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    // This test fails because after the client logs in, the Profile tab doesn't get tapped. The logic is correct.
    func testTherapistChange() throws {
        let app = makeApp()
        app.launch()
        
        // Login as new therapist to generate referral code for client to change therapist
        login(email: newTherapistEmail, password: newTherapistPassword, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Add Client"].waitForExistence(timeout: 10))
        
        let referralCode = generateReferralCode(app)
        
        openTab("Profile", app: app)
        
        logOut(app)
        assertLoginScreen(app)
        
        // Login as client to change therapist using the referral code
        login(email: clientEmail, password: clientPassword, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        
        openTab("Profile", app: app)
        
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[oldTherapistName].exists)
        XCTAssertTrue(app.buttons["Change my Therapist"].exists)
        XCTAssertTrue(app.buttons["Log Out"].exists)
        
        let changeTherapistButton = app.buttons["Change my Therapist"]
        changeTherapistButton.tap()
        
        XCTAssertTrue(app.navigationBars["Find a Therapist"].waitForExistence(timeout: 5))
        
        openReferralCodeSheet(app)
        submitReferralCode(referralCode, app: app)
        
        XCTAssertTrue(app.navigationBars["Find a Therapist"].waitForExistence(timeout: 5))
        
        openReferralCodeSheet(app)
        submitReferralCode(referralCode, app: app)
        
        let duplicateCodeAlert = app.alerts["Error"]
        XCTAssertTrue(duplicateCodeAlert.waitForExistence(timeout: 10), "Expected duplicate referral code error alert")
        XCTAssertTrue(duplicateCodeAlert.staticTexts["This referral code has already been used."].exists)
        duplicateCodeAlert.buttons["OK"].tap()
        
        let cancelButton = app.navigationBars["Referral Code"].buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Cancel button not found on referral code page")
        cancelButton.tap()
        
        XCTAssertTrue(app.navigationBars["Find a Therapist"].waitForExistence(timeout: 5))
        
        tapBackButton(expectedTitle: "Find a Therapist", app: app)
        
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[newTherapistName].waitForExistence(timeout: 10))
        
        logOut(app)
        assertLoginScreen(app)
    }
    
    func testOldTherapistClientList() throws {
        let app = makeApp()
        app.launch()
        
        login(email: oldTherapistEmail, password: oldTherapistPassword, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        
        openTab("Patient Journals", app: app)
        
        XCTAssertTrue(app.navigationBars["My Clients"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts[clientName].exists)
        
        openTab("Patient Journals", app: app)
        
        logOut(app)
        assertLoginScreen(app)
    }
    
    func testNewTherapistClientList() throws {
        let app = makeApp()
        app.launch()
        
        login(email: newTherapistEmail, password: newTherapistPassword, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        
        openTab("Profile", app: app)
        
        XCTAssertTrue(app.navigationBars["My Clients"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[clientName].exists)
        
        openTab("Profile", app: app)
        
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
    
    private func tapBackButton(expectedTitle: String, app: XCUIApplication) {
        let backButton = app.navigationBars[expectedTitle].buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button not found for \(expectedTitle)")
        backButton.tap()
    }
    
    private func generateReferralCode(_ app: XCUIApplication) -> String {
        tapAddClientQuickAction(app)

        XCTAssertTrue(app.navigationBars["Generate Referral Code"].waitForExistence(timeout: 5))
        
        let generateButton = app.buttons["Generate Referral Code"]
        XCTAssertTrue(generateButton.waitForExistence(timeout: 5), "Generate Referral Code button not found")
        generateButton.tap()
        
        let referralCodeField = app.textFields["Referral Code"]
        XCTAssertTrue(referralCodeField.waitForExistence(timeout: 10), "Referral code field not found")
        
        let code = NSPredicate(format: "value != %@", "Referral Code")
        expectation(for: code, evaluatedWith: referralCodeField)
        waitForExpectations(timeout: 10)
        
        guard let referralCode = referralCodeField.value as? String else {
            XCTFail("Unable to read generated referral code")
            return ""
        }
        
        XCTAssertFalse(referralCode.isEmpty, "Generated referral code should not be empty")
        return referralCode
    }

    private func tapAddClientQuickAction(_ app: XCUIApplication) {
        let addClientButton = app.buttons["Add Client"]
        if addClientButton.waitForExistence(timeout: 5), addClientButton.isHittable {
            addClientButton.tap()
            return
        }

        let addClientLink = app.links["Add Client"]
        if addClientLink.waitForExistence(timeout: 2), addClientLink.isHittable {
            addClientLink.tap()
            return
        }

        let addClientCard = app.otherElements.containing(.staticText, identifier: "Add Client").firstMatch
        if addClientCard.waitForExistence(timeout: 2), addClientCard.isHittable {
            addClientCard.tap()
            return
        }

        let addClientLabel = app.staticTexts["Add Client"]
        XCTAssertTrue(addClientLabel.waitForExistence(timeout: 5), "Add Client quick action not found")
        XCTAssertTrue(addClientLabel.isHittable, "Add Client label exists but is not hittable")
        addClientLabel.tap()
    }

    private func openReferralCodeSheet(_ app: XCUIApplication) {
        let referralCodeButton = app.buttons["Referral Code"]
        XCTAssertTrue(referralCodeButton.waitForExistence(timeout: 5), "Referral Code toolbar button not found")
        referralCodeButton.tap()
        
        XCTAssertTrue(app.navigationBars["Referral Code"].waitForExistence(timeout: 5))
    }
    
    private func submitReferralCode(_ code: String, app: XCUIApplication) {
        let referralCodeField = app.textFields["XXXXXXXXXX"]
        XCTAssertTrue(referralCodeField.waitForExistence(timeout: 5), "Referral code entry field not found")
        referralCodeField.tap()
        referralCodeField.typeText(code)
        
        let connectButton = app.buttons["Connect with Therapist"]
        XCTAssertTrue(connectButton.waitForExistence(timeout: 5), "Connect with Therapist button not found")
        connectButton.tap()
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

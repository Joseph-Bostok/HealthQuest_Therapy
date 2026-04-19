//
//  verifyClientRatingTherapist.swift
//  healthQuestUITests
//
//  Created by Alexander Mesa on 4/18/26.
//  Codex AI Generated This Code from reading this test cases in Test Cases Doc file: Client Rating Therapist

// Precondition: Therapist should have 3-star ratings from patient@gmail.com and blaine.johns@ima.net
// Condition: Run the tests in this order: testLowClientRating(), testHighClientRating(), testUpdateClientRating(), testReuseClientRating()

import XCTest

final class verifyClientRatingTherapist: XCTestCase {

    private let clientEmail = "patient@gmail.com"
    private let clientPassword = "123456"
    private let clientEmail2 = "blaine.johns@ima.net"
    private let clientPassword2 = "123456"
    private let therapistEmail = "therapy@gmail.com"
    private let therapistPassword = "123456"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLowClientRating() throws {
        let app = makeApp()
        app.launch()

        // Get Initial Rating
        login(email: therapistEmail, password: therapistPassword, app)
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rating"].exists)
        let initialRating = try XCTUnwrap(homeStatDoubleValue(for: "Rating", app: app))
        
        openTab("Profile", app: app)

        logOut(app)
        assertLoginScreen(app)
        
        // Rate Therapist
        login(email: clientEmail, password: clientPassword, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        
        openTab("Profile", app: app)
        
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["About Me"].exists)
        XCTAssertTrue(app.staticTexts["Therapist"].exists)
        XCTAssertTrue(app.staticTexts["Dr. John Smith"].exists)
        XCTAssertTrue(app.buttons["Rate my Therapist"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Change my Therapist"].exists)
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Log Out"].exists)

        let rateButton = app.buttons["Rate my Therapist"]
        rateButton.tap()

        let ratingAlert = app.alerts["Rate Your Therapist"]
        XCTAssertTrue(ratingAlert.waitForExistence(timeout: 5), "Rate Your Therapist alert did not appear")

        let oneStarButton = ratingAlert.buttons["⭐️"]
        XCTAssertTrue(oneStarButton.waitForExistence(timeout: 5), "One-star rating button not found")
        oneStarButton.tap()

        XCTAssertFalse(ratingAlert.waitForExistence(timeout: 2), "Rate Your Therapist alert should close after selecting a rating")
        
        logOut(app)
        assertLoginScreen(app)
        
        // Get Updated Rating (rating should decrease)
        login(email: therapistEmail, password: therapistPassword, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rating"].exists)
        let updatedRating = try XCTUnwrap(homeStatDoubleValue(for: "Rating", app: app))
        XCTAssertLessThan(updatedRating, initialRating, "Therapist rating should decrease after a one-star client rating")
        
        openTab("Profile", app: app)
        
        logOut(app)
        assertLoginScreen(app)
    }

    func testHighClientRating() throws {
        let app = makeApp()
        app.launch()

        // Get Initial Rating
        login(email: therapistEmail, password: therapistPassword, app)
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rating"].exists)
        let initialRating = try XCTUnwrap(homeStatDoubleValue(for: "Rating", app: app))
        
        openTab("Profile", app: app)

        logOut(app)
        assertLoginScreen(app)
        
        // Rate Therapist
        login(email: clientEmail2, password: clientPassword2, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        
        openTab("Profile", app: app)
        
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["About Me"].exists)
        XCTAssertTrue(app.staticTexts["Therapist"].exists)
        XCTAssertTrue(app.staticTexts["Dr. John Smith"].exists)
        XCTAssertTrue(app.buttons["Rate my Therapist"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Change my Therapist"].exists)
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Log Out"].exists)

        let rateButton = app.buttons["Rate my Therapist"]
        rateButton.tap()

        let ratingAlert = app.alerts["Rate Your Therapist"]
        XCTAssertTrue(ratingAlert.waitForExistence(timeout: 5), "Rate Your Therapist alert did not appear")

        let fiveStarButton = ratingAlert.buttons["⭐️⭐️⭐️⭐️⭐️"]
        XCTAssertTrue(fiveStarButton.waitForExistence(timeout: 5), "Five-star rating button not found")
        fiveStarButton.tap()

        XCTAssertFalse(ratingAlert.waitForExistence(timeout: 2), "Rate Your Therapist alert should close after selecting a rating")
        
        logOut(app)
        assertLoginScreen(app)
        
        // Get Updated Rating (rating should increase)
        login(email: therapistEmail, password: therapistPassword, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rating"].exists)
        let updatedRating = try XCTUnwrap(homeStatDoubleValue(for: "Rating", app: app))
        XCTAssertGreaterThan(updatedRating, initialRating, "Therapist rating should increase after a five-star client rating")
        
        openTab("Profile", app: app)
        
        logOut(app)
        assertLoginScreen(app)
    }
    
    func testUpdateClientRating() throws {
        let app = makeApp()
        app.launch()

        // Get Initial Rating
        login(email: therapistEmail, password: therapistPassword, app)
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rating"].exists)
        let initialRating = try XCTUnwrap(homeStatDoubleValue(for: "Rating", app: app))
        
        openTab("Profile", app: app)

        logOut(app)
        assertLoginScreen(app)
        
        // Rate Therapist
        login(email: clientEmail2, password: clientPassword2, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        
        openTab("Profile", app: app)
        
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["About Me"].exists)
        XCTAssertTrue(app.staticTexts["Therapist"].exists)
        XCTAssertTrue(app.staticTexts["Dr. John Smith"].exists)
        XCTAssertTrue(app.buttons["Rate my Therapist"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Change my Therapist"].exists)
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Log Out"].exists)

        let rateButton = app.buttons["Rate my Therapist"]
        rateButton.tap()

        let ratingAlert = app.alerts["Rate Your Therapist"]
        XCTAssertTrue(ratingAlert.waitForExistence(timeout: 5), "Rate Your Therapist alert did not appear")

        let threeStarButton = ratingAlert.buttons["⭐️⭐️⭐️"]
        XCTAssertTrue(threeStarButton.waitForExistence(timeout: 5), "Three-star rating button not found")
        threeStarButton.tap()

        XCTAssertFalse(ratingAlert.waitForExistence(timeout: 2), "Rate Your Therapist alert should close after selecting a rating")
        
        logOut(app)
        assertLoginScreen(app)
        
        // Get Updated Rating (rating should increase)
        login(email: therapistEmail, password: therapistPassword, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rating"].exists)
        let updatedRating = try XCTUnwrap(homeStatDoubleValue(for: "Rating", app: app))
        XCTAssertLessThan(updatedRating, initialRating, "Therapist rating should decrease after a client changes rating from five-star to three-star")
        
        openTab("Profile", app: app)
        
        logOut(app)
        assertLoginScreen(app)
    }
    
    func testRepeatClientRating() throws {
        let app = makeApp()
        app.launch()

        // Get Initial Rating
        login(email: therapistEmail, password: therapistPassword, app)
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rating"].exists)
        let initialRating = try XCTUnwrap(homeStatDoubleValue(for: "Rating", app: app))
        
        openTab("Profile", app: app)

        logOut(app)
        assertLoginScreen(app)
        
        // Rate Therapist (Same rating from same client)
        login(email: clientEmail, password: clientPassword, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        
        openTab("Profile", app: app)
        
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["About Me"].exists)
        XCTAssertTrue(app.staticTexts["Therapist"].exists)
        XCTAssertTrue(app.staticTexts["Dr. John Smith"].exists)
        XCTAssertTrue(app.buttons["Rate my Therapist"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Change my Therapist"].exists)
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Log Out"].exists)

        let rateButton = app.buttons["Rate my Therapist"]
        rateButton.tap()

        let ratingAlert = app.alerts["Rate Your Therapist"]
        XCTAssertTrue(ratingAlert.waitForExistence(timeout: 5), "Rate Your Therapist alert did not appear")

        let oneStarButton = ratingAlert.buttons["⭐️"]
        XCTAssertTrue(oneStarButton.waitForExistence(timeout: 5), "One-star rating button not found")
        oneStarButton.tap()

        XCTAssertFalse(ratingAlert.waitForExistence(timeout: 2), "Rate Your Therapist alert should close after selecting a rating")
        
        logOut(app)
        assertLoginScreen(app)
        
        // Get Updated Rating (rating should not change because it's same rating from same client)
        login(email: therapistEmail, password: therapistPassword, app)
        
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rating"].exists)
        let updatedRating = try XCTUnwrap(homeStatDoubleValue(for: "Rating", app: app))
        XCTAssertEqual(updatedRating, initialRating, "Therapist rating should not change after the same rating from the same client")
        
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

    private func homeStatDoubleValue(for label: String, app: XCUIApplication) -> Double? {
        let labelElement = app.staticTexts[label]
        guard labelElement.waitForExistence(timeout: 5) else { return nil }

        let labelFrame = labelElement.frame
        let candidates = app.staticTexts.allElementsBoundByIndex.compactMap { element -> (XCUIElement, Double)? in
            guard element.exists,
                  let text = element.label.split(separator: "\n").first.map(String.init),
                  let value = Double(text)
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

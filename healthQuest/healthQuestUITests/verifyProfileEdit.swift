//
//  verifyProfileEdit.swift
//  healthQuestUITests
//
//  Created by Alexander Mesa on 4/17/26.
//  Codex AI Generated This Code from reading these test cases in Test Cases Doc file: Client Editing Profile and Therapist Editing Profile

import XCTest

/* Preconditions:
    Client Profile:
        Name: Jane Doe
        Email: patient@gmail.com
        Phone: 123-456-7890
    Therapist Profile:
        Name: John Smith
        Email: therapy@gmail.com
        Phone: 123-456-7890

*/

final class verifyProfileEdit: XCTestCase {

    private let clientName = "Jane Doe"
    private let clientFirstName = "Jane"
    private let clientLastName = "Doe"
    private let clientEmail = "patient@gmail.com"
    private let clientPassword = "123456"
    
    private let clientNameEdit = "Jan Doel"
    private let clientFirstNameEdit = "Jan"
    private let clientLastNameEdit = "Doel"
    private let clientEmailEdit = "patien@gmail.com"
    private let clientPhone = "123-456-7890"
    private let clientPhoneEdit = "123-456-7891"
    private let clientGreeting = "Hello, Jane! 👋"
    private let clientGreetingEdit = "Hello, Jan! 👋"
    
    private let therapistName = "John Smith"
    private let therapistFirstName = "John"
    private let therapistLastName = "Smith"
    private let therapistEmail = "therapy@gmail.com"
    private let therapistPassword = "123456"
    
    private let therapistNameEdit = "Jon Sith"
    private let therapistFirstNameEdit = "Jon"
    private let therapistLastNameEdit = "Sith"
    private let therapistEmailEdit = "therap@gmail.com"
    private let therapistPhone = "123-456-7890"
    private let therapistPhoneEdit = "123-456-7891"
    private let therapistGreeting = "Hello, Dr. Smith! 👋"
    private let therapistGreetingEdit = "Hello, Dr. Sith! 👋"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testClientProfileEdit() throws {
        let app = makeApp()
        app.launch()

        login(email: clientEmail, password: clientPassword, app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        openTab("Profile", app: app)
        
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[clientName].exists)
        XCTAssertTrue(app.staticTexts[clientEmail].exists)
        XCTAssertTrue(app.staticTexts[clientPhone].exists)
        XCTAssertTrue(app.staticTexts["About Me"].exists)
        XCTAssertTrue(app.staticTexts["Therapist"].exists)
        XCTAssertTrue(app.buttons["Rate my Therapist"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Change my Therapist"].exists)
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Log Out"].exists)

        openEditProfile(app)
        assertEditProfileFieldsVisible(app)

        populateClientProfileFields(
            app,
            firstName: clientFirstNameEdit,
            lastName: clientLastNameEdit,
            email: clientEmailEdit,
            phone: clientPhoneEdit
        )
        tapCancelAndDiscard(app)
        assertClientProfile(app, expectedName: clientName, expectedEmail: clientEmail, expectedPhone: clientPhone)

        openEditProfile(app)
        populateClientProfileFields(
            app,
            firstName: clientFirstNameEdit,
            lastName: clientLastNameEdit,
            email: clientEmailEdit,
            phone: clientPhoneEdit
        )
        tapSaveChanges(app)
        /*assertErrorAlertContains("Please verify the new email before changing email.", app: app)*/
        dismissErrorAlert(app)
        
        assertClientProfile(app, expectedName: clientNameEdit, expectedEmail: clientEmail, expectedPhone: clientPhoneEdit)

        openTab("Home", app: app)
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[clientGreetingEdit].waitForExistence(timeout: 5))

        openTab("Profile", app: app)
        openEditProfile(app)
        populateClientProfileFields(
            app,
            firstName: clientFirstNameEdit,
            lastName: clientLastNameEdit,
            email: nil,
            phone: clientPhoneEdit
        )
        tapSaveChanges(app)
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 10))
        assertClientProfile(app, expectedName: clientNameEdit, expectedEmail: clientEmail, expectedPhone: clientPhoneEdit)

        openTab("Home", app: app)
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[clientGreetingEdit].waitForExistence(timeout: 5))

        openTab("Profile", app: app)
        openEditProfile(app)
        populateClientProfileFields(
            app,
            firstName: clientFirstName,
            lastName: clientLastName,
            email: nil,
            phone: clientPhone
        )
        tapSaveChanges(app)
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 10))
        assertClientProfile(app, expectedName: clientName, expectedEmail: clientEmail, expectedPhone: clientPhone)

        openTab("Home", app: app)
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[clientGreeting].waitForExistence(timeout: 5))

        logOut(app)
        assertLoginScreen(app)
    }

    func testTherapistProfileEdit() throws {
        let app = makeApp()
        app.launch()

        login(email: therapistEmail, password: therapistPassword, app)

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        openTab("Profile", app: app)
        
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[therapistName].exists)
        XCTAssertTrue(app.staticTexts[therapistEmail].exists)
        XCTAssertTrue(app.staticTexts[therapistPhone].exists)
        XCTAssertTrue(app.staticTexts["About Me"].exists)
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Log Out"].exists)

        openEditProfile(app)
        assertEditProfileFieldsVisible(app)

        populateClientProfileFields(
            app,
            firstName: therapistFirstNameEdit,
            lastName: therapistLastNameEdit,
            email: therapistEmailEdit,
            phone: therapistPhoneEdit
        )
        tapCancelAndDiscard(app)
        assertClientProfile(app, expectedName: therapistName, expectedEmail: therapistEmail, expectedPhone: therapistPhone)

        openEditProfile(app)
        populateClientProfileFields(
            app,
            firstName: therapistFirstNameEdit,
            lastName: therapistLastNameEdit,
            email: therapistEmailEdit,
            phone: therapistPhoneEdit
        )
        tapSaveChanges(app)
        dismissErrorAlert(app)
        assertClientProfile(app, expectedName: therapistNameEdit, expectedEmail: therapistEmail, expectedPhone: therapistPhoneEdit)

        openTab("Home", app: app)
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[therapistGreetingEdit].waitForExistence(timeout: 5))

        openTab("Profile", app: app)
        openEditProfile(app)
        populateClientProfileFields(
            app,
            firstName: therapistFirstNameEdit,
            lastName: therapistLastNameEdit,
            email: nil,
            phone: therapistPhoneEdit
        )
        tapSaveChanges(app)
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 10))
        assertClientProfile(app, expectedName: therapistNameEdit, expectedEmail: therapistEmail, expectedPhone: therapistPhoneEdit)

        openTab("Home", app: app)
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[therapistGreetingEdit].waitForExistence(timeout: 5))

        openTab("Profile", app: app)
        openEditProfile(app)
        populateClientProfileFields(
            app,
            firstName: therapistFirstName,
            lastName: therapistLastName,
            email: nil,
            phone: therapistPhone
        )
        tapSaveChanges(app)
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 10))
        assertClientProfile(app, expectedName: therapistName, expectedEmail: therapistEmail, expectedPhone: therapistPhone)

        openTab("Home", app: app)
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[therapistGreeting].waitForExistence(timeout: 5))

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

    private func openEditProfile(_ app: XCUIApplication) {
        let editProfileButton = app.buttons["Edit Profile"]
        XCTAssertTrue(editProfileButton.waitForExistence(timeout: 5), "Edit Profile button not found")
        editProfileButton.tap()
        XCTAssertTrue(app.navigationBars["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Name"].exists)
        XCTAssertTrue(app.staticTexts["Contact"].exists)
        XCTAssertTrue(app.staticTexts["About Me"].exists)
    }

    private func assertEditProfileFieldsVisible(_ app: XCUIApplication) {
        XCTAssertTrue(app.navigationBars["Edit Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["First Name"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["Last Name"].exists)
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.textFields["Phone (optional)"].exists)
        XCTAssertTrue(app.staticTexts["About Me"].exists)
        XCTAssertTrue(app.buttons["Save Changes"].exists)
        XCTAssertTrue(app.buttons["Cancel"].exists)
    }

    private func populateClientProfileFields(
        _ app: XCUIApplication,
        firstName: String,
        lastName: String,
        email: String?,
        phone: String
    ) {
        replaceText(in: app.textFields["First Name"], with: firstName)
        replaceText(in: app.textFields["Last Name"], with: lastName)
        if let email {
            replaceText(in: app.textFields["Email"], with: email)
        }
        replaceText(in: app.textFields["Phone (optional)"], with: phone)

        XCTAssertEqual(app.textFields["First Name"].value as? String, firstName)
        XCTAssertEqual(app.textFields["Last Name"].value as? String, lastName)
        if let email {
            XCTAssertEqual(app.textFields["Email"].value as? String, email)
        }
        XCTAssertEqual(app.textFields["Phone (optional)"].value as? String, phone)
    }

    private func tapCancelAndDiscard(_ app: XCUIApplication) {
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Cancel button not found")
        cancelButton.tap()

        let discardAlert = app.alerts["Discard changes?"]
        XCTAssertTrue(discardAlert.waitForExistence(timeout: 5), "Discard alert did not appear")
        let discardButton = discardAlert.buttons["Discard"]
        XCTAssertTrue(discardButton.waitForExistence(timeout: 5), "Discard button not found")
        discardButton.tap()

        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
    }

    private func tapSaveChanges(_ app: XCUIApplication) {
        let saveButton = app.buttons["Save Changes"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save Changes button not found")
        saveButton.tap()
    }

    private func assertErrorAlertContains(_ message: String, app: XCUIApplication) {
        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 10), "Error alert did not appear")
        XCTAssertTrue(errorAlert.staticTexts[message].waitForExistence(timeout: 5), "Expected error message not found")
    }

    private func dismissErrorAlert(_ app: XCUIApplication) {
        let errorAlert = app.alerts["Error"]
        if errorAlert.waitForExistence(timeout: 2) {
            let okButton = errorAlert.buttons["OK"]
            if okButton.waitForExistence(timeout: 2) {
                okButton.tap()
            }
        }
    }

    private func assertClientProfile(_ app: XCUIApplication, expectedName: String, expectedEmail: String, expectedPhone: String) {
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[expectedName].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[expectedEmail].exists)
        XCTAssertTrue(app.staticTexts[expectedPhone].exists)
    }

    private func replaceText(in element: XCUIElement, with text: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "\(element) not found")
        element.tap()

        if let currentValue = element.value as? String, !currentValue.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            element.typeText(deleteString)
        }

        element.typeText(text)
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

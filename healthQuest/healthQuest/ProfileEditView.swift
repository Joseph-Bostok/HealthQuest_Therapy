//
//  ProfileEditView.swift
//  healthQuest
//
//  ID 3 – Profile edit screen
//  Cameron
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {

    // MARK: – Form state
    @State private var firstName:  String = ""
    @State private var lastName:   String = ""
    @State private var email:      String = ""
    @State private var phone:      String = ""
    @State private var bio:        String = ""

    // MARK: – Photo picker
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil

    // MARK: – Validation errors
    @State private var firstNameError: String = ""
    @State private var lastNameError:  String = ""
    @State private var emailError:     String = ""
    @State private var phoneError:     String = ""

    // MARK: – UI state
    @State private var isSaving:      Bool = false
    @State private var saveSuccess:   Bool = false
    @State private var showDiscardAlert = false

    @Environment(\.dismiss) private var dismiss

    /// True when the user has modified at least one field
    private var isDirty: Bool {
        !firstName.isEmpty || !lastName.isEmpty ||
        !email.isEmpty     || !phone.isEmpty    ||
        !bio.isEmpty       || profileImage != nil
    }

    // Light gray matching AppBackground-adjacent cards
    private let fieldBg = Color(red: 0.914, green: 0.941, blue: 0.918)

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        profilePictureSection

                        formSection(title: "Name") {
                            validatedField(
                                label: "First Name",
                                text: $firstName,
                                error: firstNameError,
                                keyboard: .default
                            )
                            validatedField(
                                label: "Last Name",
                                text: $lastName,
                                error: lastNameError,
                                keyboard: .default
                            )
                        }

                        formSection(title: "Contact") {
                            validatedField(
                                label: "Email",
                                text: $email,
                                error: emailError,
                                keyboard: .emailAddress
                            )
                            validatedField(
                                label: "Phone (optional)",
                                text: $phone,
                                error: phoneError,
                                keyboard: .phonePad
                            )
                        }

                        formSection(title: "About Me") {
                            bioField
                        }

                        saveButton

                        if saveSuccess {
                            Label("Profile saved!", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.footnote.bold())
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if isDirty { showDiscardAlert = true } else { dismiss() }
                    }
                }
            }
            .alert("Discard changes?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep Editing", role: .cancel) { }
            }
        }
    }

    // MARK: – Profile picture section
    private var profilePictureSection: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let profileImage {
                        profileImage
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                            .foregroundStyle(Color("AccentColor").opacity(0.35))
                    }
                }
                .frame(width: 110, height: 110)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color("AccentColor"), lineWidth: 2.5))

                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color("AccentColor"))
                        .background(Circle().fill(Color("AppBackground")))
                }
                .offset(x: 4, y: 4)
            }

            Text("Tap the pencil to change your photo")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImg = UIImage(data: data) {
                    profileImage = Image(uiImage: uiImg)
                }
            }
        }
    }

    // MARK: – Reusable form section
    @ViewBuilder
    private func formSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color("AccentColor"))

            VStack(spacing: 10) { content() }
                .padding(16)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: – Validated text field
    @ViewBuilder
    private func validatedField(
        label: String,
        text: Binding<String>,
        error: String,
        keyboard: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(label, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                .autocorrectionDisabled()
                .padding(12)
                .background(fieldBg)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            error.isEmpty ? Color.clear : Color.red,
                            lineWidth: 1.5
                        )
                )

            if !error.isEmpty {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
            }
        }
    }

    // MARK: – Bio text editor
    private var bioField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("About Me")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextEditor(text: $bio)
                .frame(minHeight: 90, maxHeight: 200)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(fieldBg)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text("\(bio.count) characters")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    // MARK: – Save button
    private var saveButton: some View {
        Button {
            if validate() { save() }
        } label: {
            Group {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("Save Changes").fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("AccentColor"))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isSaving)
    }

    // MARK: – Validation
    @discardableResult
    private func validate() -> Bool {
        var valid = true

        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            firstNameError = "First name is required."; valid = false
        } else { firstNameError = "" }

        if lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            lastNameError = "Last name is required."; valid = false
        } else { lastNameError = "" }

        let emailRegex = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = "Email is required."; valid = false
        } else if (try? emailRegex.wholeMatch(in: email)) == nil {
            emailError = "Enter a valid email address."; valid = false
        } else { emailError = "" }

        if !phone.isEmpty {
            let digits = phone.filter { $0.isNumber }
            if digits.count < 7 || digits.count > 15 {
                phoneError = "Enter a valid phone number."; valid = false
            } else { phoneError = "" }
        } else { phoneError = "" }

        return valid
    }

    // MARK: – Save
    private func save() {
        isSaving = true
        // TODO: Firestore update here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isSaving = false
            withAnimation { saveSuccess = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { saveSuccess = false }
            }
        }
    }
}

#Preview { ProfileEditView() }

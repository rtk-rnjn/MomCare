

import SwiftUI

struct BaseSignUpView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                signUpForm
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 16)
                    }

                createButton
            }
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.large)
            .alert("Invalid Details", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var mobileNumber = ""

    @State private var showPassword = false
    @State private var showConfirmPassword = false

    @State private var showAlert = false
    @State private var alertMessage = ""

    @State private var navigateToOTP = false
    @State private var isLoading = false

    @FocusState private var isFocused: Bool

    private var signUpForm: some View {
        Group {
            if #available(iOS 16.0, *) {
                Form {
                    nameSection
                    credentialsSection
                    mobileSection
                }
                .scrollContentBackground(.hidden)
            } else {
                Form {
                    nameSection
                    credentialsSection
                    mobileSection
                }
            }
        }
    }

    private var nameSection: some View {
        Section {
            TextField("First Name", text: $firstName)
                .textInputAutocapitalization(.words)
                .listRowBackground(Color(.secondarySystemBackground))

            TextField("Last Name", text: $lastName)
                .textInputAutocapitalization(.words)
                .listRowBackground(Color(.secondarySystemBackground))
        }
    }

    private var credentialsSection: some View {
        Section {
            TextField("Email Address", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .listRowBackground(Color(.secondarySystemBackground))

            passwordField(
                title: "Password",
                text: $password,
                isVisible: $showPassword
            )

            passwordField(
                title: "Confirm Password",
                text: $confirmPassword,
                isVisible: $showConfirmPassword
            )
        }
    }

    private var mobileSection: some View {
        Section {
            TextField("Mobile Number", text: $mobileNumber)
                .keyboardType(.numberPad)
                .onChange(of: mobileNumber) { _, newValue in
                    mobileNumber = newValue.filter(\.isNumber)
                }
                .listRowBackground(Color(.secondarySystemBackground))
        }
    }

    private var createButton: some View {
        VStack {
            Button {
                Task { await handleCreate() }
            } label: {
                Text("Create")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(MomCareAccent.primary)
            .controlSize(.large)
        }
        .padding(.horizontal)
        .padding(.top, 30)
        .padding(.bottom, 20)
        .navigationDestination(isPresented: $navigateToOTP) {
            OTPScreenView(navigateTo: .extendedSignUp)
        }
    }

    private func passwordField(
        title: String,
        text: Binding<String>,
        isVisible: Binding<Bool>
    ) -> some View {
        HStack {
            ZStack {
                SecureField(title, text: text)
                    .opacity(isVisible.wrappedValue ? 0 : 1)

                TextField(title, text: text)
                    .opacity(isVisible.wrappedValue ? 1 : 0)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
            }
            .focused($isFocused)
            .animation(.easeInOut(duration: 0.2), value: isVisible.wrappedValue)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isVisible.wrappedValue.toggle()
                }
            } label: {
                Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
                    .symbolEffect(.bounce.down, options: .nonRepeating, value: isVisible.wrappedValue)
            }
            .buttonStyle(.plain)
        }
        .listRowBackground(Color(.secondarySystemBackground))
    }

    private func communicateWithServer() async {
        let networkResponse = try? await authenticationService.register(emailAddress: email, password: password)
        if let error = networkResponse?.errorMessage {
            alertMessage = error
            showAlert = true
            return
        }

        authenticationService.userModel?.firstName = firstName
        authenticationService.userModel?.lastName = lastName
        authenticationService.userModel?.phoneNumber = mobileNumber

        navigateToOTP = authenticationService.hasAccessToken
        _ = try? await authenticationService.update(firstName: .value(firstName), lastName: .value(lastName), phoneNumber: .value(mobileNumber))
    }

    private func handleCreate() async {
        let missingFields = getMissingFields()
        if !missingFields.isEmpty {
            alertMessage = "\(missingFields.joined(separator: ", ")) are missing."
            showAlert = true
            return
        }

        if !isValidEmail(email) {
            alertMessage = "Please enter a valid email address."
        }

        else if password.count < 8 {
            alertMessage = "Password must be at least 8 characters long."
        }

        else if password != confirmPassword {
            alertMessage = "Passwords do not match."
        }

        else if mobileNumber.count != 10 {
            alertMessage = "Mobile number must be exactly 10 digits."
        }

        else {
            isLoading = true
            await communicateWithServer()
            return
        }

        showAlert = true
    }

    private func getMissingFields() -> [String] {
        var missing = [String]()

        if firstName.isEmpty { missing.append("First Name") }
        if lastName.isEmpty { missing.append("Last Name") }
        if email.isEmpty { missing.append("Email Address") }
        if password.isEmpty { missing.append("Password") }
        if confirmPassword.isEmpty { missing.append("Confirm Password") }
        if mobileNumber.isEmpty { missing.append("Mobile Number") }

        return missing
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }

}

import SwiftUI

struct SignInView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                signInForm
                    .safeAreaInset(edge: .top) {
                        Color.clear
                            .frame(height: 16)
                    }

                VStack {
                    Button {
                        Task { await handleSubmit() }
                    } label: {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(MomCareAccent.primary)
                    .controlSize(.large)
                }
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(alertMessage)
                }
                .padding(.horizontal)
                .padding(.top, 30)
                .padding(.bottom, 20)
            }
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    func handleSubmit() async {
        let networkResponse = try? await authenticationService.login(emailAddress: email, password: password)

        guard let networkResponse else {
            alertTitle = "Error"
            alertMessage = "An unexpected error occurred. Please try again later."
            showAlert = true
            return
        }

        if let error = networkResponse.errorMessage {
            alertTitle = "Sign In Failed"
            alertMessage = error
            showAlert = true
            return
        }

        showAlert = false
        controlState.isLoggedIn = true
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService
    @EnvironmentObject private var controlState: ControlState

    @State private var email = ""
    @State private var password = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""

    @ViewBuilder
    private var signInForm: some View {
        Form {
            Section {
                emailField
                passwordField
            }
        }
        .scrollContentBackground(.hidden)
    }

    private var emailField: some View {
        TextField("Email ID", text: $email)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .listRowBackground(Color(.secondarySystemBackground))
    }

    private var passwordField: some View {
        SecureField("Password", text: $password)
            .listRowBackground(Color(.secondarySystemBackground))
    }
}

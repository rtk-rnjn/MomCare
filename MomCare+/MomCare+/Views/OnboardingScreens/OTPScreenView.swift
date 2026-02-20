import Combine
import SwiftUI

enum DestinationType {
    case mainApp
    case extendedSignUp
}

struct OTPScreenView: View {

    // MARK: Lifecycle

    init(navigateTo destination: DestinationType) {
        self.destination = destination
    }

    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Verification Code")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(MomCareAccent.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

                Text("Enter the code sent to your email address")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                otpInputView

                verifyButton

                resendButton

                Spacer()
            }
            .padding()
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .onReceive(timer) { _ in
                if resendTimer > 0 {
                    resendTimer -= 1
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .task {
                _ = try? await authenticationService.requestOTP()
            }
        }
    }

    func handleSubmit() async {
        let response = try? await authenticationService.verifyOTP(otp: otpString)

        guard response?.statusCode == 200 else {
            showVerificationError(message: response?.errorMessage)
            return
        }

        let networkResponse = try? await authenticationService.me()
        if networkResponse?.statusCode != 200 {
            showUnknownError()
            return
        }
        guard let user = authenticationService.userModel else {
            showUnknownError()
            return
        }

        if user.isProfileComplete {
            destination = .mainApp
        } else {
            destination = .extendedSignUp
        }

        navigate = true
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService

    @State private var otpString = ""
    @FocusState private var isFieldFocused: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var resendTimer = 0
    @State private var navigate: Bool = false

    @State private var destination: DestinationType

    private let otpLength = 6
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var otpInputView: some View {
        ZStack {
            HStack(spacing: 12) {
                ForEach(0 ..< otpLength, id: \.self) { index in
                    OTPBox(
                        index: index,
                        otpString: otpString,
                        isActive: isFieldFocused && index == otpString.count
                    )
                }
            }

            hiddenOTPTextField
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFieldFocused = true
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isFieldFocused = true
            }
        }
    }

    private var hiddenOTPTextField: some View {
        Group {
            if #available(iOS 17.0, *) {
                TextField("", text: $otpString)
                    .otpTextFieldStyle(isFocused: $isFieldFocused)
                    .onChange(of: otpString) { _, newValue in
                        sanitizeOTP(newValue)
                    }
            } else {
                TextField("", text: $otpString)
                    .otpTextFieldStyle(isFocused: $isFieldFocused)
                    .onChange(of: otpString) { newValue in
                        sanitizeOTP(newValue)
                    }
            }
        }
    }

    private var verifyButton: some View {
        Button {
            Task { await handleSubmit() }
        } label: {
            Text("Verify")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(MomCareAccent.primary)
        .controlSize(.large)
        .disabled(otpString.count != otpLength)
        .navigationDestination(isPresented: $navigate) {
            switch destination {
            case .mainApp:
                MomCareMainTabView()
            case .extendedSignUp:
                HealthMetricsSignUpView()
            }
        }
    }

    private var resendButton: some View {
        Button {
            Task {
                if let networkResponse = try? await authenticationService.requestOTP() {
                    if networkResponse.statusCode == 200 {
                        resendTimer = 30
                        alertTitle = "OTP Sent"
                        showAlert = true
                    } else if let errorMessage = networkResponse.errorMessage {
                        resendTimer = 0
                        alertTitle = "Verification Failed"
                        alertMessage = errorMessage
                        showAlert = true
                    }
                }
            }
        } label: {
            Text(
                resendTimer > 0
                    ? "Resend in \(resendTimer)s"
                    : "Didn’t receive a code?"
            )
        }
        .foregroundStyle(resendTimer > 0 ? .secondary : Color("primaryAppColor"))
        .disabled(resendTimer > 0)
        .padding(.top, 8)
    }

    private func showVerificationError(message: String?) {
        alertTitle = "Verification Failed"
        alertMessage = message ?? "Invalid OTP. Please try again."
        showAlert = true
    }

    private func showUnknownError() {
        alertTitle = "Verification Failed"
        alertMessage = "An unknown error occurred. Please try again."
        showAlert = true
    }

    private func sanitizeOTP(_ value: String) {
        let filtered = value.filter(\.isNumber)
        let limited = String(filtered.prefix(otpLength))
        otpString = limited

        if limited.count == otpLength {
            isFieldFocused = false
        }
    }
}

struct OTPBox: View {

    // MARK: Internal

    let index: Int
    let otpString: String
    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isActive ? Color("primaryAppColor") : Color.gray.opacity(0.3),
                    lineWidth: isActive ? 2 : 1
                )
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                )

            if index < otpString.count {
                let charIndex = otpString.index(otpString.startIndex, offsetBy: index)
                Text(String(otpString[charIndex]))
                    .font(.title2.weight(.semibold))
            } else if isActive {
                Rectangle()
                    .fill(MomCareAccent.primary)
                    .frame(width: 2, height: 24)
                    .opacity(showCursor ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true),
                        value: showCursor
                    )
                    .onAppear { showCursor = true }
            }
        }
        .frame(width: 45, height: 55)
    }

    // MARK: Private

    @State private var showCursor = false

}

struct OTPTextFieldStyle: ViewModifier {
    @FocusState.Binding var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .focused($isFocused)
    }
}

extension View {
    func otpTextFieldStyle(isFocused: FocusState<Bool>.Binding) -> some View {
        modifier(OTPTextFieldStyle(isFocused: isFocused))
    }
}

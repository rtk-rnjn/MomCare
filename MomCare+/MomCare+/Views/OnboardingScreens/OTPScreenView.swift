import Combine
import SwiftUI

enum DestinationType {
    case mainApp
    case extendedSignUp
}

struct OTPScreenView: View {
    // MARK: Internal

    var redactedDisplayEmail: String {
        guard
            let email = authenticationService.credentials?.emailAddress,
            let atIndex = email.firstIndex(of: "@")
        else {
            return "your email"
        }

        let name = email[..<atIndex]
        let domain = email[atIndex...]

        guard name.count > 4 else {
            return "\(name.prefix(1))****\(domain)"
        }

        let prefix = name.prefix(2)
        let suffix = name.suffix(2)
        let stars = String(repeating: "*", count: max(4, name.count - 4))

        return "\(prefix)\(stars)\(suffix)\(domain)"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Verification Code")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(MomCareAccent.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

                Text("Enter the code sent to \(redactedDisplayEmail)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                otpInputView

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
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    verifyButton
                }
            }
            .task {
                do {
                    try await authenticationService.requestOTP()
                } catch {
                    controlState.error = error
                }
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: MCAuthenticationService
    @EnvironmentObject private var controlState: ControlState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var otpString = ""
    @FocusState private var isFieldFocused: Bool
    @State private var resendTimer = 60
    @State private var navigate: Bool = false

    @State private var destination: DestinationType?

    @State private var isLoading = false

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
            .accessibilityHidden(true)

            hiddenOTPTextField
                .onSubmit {
                    Task {
                        do {
                            try await handleSubmit()
                        } catch {
                            controlState.error = error
                        }
                    }
                }
                .submitLabel(.done)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Button(role: .confirm) {
                            Task {
                                do {
                                    try await handleSubmit()
                                } catch {
                                    controlState.error = error
                                }
                            }
                        }
                    }
                }
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Verification code input")
        .accessibilityValue("\(otpString.count) of \(otpLength) digits entered")
        .accessibilityHint("Tap to enter your \(otpLength)-digit verification code")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default) {
            isFieldFocused = true
        }
    }

    private var hiddenOTPTextField: some View {
        Group {
            TextField("", text: $otpString)
                .otpTextFieldStyle(isFocused: $isFieldFocused)
                .onChange(of: otpString) { _, newValue in
                    sanitizeOTP(newValue)
                    if otpString.count == otpLength {
                        isFieldFocused = false
                    }
                }
        }
    }

    private var verifyButton: some View {
        Button {
            Task {
                do {
                    try await handleSubmit()
                } catch {
                    controlState.error = error
                }
            }
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            } else {
                Text("Verify")
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderedProminent)
        .tint(MomCareAccent.primary)
        .controlSize(.large)
        .disabled(otpString.count != otpLength || isLoading)
        .accessibilityLabel("Verify code")
        .accessibilityHint("Verifies the 6-digit code you entered")
        .accessibilityIdentifier("verifyButton")
        .navigationDestination(isPresented: $navigate) {
            switch destination {
            case .mainApp:
                MomCareMainTabView()
            default:
                HealthMetricsSignUpView()
            }
        }
    }

    private var resendButton: some View {
        Button {
            Task {
                do {
                    try await authenticationService.requestOTP()
                    resendTimer = 60
                } catch {
                    controlState.error = error
                }
            }
        } label: {
            Text(resendTimer > 0 ? "Resend in \(resendTimer)s" : "Didn't receive a code?")
                .contentTransition(reduceMotion ? .identity : .numericText(countsDown: true))
                .animation(reduceMotion ? nil : .easeInOut, value: resendTimer)
        }
        .foregroundStyle(resendTimer > 0 ? .secondary : Color("primaryAppColor"))
        .disabled(resendTimer > 0)
        .padding(.top, 8)
        .accessibilityLabel(resendTimer > 0 ? "Resend code in \(resendTimer) seconds" : "Resend code")
        .accessibilityHint(resendTimer > 0 ? "Please wait before requesting another code" : "Sends a new verification code to your email")
        .accessibilityIdentifier("resendButton")
    }

    private func handleSubmit() async throws {
        isLoading = true
        defer { isLoading = false }

        try await authenticationService.verifyOTP(otp: otpString)

        guard let user = authenticationService.userModel else {
            return
        }

        if user.isProfileComplete {
            destination = .mainApp
        } else {
            destination = .extendedSignUp
        }

        navigate = true
    }

    private func sanitizeOTP(_ value: String) {
        let filtered = value.filter(\.isNumber)
        let limited = String(filtered.prefix(otpLength))
        otpString = limited
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
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeInOut, value: otpString[charIndex])
            } else if isActive {
                Rectangle()
                    .fill(MomCareAccent.primary)
                    .frame(width: 2, height: 24)
                    .opacity(showCursor ? 1 : 0)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: showCursor)
                    .onAppear { showCursor = true }
            }
        }
        .frame(width: 45, height: 55)
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

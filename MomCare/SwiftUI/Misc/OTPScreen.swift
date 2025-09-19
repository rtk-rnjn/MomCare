//
//  OTPScreen.swift
//  MomCare
//
//  Created by Aryan Singh on 08/06/25.
//

import SwiftUI
import Combine

struct OTPScreen: View {

    // MARK: Internal

    var viewController: OTPScreenViewController?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Verification Code")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Enter the code we sent to your email address")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            ZStack(alignment: .center) {
                HStack(spacing: 12) {
                    ForEach(0..<otpLength, id: \.self) { index in
                        OTPBox(
                            index: index,
                            otpString: otpString,
                            isActive: isFieldFocused && index == otpString.count
                        )
                    }
                }

                TextField("", text: $otpString)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($isFieldFocused)
                    .accessibilityLabel("Enter verification code")
                    .accessibilityHint("6 digit code sent to your email")
                    .onChange(of: otpString) { _, newValue in
                        if newValue.count > otpLength {
                            otpString = String(newValue.prefix(otpLength))
                        }
                        otpString = newValue.filter { "0123456789".contains($0) }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isFieldFocused = true
                        }
                    }
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            .onTapGesture {
                isFieldFocused = true
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Verification code input area")
            .accessibilityHint("Double tap to activate the keyboard and enter your 6-digit verification code")
            .accessibilityAddTraits(.isButton)

            Button(action: verifyOTP) {
                Text("Verify")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isOTPComplete() ? Color(hex: "924350") : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .disabled(!isOTPComplete())

            Button(action: resendCode) {
                Text(resendTimer > 0 ? "Resend in \(resendTimer)s" : "Didn't receive a code?")
                    .foregroundColor(resendTimer > 0 ? .gray : Color(hex: "924350"))
                    .padding(.top)
            }
            .disabled(resendTimer > 0)

            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: nil, dismissButton: .default(Text("OK")))
        }
        .onReceive(timer) { _ in
            if resendTimer > 0 {
                resendTimer -= 1
            }
        }
    }

    // MARK: Private

    @State private var otpString: String = ""
    @FocusState private var isFieldFocused: Bool
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var resendTimer = 0

    private let otpLength = 6
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private func isOTPComplete() -> Bool {
        return otpString.count == otpLength
    }

    private func verifyOTP() {
        Task {
            let success = await viewController?.verifyOTP(otp: otpString)
            if let success {
                if success {
                    await viewController?.navigate()
                } else {
                    alertTitle = "Invalid OTP"
                    showAlert = true
                }
            }
        }
    }

    private func resendCode() {
        Task {
            if let otpSent = await viewController?.resendOTP(), otpSent {
                resendTimer = 30
                alertTitle = "OTP Sent"
                showAlert = true
            }
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
                .stroke(isActive ? Color(hex: "924350") : Color.gray.opacity(0.3), lineWidth: isActive ? 2 : 1)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                )

            if index < otpString.count {
                let startIndex = otpString.startIndex
                let charIndex = otpString.index(startIndex, offsetBy: index)
                Text(String(otpString[charIndex]))
                    .font(.title2.weight(.semibold))
            } else if isActive {
                Rectangle()
                    .fill(Color(hex: "924350"))
                    .frame(width: 2, height: 24)
                    .opacity(showCursor ? 1 : 0)
                    .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: showCursor)
                    .onAppear {
                        showCursor = true
                    }
            }
        }
        .frame(width: 45, height: 55)
    }

    // MARK: Private

    @State private var showCursor = false

}

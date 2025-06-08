//
//  otpScreen.swift
//  MomCare
//
//  Created by Aryan Singh on 08/06/25.
//

import SwiftUI
import Combine

struct otpScreen: View {
    @State private var otpString: String = ""
    @FocusState private var isFieldFocused: Bool
    private let otpLength = 6
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Verification Code")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Enter the code we sent to your phone number")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // OTP Input Field
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
                
                // Actual input field (invisible)
                TextField("", text: $otpString)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($isFieldFocused)
                    .onChange(of: otpString) { _, newValue in
                        // Limit to maximum length
                        if newValue.count > otpLength {
                            otpString = String(newValue.prefix(otpLength))
                        }
                        
                        // Filter to numbers only
                        otpString = newValue.filter { "0123456789".contains($0) }
                    }
                    .onAppear {
                        // Making this optional since SMS autofill might make it unnecessary
                        // but keeping it as a fallback for when autofill doesn't happen
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
                Text("Didn't receive a code?")
                    .foregroundColor(Color(hex: "924350"))
                    .padding(.top)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func isOTPComplete() -> Bool {
        return otpString.count == otpLength
    }
    
    private func verifyOTP() {
        print("OTP Verification requested with code: \(otpString)")
        // Here you would add your verification logic
    }
    
    private func resendCode() {
        print("Resend code requested")
        // Here you would add your resend logic
    }
}

// A visual box for displaying one digit of the OTP
struct OTPBox: View {
    let index: Int
    let otpString: String
    let isActive: Bool
    
    // Cursor blinking state
    @State private var showCursor = false
    
    var body: some View {
        ZStack {
            // Box
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color(hex: "924350") : Color.gray.opacity(0.3), lineWidth: isActive ? 2 : 1)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                )
            
            // Text or cursor
            if index < otpString.count {
                // Show the digit
                let startIndex = otpString.startIndex
                let charIndex = otpString.index(startIndex, offsetBy: index)
                Text(String(otpString[charIndex]))
                    .font(.title2.weight(.semibold))
            } else if isActive {
                // Show blinking cursor
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
}

#Preview {
    otpScreen()
}

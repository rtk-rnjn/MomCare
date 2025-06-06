//
//  launchScreen.swift
//  MomCare
//
//  Created by Aryan Singh on 06/06/25.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    let pinkColor = Color(hex: "924350")
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // App logo from assets
                Image("AppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                // App name with stylish font
                Text("MomCare+")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(pinkColor)
                
                // Optional tagline
                Text("Supporting mothers every step of the way")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(pinkColor.opacity(0.8))
                    .padding(.top, 5)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5)) {
                    opacity = 1.0
                    scale = 1.0
                }
            }
        }
    }
}

// Include the color extension in each file so they're self-contained
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LaunchScreen()
}

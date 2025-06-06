//
//  FillingLoadingScreen.swift
//  MomCare
//
//  Created by Aryan Singh on 06/06/25.
//
import SwiftUI

struct FillingLoadingScreen: View {
    @State private var fillAmount: CGFloat = 0.0
    @State private var showMessage = false
    
    let pinkColor = Color(hex: "924350")
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // App logo
                Image("AppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .padding(.bottom, -10)
                
                // Loading title
                Text("Loading")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Color.gray.opacity(0.8))
                
                // App name with filling animation
                ZStack(alignment: .leading) {
                    // Outline version
                    Text("MomCare+")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color.gray.opacity(0.3))
                    
                    // Filling version
                    Text("MomCare+")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(pinkColor)
                        .mask(
                            GeometryReader { geo in
                                Rectangle()
                                    .fill(pinkColor)
                                    .frame(width: geo.size.width * fillAmount, height: geo.size.height)
                            }
                        )
                }
                
                // Optional message that appears when loading is almost complete
                Text("Almost there...")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color.gray)
                    .opacity(showMessage ? 1 : 0)
                    .animation(.easeIn(duration: 0.5), value: showMessage)
                
                // Progress percentage
                Text("\(Int(fillAmount * 100))%")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(pinkColor)
            }
        }
        .onReceive(timer) { _ in
            if fillAmount < 1.0 {
                fillAmount += 0.01
                
                // Show the "almost there" message at 70%
                if fillAmount > 0.7 && !showMessage {
                    showMessage = true
                }
                
                // Simulate some slowdown near the end to feel more realistic
                if fillAmount > 0.8 {
                    fillAmount += 0.002
                }
            } else {
                timer.upstream.connect().cancel()
            }
        }
    }
}

// Include the color extension in each file so they're self-contained


#Preview {
    FillingLoadingScreen()
}

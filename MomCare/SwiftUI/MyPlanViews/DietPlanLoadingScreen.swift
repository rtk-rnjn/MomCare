//
//  DietPlanLoadingScreen.swift
//  MomCare
//
//  Created by Aryan Singh on 06/06/25.
//

import SwiftUI

struct DietPlanLoadingScreen: View {
    @State private var currentText = 0
    var stopAnimation = false
    let pinkColor: Color = .CustomColors.mutedRaspberry

    let messages = [
        "Analyzing your nutritional needs...",
        "Creating personalized meal options...",
        "Optimizing for maternal health...",
        "Finalizing your perfect meal plan...",
        "Almost ready..."
    ]

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Image("AppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)

                Text("Curating Your Diet Plan")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(pinkColor)

                Text(messages[currentText])
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .animation(.easeInOut, value: currentText)
                    .id(currentText)

                HStack(spacing: 25) {
                    FoodToAnimate(symbolName: "applelogo", delay: 0.0)
                    FoodToAnimate(symbolName: "carrot.fill", delay: 0.3)
                    FoodToAnimate(symbolName: "leaf.fill", delay: 0.6)
                    FoodToAnimate(symbolName: "drop.fill", delay: 0.9)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .onAppear {
            startMessageAnimation()
        }
    }

    @MainActor private func startMessageAnimation() {
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task { @MainActor in
                withAnimation {
                    currentText = (currentText + 1) % messages.count
                }
            }
        }
        timer.fire()
    }
}

struct FoodToAnimate: View {
    let symbolName: String
    let delay: Double
    @State private var isPulsing = false

    let pinkColor: Color = .CustomColors.mutedRaspberry

    var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: 24))
            .foregroundColor(pinkColor)
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .opacity(isPulsing ? 1.0 : 0.7)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever()
                    .delay(delay),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

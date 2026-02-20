//
//  BreathingCardView.swift
//  MomCare
//
//  Created by Aryan singh on 19/02/26.
//

import SwiftUI

struct BreathingCardView: View {

    // MARK: Internal

    var onInfo: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Beginner")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)

                    Text("Breathing")
                        .font(.title3.weight(.bold))

                    Text("\(Int(completionProgress * 100))% completed")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)

                    startButton
                }

                Spacer()

                lungsIcon
            }
        }
        .padding(18)
        .background(cardBackground)
        .shadow(color: darkAccentColor.opacity(0.08), radius: 8, x: 0, y: 4)
        .onAppear { updateProgress() }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

    @State private var completionProgress: Double = 0
    @State private var startBreathingPlayer: Bool = false

}

private extension BreathingCardView {
    var header: some View {
        HStack {
            Spacer()
            Button(action: onInfo) {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(darkAccentColor.opacity(0.5))
            }
        }
    }

    var startButton: some View {
        Button {
            startBreathingPlayer = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "play.fill")
                Text(completionProgress >= 1 ? "Replay" : "Start")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(darkAccentColor)
            )
        }
        .fullScreenCover(isPresented: $startBreathingPlayer, onDismiss: {
            updateProgress()
        }) {
            BreathingExerciseView()
        }
    }

    var lungsIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(accentColor.opacity(0.25))

            Image(systemName: "lungs.fill")
                .font(.system(size: 30))
                .foregroundColor(darkAccentColor)
        }
        .frame(width: 80, height: 80)
    }

    func updateProgress() {
        completionProgress =
            healthKitHandler.fetchBreathingCompletionDuration(for: Date())
                / healthKitHandler.breathingTargetInSeconds

        completionProgress = min(completionProgress, 1.0)
    }

    var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(hex: "D0E1F0"))
    }

    var accentColor: Color {
        Color(hex: "8BBBD4")
    }

    var darkAccentColor: Color {
        Color(hex: "4A7A9B")
    }
}

import SwiftUI

struct BreathingCardView: View {

    // MARK: Internal

    var onInfo: () -> Void = {}

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .bottom, spacing: 16) {
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

                    Button {
                        startBreathingPlayer = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .accessibilityHidden(true)
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
                    .accessibilityLabel(completionProgress >= 1 ? "Replay breathing exercise" : "Start breathing exercise")
                    .accessibilityIdentifier("startBreathingButton")
                    .fullScreenCover(isPresented: $startBreathingPlayer) {
                        updateProgress()
                    } content: {
                        BreathingExerciseView()
                    }
                }
                .padding(16)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(reduceTransparency ? accentColor : accentColor.opacity(0.25))

                    Image(systemName: "lungs.fill")
                        .font(.title)
                        .foregroundColor(darkAccentColor)
                }
                .frame(width: 80, height: 80)
                .padding(16)
                .accessibilityHidden(true)
            }

            Button(action: onInfo) {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(darkAccentColor.opacity(0.5))
            }
            .accessibilityLabel("Breathing exercise information")
            .accessibilityHint("Shows details about this breathing exercise")
            .frame(width: 44, height: 44)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "D0E1F0"))
        )
        .shadow(color: darkAccentColor.opacity(0.08), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Breathing exercise, Beginner")
        .accessibilityValue("\(Int(completionProgress * 100)) percent completed")
        .onAppear { updateProgress() }
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler

    @State private var completionProgress: Double = 0
    @State private var startBreathingPlayer: Bool = false
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var accentColor: Color {
        Color(hex: "8BBBD4")
    }

    private var darkAccentColor: Color {
        Color(hex: "4A7A9B")
    }

    private func updateProgress() {
        completionProgress = contentServiceHandler.fetchBreathingCompletionDuration(for: Date()) / contentServiceHandler.breathingTargetInSeconds
        completionProgress = min(completionProgress, 1.0)
    }
}

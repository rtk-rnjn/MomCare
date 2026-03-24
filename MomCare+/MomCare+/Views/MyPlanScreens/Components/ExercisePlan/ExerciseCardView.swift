import AVKit
import SwiftUI

struct ExerciseCardView: View {
    // MARK: Internal

    let userExerciseModel: UserExerciseModel
    let onTapInfo: () -> Void
    let onVideoDismiss: (AVPlayer) async -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(exercise?.level.rawValue ?? "")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)

                    Text(exercise?.name ?? "Exercise")
                        .font(.title3.weight(.bold))

                    Text("\(Int(completionProgress * 100))% completed")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 12)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: completionProgress)

                    Button {
                        startExercisePlayer = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .accessibilityHidden(true)
                            Text(completionProgress >= 1 ? "Replay" : "Start")
                                .contentTransition(reduceMotion ? .identity : .interpolate)
                                .animation(reduceMotion ? nil : .easeInOut, value: completionProgress)
                                .accessibilityHidden(true)
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
                    .accessibilityLabel(completionProgress >= 1 ? "Replay \(exercise?.name ?? "exercise")" : "Start \(exercise?.name ?? "exercise")")
                    .accessibilityIdentifier("startExerciseButton")
                    .fullScreenCover(isPresented: $startExercisePlayer) {
                        NavigationStack {
                            playerView
                        }
                    }
                }
                .padding(16)

                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(reduceTransparency ? accentColor : accentColor.opacity(0.25))

                    if let uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    } else {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.title)
                            .foregroundColor(darkAccentColor)
                    }
                }
                .frame(width: 80, height: 80)
                .padding(16)
                .accessibilityHidden(true)
            }

            Button(action: onTapInfo) {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(darkAccentColor.opacity(0.5))
            }
            .accessibilityLabel("Exercise information")
            .accessibilityHint("Shows details about this exercise")
            .frame(width: 44, height: 44)
            .padding(.trailing, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "F0D5C8"))
        )
        .shadow(color: darkAccentColor.opacity(0.08), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(exercise.map { "\($0.name), \($0.level.rawValue)" } ?? "Exercise")
        .accessibilityValue("\(Int(completionProgress * 100)) percent completed")
        .task { await loadExercise() }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "An unexpected error occurred.")
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    @State private var exercise: ExerciseModel?
    @State private var exerciseURL: URL?
    @State private var uiImage: UIImage?
    @State private var completionProgress: Double = 0
    @State private var startExercisePlayer: Bool = false
    @State private var avPlayer: AVPlayer?
    @State private var showErrorAlert = false
    @State private var alertMessage: String?

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var accentColor: Color {
        Color(hex: "D4A08A")
    }

    private var darkAccentColor: Color {
        Color(hex: "9B6B52")
    }

    private var playerView: some View {
        VideoPlayer(player: avPlayer)
            .onAppear { avPlayer?.play() }
            .accessibilityLabel("Exercise video player")
            .navigationTitle(exercise?.name ?? "Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        defer { startExercisePlayer = false }
                        guard let avPlayer else {
                            return
                        }

                        avPlayer.pause()

                        Task {
                            await onVideoDismiss(avPlayer)
                            let currentTime = avPlayer.currentTime().seconds
                            completionProgress = currentTime / (exercise?.videoDurationSeconds ?? 0)
                        }
                    }
                    .accessibilityLabel("Close video")
                    .accessibilityIdentifier("closeVideoButton")
                    .padding(.top, 20)
                }
            }
    }

    private func loadExercise() async {
        exercise = await userExerciseModel.exerciseModel
        exerciseURL = await userExerciseModel.url

        if let url = exerciseURL {
            avPlayer = AVPlayer(url: url)
        }

        uiImage = await exercise?.image
        completionProgress = await userExerciseModel.completionPercentage
    }
}

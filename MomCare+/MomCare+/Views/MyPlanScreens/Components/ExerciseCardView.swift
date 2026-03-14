import AVKit
import SwiftUI

struct ExerciseCardView: View {

    // MARK: Internal

    var userExerciseModel: UserExerciseModel?
    var onInfo: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(exercise?.level.rawValue ?? "")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)

                    Text(exercise?.name ?? "Exercise")
                        .font(.title3.weight(.bold))

                    Text("\(Int(completionProgress * 100))% completed")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)

                    Button {
                        startExercisePlayer = true
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
                    .accessibilityLabel(completionProgress >= 1 ? "Replay \(exercise?.name ?? "exercise")" : "Start \(exercise?.name ?? "exercise")")
                    .accessibilityIdentifier("startExerciseButton")
                    .fullScreenCover(isPresented: $startExercisePlayer) {
                        playerView
                    }
                }

                Spacer()
                VStack(alignment: .trailing) {
                    Button(action: onInfo) {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .foregroundColor(darkAccentColor.opacity(0.5))
                    }
                    .accessibilityLabel("Exercise information")
                    .accessibilityHint("Shows details about this exercise")
                    .frame(minWidth: 44, minHeight: 44)

                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(accentColor.opacity(0.25))

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
                    .accessibilityHidden(true)
                }
            }
        }
        .padding(18)
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

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

    @State private var exercise: ExerciseModel?
    @State private var exerciseURL: URL?
    @State private var uiImage: UIImage?
    @State private var completionProgress: Double = 0
    @State private var startExercisePlayer: Bool = false
    @State private var avPlayer: AVPlayer?
    @State private var showErrorAlert = false
    @State private var alertMessage: String?

    private var accentColor: Color {
        Color(hex: "D4A08A")
    }

    private var darkAccentColor: Color {
        Color(hex: "9B6B52")
    }

    private var playerView: some View {
        ZStack(alignment: .topTrailing) {
            VideoPlayer(player: avPlayer)
                .ignoresSafeArea()
                .onAppear { avPlayer?.play() }
                .accessibilityLabel("Exercise video player")

            Button {
                avPlayer?.pause()
                Task {
                    do {
                        try await updateDuration()
                    } catch {
                        alertMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                    startExercisePlayer = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding()
            }
            .accessibilityLabel("Close video")
            .accessibilityIdentifier("closeVideoButton")
            .padding(.top, 20)
        }
    }

    private func loadExercise() async {
        guard let userExerciseModel else { return }

        exercise = await userExerciseModel.exerciseModel
        exerciseURL = await userExerciseModel.url

        if let url = exerciseURL {
            avPlayer = AVPlayer(url: url)
        }

        completionProgress = healthKitHandler.fetchExerciseCompletionDuration(id: userExerciseModel.id) / (exercise?.videoDurationSeconds ?? 1.0)

        completionProgress = min(completionProgress, 1.0)
        uiImage = await exercise?.image
    }

    private func updateDuration() async throws {
        guard let id = userExerciseModel?.exerciseId,
              let current = avPlayer?.currentTime().seconds else { return }

        try await healthKitHandler.updateExerciseCompletionDuration(id: id, duration: current)
        completionProgress = current / (exercise?.videoDurationSeconds ?? 1.0)
    }

}

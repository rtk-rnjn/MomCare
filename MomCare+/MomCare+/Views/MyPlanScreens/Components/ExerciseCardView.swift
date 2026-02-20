import AVKit
import SwiftUI

struct ExerciseCardView: View {

    // MARK: Internal

    @Environment(\.dismiss) var dismiss

    var userExerciseModel: UserExerciseModel?
    var onInfo: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            HStack(spacing: 16) {
                contentSection

                Spacer()

                imageSection
            }
        }
        .padding(18)
        .background(cardBackground)
        .shadow(color: darkAccentColor.opacity(0.08), radius: 8, x: 0, y: 4)
        .task { await loadExercise() }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

    @State private var exercise: ExerciseModel? = nil
    @State private var exerciseURL: URL? = nil
    @State private var uiImage: UIImage? = nil
    @State private var completionProgress: Double = 0
    @State private var startExercisePlayer: Bool = false
    @State private var avPlayer: AVPlayer? = nil

}

private extension ExerciseCardView {
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

    var contentSection: some View {
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

            startButton
        }
    }

    var startButton: some View {
        Button {
            startExercisePlayer = true
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
        .fullScreenCover(isPresented: $startExercisePlayer) {
            playerView
        }
    }

    var playerView: some View {
        ZStack(alignment: .topTrailing) {
            VideoPlayer(player: avPlayer)
                .ignoresSafeArea()
                .onAppear { avPlayer?.play() }

            Button {
                avPlayer?.pause()
                Task { try? await updateDuration() }
                startExercisePlayer = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding()
            }
            .padding(.top, 20)
        }
    }

    var imageSection: some View {
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
                    .font(.system(size: 30))
                    .foregroundColor(darkAccentColor)
            }
        }
        .frame(width: 80, height: 80)
    }
}

private extension ExerciseCardView {
    func loadExercise() async {
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

    func updateDuration() async throws {
        guard let id = userExerciseModel?.exerciseId,
              let current = avPlayer?.currentTime().seconds else { return }

        try await healthKitHandler.updateExerciseCompletionDuration(id: id, duration: current)
        completionProgress = current / (exercise?.videoDurationSeconds ?? 1.0)
    }

    var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(hex: "F0D5C8"))
    }

    var accentColor: Color {
        Color(hex: "D4A08A")
    }

    var darkAccentColor: Color {
        Color(hex: "9B6B52")
    }
}

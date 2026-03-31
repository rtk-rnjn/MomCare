import HealthKit
import SwiftUI
import TipKit

struct MoodNestView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            ZStack {
                moodNestViewModel.backgroundColor
                    .ignoresSafeArea()
                    .accessibilityHidden(true)

                VStack {
                    Spacer()

                    Text("How are you feeling right now?")
                        .font(.title.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 25)
                        .accessibilityAddTraits(.isHeader)

                    Spacer()

                    MoodFaceView(
                        isSemiCircleEyes: moodNestViewModel.useSemiCircleEyes,
                        faceColor: moodNestViewModel.faceColor,
                        eyeScale: moodNestViewModel.eyeScale,
                        leftEyeRotation: moodNestViewModel.eyeRotationLeft,
                        rightEyeRotation: moodNestViewModel.eyeRotationRight,
                        smileRotation: moodNestViewModel.smileRotation
                    )
                        .frame(maxHeight: 220)
                        .accessibilityHidden(true)

                    Spacer()

                    moodButtons

                    Spacer()
                }
                .padding(.horizontal, 20)
            }

            .safeAreaInset(edge: .bottom) {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    controlState.showingMoodnestPlaylistsView = true
                } label: {
                    Text("Set Mood ✓")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(moodNestViewModel.faceColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(moodNestViewModel.backgroundColor)
                .accessibilityLabel("Set mood to \(moodNestViewModel.mood.rawValue)")
                .accessibilityHint("Opens playlist recommendations for your mood")
                .accessibilityIdentifier("setMoodButton")
            }
            .toolbar {
                if stateOfMindPermission == .notDetermined {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            askForPermission()
                        } label: {
                            Label("Permission Error", systemImage: "exclamationmark.triangle")
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $controlState.showingMoodnestPlaylistsView) {
                MoodNestPlaylistsView(mood: moodNestViewModel.mood)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Private

    @StateObject private var moodNestViewModel: MoodNestViewModel = .init()
    @EnvironmentObject private var contentService: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var stateOfMindPermission: HKAuthorizationStatus {
        contentService.healthStore.authorizationStatus(for: .stateOfMindType())
    }

    private var moodButtons: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0...3, id: \.self) { index in
                let mood = MoodType.from(int: index)
                let isSelected = moodNestViewModel.sliderValue == Double(index)

                Button {
                    moodNestViewModel.sliderValue = Double(index)

                    if reduceMotion {
                        moodNestViewModel.updateMood()
                    } else {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            moodNestViewModel.updateMood()
                        }
                    }

                } label: {
                    VStack(spacing: 8) {
                        Text(mood.emoji)
                            .font(.system(size: 34))

                        Text(mood.rawValue)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .foregroundStyle(isSelected ? .black : .white)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                isSelected
                                ? Color.white
                                : Color.white.opacity(0.2)
                            )
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mood.rawValue)
            }
        }
        .padding(.horizontal, 30)
        .accessibilityLabel("Mood selector")
        .accessibilityValue(moodNestViewModel.mood.rawValue)
        .accessibilityHint("Select a mood")
        .accessibilityIdentifier("moodButtons")
    }

    private func askForPermission() {
        contentService.healthStore.requestAuthorization(toShare: [.stateOfMindType()], read: [.stateOfMindType()]) { _, _ in
        }
    }
}

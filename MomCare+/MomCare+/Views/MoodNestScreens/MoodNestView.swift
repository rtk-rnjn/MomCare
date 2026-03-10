import SwiftUI

struct MoodNestView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            ZStack {
                moodNestViewModel.backgroundColor.ignoresSafeArea()
                    .accessibilityHidden(true)

                VStack(spacing: 32) {
                    Spacer(minLength: 30)

                    Text("How are you feeling right now?")
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 25)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("moodQuestion")
                        .accessibilityHint("Asks the user to select their current mood")

                    Spacer()

                    MoodFaceView(moodNestViewModel: moodNestViewModel)
                        .frame(height: 240)
                        .accessibilityHidden(true)

                    Text(moodNestViewModel.mood.rawValue)
                        .font(.headline)
                        .accessibilityLabel("Current mood: \(moodNestViewModel.mood.rawValue)")
                        .accessibilityAddTraits(.updatesFrequently)

                    Slider(value: $moodNestViewModel.sliderValue, in: 0 ... 3, step: 1)
                        // Imagine you can not remove Haptic feedback, is you are using step: Int
                        .onChange(of: moodNestViewModel.sliderValue) {
                            if reduceMotion {
                                moodNestViewModel.updateMood()
                            } else {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    moodNestViewModel.updateMood()
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 30)
                        .tint(.white)
                        .accessibilityLabel("Mood selector")
                        .accessibilityValue(moodNestViewModel.mood.rawValue)
                        .accessibilityHint("Swipe left or right to change your mood")
                        .accessibilityIdentifier("moodSlider")

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
                    .padding(.horizontal, 32)
                    .padding(.top, 30)
                    .accessibilityLabel("Set mood to \(moodNestViewModel.mood.rawValue)")
                    .accessibilityHint("Opens playlist recommendations for your mood")
                    .accessibilityIdentifier("setMoodButton")
                    .navigationDestination(isPresented: $controlState.showingMoodnestPlaylistsView) {
                        MoodNestPlaylistsView(mood: moodNestViewModel.mood)
                    }
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: Private

    @StateObject private var moodNestViewModel: MoodNestViewModel = .init()
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

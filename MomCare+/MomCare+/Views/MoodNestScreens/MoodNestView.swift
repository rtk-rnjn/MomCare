import SwiftUI
import TipKit

struct MoodNestView: View {

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

                    MoodFaceView(moodNestViewModel: moodNestViewModel)
                        .frame(maxHeight: 220)
                        .accessibilityHidden(true)

                    Spacer()

                    Text(moodNestViewModel.mood.rawValue)
                        .font(.headline)
                        .accessibilityLabel("Current mood: \(moodNestViewModel.mood.rawValue)")
                        .accessibilityAddTraits(.updatesFrequently)

                    Spacer()

                    Slider(value: $moodNestViewModel.sliderValue, in: 0...3, step: 1)
                        .onChange(of: moodNestViewModel.sliderValue) {
                            if reduceMotion {
                                moodNestViewModel.updateMood()
                            } else {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    moodNestViewModel.updateMood()
                                }
                            }
                        }
                        .popoverTip(sliderTip, arrowEdge: .bottom)
                        .padding(.horizontal, 40)
                        .tint(.white)
                        .accessibilityLabel("Mood selector")
                        .accessibilityValue(moodNestViewModel.mood.rawValue)
                        .accessibilityHint("Swipe left or right to change your mood")
                        .accessibilityIdentifier("moodSlider")

                    Spacer()
                }
                .padding(.horizontal, 20)
            }

            // ✅ Bottom button (safe & Apple-compliant)
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

            .navigationDestination(isPresented: $controlState.showingMoodnestPlaylistsView) {
                MoodNestPlaylistsView(mood: moodNestViewModel.mood)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: Private

    @StateObject private var moodNestViewModel: MoodNestViewModel = .init()
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let sliderTip: MomCareTips.MoodNest.MoodNestSliderTip = .init()
}

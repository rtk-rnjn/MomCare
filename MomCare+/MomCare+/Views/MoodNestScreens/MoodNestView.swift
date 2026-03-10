import SwiftUI

struct MoodNestView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            ZStack {
                vm.backgroundColor.ignoresSafeArea()
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

                    Spacer()

                    MoodFaceView(vm: vm)
                        .frame(height: 240)
                        .accessibilityHidden(true)

                    Text(vm.mood.rawValue)
                        .font(.headline)
                        .accessibilityLabel("Current mood: \(vm.mood.rawValue)")
                        .accessibilityAddTraits(.updatesFrequently)

                    Slider(value: $vm.sliderValue, in: 0 ... 3, step: 1)
                        .onChange(of: vm.sliderValue) {
                            if reduceMotion {
                                vm.updateMood()
                            } else {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    vm.updateMood()
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 30)
                        .tint(.white)
                        .accessibilityLabel("Mood selector")
                        .accessibilityValue(vm.mood.rawValue)
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
                            .background(vm.faceColor)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 30)
                    .accessibilityLabel("Set mood to \(vm.mood.rawValue)")
                    .accessibilityHint("Opens playlist recommendations for your mood")
                    .accessibilityIdentifier("setMoodButton")
                    .navigationDestination(isPresented: $controlState.showingMoodnestPlaylistsView) {
                        MoodNestPlaylistsView(mood: vm.mood)
                    }
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: Private

    @StateObject private var vm: MoodNestViewModel = .init()
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

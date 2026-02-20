import SwiftUI

struct MoodNestView: View {

    // MARK: Internal

    var body: some View {
        NavigationStack {
            ZStack {
                vm.backgroundColor.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer(minLength: 30)

                    Text("How are you feeling right now?")
                        .font(.title.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 25)

                    Spacer()

                    MoodFaceView(vm: vm)
                        .frame(height: 240)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Mood face")
                        .accessibilityValue(vm.mood.rawValue)

                    Text(vm.mood.rawValue)
                        .font(.headline)

                    Slider(value: $vm.sliderValue, in: 0 ... 3, step: 1)
                        .onChange(of: vm.sliderValue) {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                vm.updateMood()
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 30)
                        .tint(.white)
                        .accessibilityLabel("Mood selector")
                        .accessibilityValue(vm.mood.rawValue)
                        .accessibilityHint("Swipe left or right to change your mood")

                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        navigateToResult = true
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
                    .navigationDestination(isPresented: $navigateToResult) {
                        MoodResultView(mood: vm.mood)
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
    @State private var navigateToResult = false

}

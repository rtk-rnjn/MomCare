import HealthKit
import SwiftUI
import TipKit

struct MoodNestView: View {

    @StateObject private var moodNestViewModel = MoodNestViewModel()

    // ✅ ONLY trigger now (for center emoji)
    @State private var faceTrigger = UUID()
    @State private var isFaceAngryAnimating = false
    @State private var isFaceSadAnimating = false
    @State private var isSadAnimating = false

    @EnvironmentObject private var contentService: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState

    private let primary = Color(hex: "#924350")
    private let secondary = Color(hex: "#FBE8E5")

    var body: some View {
        NavigationStack {
            ZStack {
                secondary.ignoresSafeArea()

                VStack {
                    title
                        .padding(.top, 60)

                    Spacer(minLength: 30)

                    faceWithSelector

                    Spacer(minLength: 100)
                }
            }

            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        controlState.showingMoodnestPlaylistsView = true
                    } label: {
                        Text("Next Step")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
                .background(secondary)
            }

            .navigationDestination(isPresented: $controlState.showingMoodnestPlaylistsView) {
                MoodNestPlaylistsView(mood: moodNestViewModel.selectedMood)
            }
        }
    }
}

// MARK: - UI
private extension MoodNestView {

    var title: some View {
        Text("What is your mood?")
            .font(.title.weight(.semibold))
            .padding(.top, 60)
    }

    var faceWithSelector: some View {
        VStack(spacing: 0) {

            ZStack {
                Circle()
                let angryTint = Color(red: 0.85, green: 0.35, blue: 0.35)
                let sadTint = Color(red: 0.75, green: 0.85, blue: 1.0)

                Circle()
                    .fill(
                        moodNestViewModel.selectedMood == .angry && isFaceAngryAnimating
                        ? angryTint
                        : moodNestViewModel.selectedMood == .sad && isFaceSadAnimating
                            ? sadTint
                            : moodNestViewModel.backgroundColor
                    )
                    .animation(.easeInOut(duration: 0.25), value: isFaceAngryAnimating)
                    .animation(.easeInOut(duration: 0.25), value: isFaceSadAnimating)
                    .frame(width: 220, height: 220)
                
                MoodFaceView(
                    mood: moodNestViewModel.selectedMood,
                    trigger: faceTrigger,
                    faceColor: moodNestViewModel.faceColor,
                    isSemiCircleEyes: moodNestViewModel.useSemiCircleEyes,
                    eyeScale: moodNestViewModel.eyeScale,
                    leftEyeRotation: moodNestViewModel.eyeRotationLeft,
                    rightEyeRotation: moodNestViewModel.eyeRotationRight,
                    smileRotation: moodNestViewModel.smileRotation
                )
                .frame(width: 150, height: 120)
            }

            Text(moodNestViewModel.selectedMood.rawValue)
                .font(.headline)
                .padding(.top, 12)

            moodArc
                .padding(.top, 10)
        }
    }

    var moodArc: some View {
        GeometryReader { geo in
            let size = geo.size
            let center = CGPoint(x: size.width / 2, y: size.height * 0.38)
            let radius: CGFloat = size.width * 0.36

            let moods: [MoodType] = [.happy, .stressed, .sad, .angry]

            ZStack {

                Path {
                    $0.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(30),
                        endAngle: .degrees(150),
                        clockwise: false
                    )
                }
                .stroke(Color.gray.opacity(0.25), lineWidth: 2)

                ForEach(moods.indices, id: \.self) { index in
                    let mood = moods[index]

                    let angleStep = (160.0 - 20.0) / Double(moods.count - 1)
                    let angle = (160.0 - Double(index) * angleStep) * .pi / 180

                    let x = center.x + cos(angle) * radius
                    let y = center.y + sin(angle) * radius

                    moodButton(for: mood)
                        .position(x: x, y: y)
                }
            }
        }
        .frame(height: 170)
    }

    // ✅ CLEAN BUTTON (NO ANIMATION STATES)
    func moodButton(for mood: MoodType) -> some View {
        let isSelected = moodNestViewModel.selectedMood == mood

        return ZStack {

            // OUTER
            Circle()
                .fill(
                    color(for: mood)
                        .opacity(isSelected ? 0.25 : 0.12)
                )
                .frame(width: isSelected ? 70 : 52)

            // INNER
            Circle()
                .fill(color(for: mood))
                .frame(width: isSelected ? 58 : 44)

            miniFace(for: mood, isSelected: isSelected)
        }
        .scaleEffect(isSelected ? 1.12 : 0.9)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            // ✅ Step 1: update mood FIRST
            withAnimation(.spring()) {
                moodNestViewModel.selectMood(mood)
            }

            // ✅ Step 2: trigger animation AFTER tiny delay (fixes first-tap bug)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                faceTrigger = UUID()
            }

            // 🔴 Step 3: delayed background animation
            if mood == .angry {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    isFaceAngryAnimating = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                    isFaceAngryAnimating = false
                }
            }
            if mood == .sad {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    isSadAnimating = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isSadAnimating = false
                }
            }
        }
    }

    // MINI FACE (STATIC NOW)
    @ViewBuilder
    func miniFace(for mood: MoodType, isSelected: Bool) -> some View {

        let size: CGFloat = isSelected ? 36 : 28

        ZStack {
            Circle()
                .fill(color(for: mood))
                .frame(width: size * 2.2, height: size * 2.2)

            MiniMoodFaceView(
                mood: mood,
                color: Color(hex: "#6B3A35"),
                isActive: isSelected
            )
            .frame(width: 28, height: 28)
        }
    }

    func color(for mood: MoodType) -> Color {
        switch mood {
        case .happy: MoodColors.happyBackgroundSwiftUI
        case .sad: MoodColors.sadBackgroundSwiftUI
        case .stressed: MoodColors.stressedBackgroundSwiftUI
        case .angry: MoodColors.angryBackgroundSwiftUI
        }
    }
}

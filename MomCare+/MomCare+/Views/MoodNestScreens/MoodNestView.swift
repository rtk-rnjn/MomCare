import HealthKit
import SwiftUI
import TipKit

struct MoodNestView: View {

    @StateObject private var moodNestViewModel = MoodNestViewModel()
    @State private var angryTrigger = UUID()
    @State private var sadTrigger = UUID()
    @State private var isAngryFlashing = false
    
    @EnvironmentObject private var contentService: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

            // My Giant Face
            ZStack {
                Circle()
                    .fill(moodNestViewModel.backgroundColor)
                    .frame(width: 220, height: 220)

                MoodFaceView(
                    isSemiCircleEyes: moodNestViewModel.useSemiCircleEyes,
                    faceColor: moodNestViewModel.faceColor,
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

            let moods = MoodType.allCases

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

                ForEach(Array(moods.enumerated()), id: \.element) { index, mood in

                    let angleStep = (160.0 - 20.0) / Double(moods.count - 1)
                    let angle = (20.0 + Double(index) * angleStep) * .pi / 180

                    let x = center.x + cos(angle) * radius
                    let y = center.y + sin(angle) * radius

                    moodButton(for: mood)
                        .position(x: x, y: y)
                }
            }
        }
        .frame(height: 170)
    }

    func moodButton(for mood: MoodType) -> some View {
        let isSelected = moodNestViewModel.selectedMood == mood

        return ZStack {
            
            let softRed = Color(red: 0.85, green: 0.35, blue: 0.35)
            let isAngryFlash = mood == .angry && isAngryFlashing

            Circle()
                .fill(
                    isAngryFlash
                    ? softRed.opacity(0.15) // 🔻 reduce intensity
                    : color(for: mood).opacity(isSelected ? 0.25 : 0.12)
                )
                .frame(width: isSelected ? 70 : 52)
                .animation(.easeInOut(duration: 0.2), value: isAngryFlashing)

            // INNER
            Circle()
                .fill(
                    isAngryFlash
                    ? softRed
                    : color(for: mood)
                )
                .frame(width: isSelected ? 58 : 44)
            
            miniFace(for: mood, isSelected: isSelected)
        }
        .scaleEffect(isSelected ? 1.12 : 0.9)

        // 🔥 THIS is the key
        .animation(.easeInOut(duration: 0.35), value: isAngryFlashing)

        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)

        .onTapGesture {
            withAnimation(.spring()) {
                moodNestViewModel.selectMood(mood)
            }

            if mood == .angry {
                angryTrigger = UUID()

                withAnimation(.easeInOut(duration: 0.2)) {
                    isAngryFlashing = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isAngryFlashing = false
                    }
                }
            }

            if mood == .sad {
                sadTrigger = UUID()
            }

            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    // MARK: - FACE CONFIG
    func faceConfig(for mood: MoodType) -> (
        isSemiCircle: Bool,
        eyeScale: CGSize,
        leftEyeRotation: Angle,
        rightEyeRotation: Angle,
        smileRotation: Angle
    ) {
        switch mood {

        case .happy:
            return (false, CGSize(width: 0.9, height: 0.9), .degrees(0), .degrees(0), .degrees(0))

        case .sad:
            return (false, CGSize(width: 0.85, height: 0.85), .degrees(0), .degrees(0), .degrees(180))

        case .stressed:
            return (false, CGSize(width: 0.7, height: 0.7), .degrees(0), .degrees(0), .degrees(10))

        case .angry:
            return (false, CGSize(width: 0.9, height: 0.7), .degrees(-12), .degrees(12), .degrees(180))
        }
    }

    // MARK: - MINI FACE (FIXED)
    @ViewBuilder
    func miniFace(for mood: MoodType, isSelected: Bool) -> some View {

        let size: CGFloat = isSelected ? 36 : 28
        
        // 🌸 Gentle, theme-matching angry red
        let gentleAngryRed = Color(hex: "#E8897F")

        ZStack {
            Circle()
                .fill(
                    mood == .angry && isAngryFlashing
                    ? gentleAngryRed.opacity(0.9) // softer than pure red
                    : color(for: mood)
                )
                .animation(.easeInOut(duration: 0.25), value: isAngryFlashing)
                .frame(width: size * 2.2, height: size * 2.2)

            MiniMoodFaceView(
                mood: mood,
                color: Color(hex: "#6B3A35"),
                isActive: isSelected,
                trigger: mood == .angry ? angryTrigger :
                         mood == .sad ? sadTrigger :
                         UUID()
            )
            .frame(width: 28, height: 28)
        }
    }

    // MARK: - COLOR FIX
    func color(for mood: MoodType) -> Color {
        switch mood {
        case .happy: MoodColors.happyBackgroundSwiftUI
        case .sad: MoodColors.sadBackgroundSwiftUI
        case .stressed: MoodColors.stressedBackgroundSwiftUI
        case .angry: MoodColors.angryBackgroundSwiftUI
        }
    }
}

// MARK: - HealthKit
private extension MoodNestView {

    var stateOfMindPermission: HKAuthorizationStatus {
        contentService.healthStore.authorizationStatus(for: .stateOfMindType())
    }

    func askForPermission() {
        contentService.healthStore.requestAuthorization(
            toShare: [.stateOfMindType()],
            read: [.stateOfMindType()]
        ) { _, _ in }
    }
}

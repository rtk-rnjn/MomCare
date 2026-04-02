import HealthKit
import SwiftUI
import TipKit

struct MoodNestView: View {

    // MARK: - State

    @StateObject private var moodNestViewModel = MoodNestViewModel()

    @EnvironmentObject private var contentService: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let primary = Color(hex: "#924350")
    private let secondary = Color(hex: "#FBE8E5")

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                secondary.ignoresSafeArea()

                VStack {
                    
                    // 👇 TITLE (controlled)
                    title
                        .padding(.top, 60)

                    Spacer(minLength: 10)

                    // 👇 FACE + ARC (main content block)
                    faceWithSelector

                    Spacer(minLength: 80) // 👈 pushes arc toward button nicely
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    
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
                .padding(.top, 8)
                .padding(.bottom, 100) // 👈 KEY FIX
                .background(secondary)
            }

            // MARK: Navigation

            .navigationDestination(isPresented: $controlState.showingMoodnestPlaylistsView) {
                MoodNestPlaylistsView(mood: moodNestViewModel.selectedMood)
            }

            // MARK: Permission

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

            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - UI Components

private extension MoodNestView {
    
    var title: some View {
        Text("What is your mood?")
            .font(.title.weight(.semibold))
            .multilineTextAlignment(.center)
            .padding(.top, 80)
            .padding(.bottom, 10)// 👈 clean, predictable, device-safe
    }
    
    var faceWithSelector: some View {
        VStack(spacing: 0) {
            
            ZStack {
                Circle()
                    .fill(moodNestViewModel.backgroundColor)
                    .frame(width: 220, height: 220)
                
                VStack(spacing: 8) {
                    
                    HStack(spacing: 26) {
                        EyeView(
                            isSemiCircleEyes: moodNestViewModel.useSemiCircleEyes,
                            faceColor: moodNestViewModel.faceColor,
                            eyeScale: moodNestViewModel.eyeScale,
                            rotation: moodNestViewModel.eyeRotationLeft
                        )
                        .frame(width: 85, height: 85)
                        
                        EyeView(
                            isSemiCircleEyes: moodNestViewModel.useSemiCircleEyes,
                            faceColor: moodNestViewModel.faceColor,
                            eyeScale: moodNestViewModel.eyeScale,
                            rotation: moodNestViewModel.eyeRotationRight
                        )
                        .frame(width: 85, height: 85)
                    }
                    .offset(y: 6)
                    
                    SmileView(
                        rotation: moodNestViewModel.smileRotation,
                        color: moodNestViewModel.faceColor
                    )
                    .offset(y: -1)
                }
            }
            
            Text(moodNestViewModel.selectedMood.rawValue)
                .font(.headline)
                .padding(.top, 12)
            
            // 👇 ARC IS NOW ATTACHED TO FACE
            moodArc
                .padding(.top, 10)
        }
    }
    
    var moodArc: some View {
        GeometryReader { geo in
            
            let size = geo.size
            let center = CGPoint(
                x: size.width / 2,
                y: size.height * 0.38
            )
            let radius: CGFloat = size.width * 0.36
            
            let moods = MoodType.allCases
            
            ZStack {
                
                Path { path in
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(30),
                        endAngle: .degrees(150),
                        clockwise: false
                    )
                }
                .stroke(Color.gray.opacity(0.25), lineWidth: 2)
                
                ForEach(Array(moods.enumerated()), id: \.element) { index, mood in
                    
                    let total = moods.count
                    let angleStep = (160.0 - 20.0) / Double(total - 1)
                    let angleDeg = 20.0 + (Double(index) * angleStep)
                    let angle = angleDeg * .pi / 180
                    
//                    let isSelected = moodNestViewModel.selectedMood == mood
                    let r = radius
                    
                    let x = center.x + cos(angle) * r
                    let y = center.y + sin(angle) * r
                    
                    moodButton(for: mood)
                        .position(x: x, y: y) // 👈 IMPORTANT (NOT offset)
                }
            }
        }
        .frame(height: 170) // 👈 give breathing space
    }
    
    func moodButton(for mood: MoodType) -> some View {
        let isSelected = moodNestViewModel.selectedMood == mood
        
        return ZStack {
            
            // 🌈 Soft background glow
            Circle()
                .fill(color(for: mood).opacity(isSelected ? 0.35 : 0.18))
                .frame(width: isSelected ? 70 : 52)
            
            // Main circle
            Circle()
                .fill(color(for: mood))
                .frame(width: isSelected ? 58 : 44)
                .shadow(
                    color: isSelected ? color(for: mood).opacity(0.5) : .clear,
                    radius: isSelected ? 10 : 0,
                    y: 6
                )
            
            Text(mood.emoji)
                .font(.system(size: isSelected ? 26 : 20))
        }
        .scaleEffect(isSelected ? 1.12 : 0.9)
        .opacity(isSelected ? 1 : 0.65)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: moodNestViewModel.selectedMood)
        .onTapGesture {
            if reduceMotion {
                moodNestViewModel.selectMood(mood)
            } else {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    moodNestViewModel.selectMood(mood)
                }
            }
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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

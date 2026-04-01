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

                // 🌸 Static soft background (cleaner than mood switching bg)
                secondary
                    .ignoresSafeArea()

                VStack(spacing: 28) {

                    topBar

                    Spacer()

                    title

                    mainFace

                    moodSelector

                    Spacer()
                }
                .padding(.horizontal, 20)
            }

            // MARK: Bottom Button

            .safeAreaInset(edge: .bottom) {
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
                .padding(.vertical, 10)
                .background(secondary)
                .accessibilityLabel("Continue with mood \(moodNestViewModel.selectedMood.rawValue)")
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
    
    var topBar: some View {
        HStack {
            Button("Back") {
                // handle navigation
            }
            .foregroundColor(primary)
            
            Spacer()
            
            Text("3 of 10")
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.05))
                .clipShape(Capsule())
        }
    }
    
    var title: some View {
        Text("What is your mood?")
            .font(.title2.weight(.semibold))
            .multilineTextAlignment(.center)
    }
    
    var mainFace: some View {
        VStack(spacing: 12) {
            
            ZStack {
                Circle()
                    .fill(moodNestViewModel.backgroundColor)
                    .frame(width: 220, height: 220)
                
                VStack(spacing: 8) { // ✅ tighter grouping = cuter
                    
                    // 👀 BIG expressive eyes
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
                    .offset(y: 6) // ✅ bring eyes down (centered look)
                    
                    // 🙂 SMALL, subtle smile
                    SmileView(
                        rotation: moodNestViewModel.smileRotation,
                        color: moodNestViewModel.faceColor
                    )
                    .offset(y: -1) // ✅ closer to eyes
                }
            }
            
            Text(moodNestViewModel.selectedMood.rawValue)
                .font(.headline)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: moodNestViewModel.selectedMood)
    }
    
    var moodSelector: some View {
        HStack(spacing: 22) {
            ForEach(MoodType.allCases) { mood in
                moodButton(for: mood)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Mood selector")
        .accessibilityValue(moodNestViewModel.selectedMood.rawValue)
    }
    
    func moodButton(for mood: MoodType) -> some View {
        let isSelected = moodNestViewModel.selectedMood == mood
        
        return ZStack {
            Circle()
                .fill(color(for: mood))
                .frame(width: isSelected ? 60 : 48)
                .shadow(
                    color: isSelected ? color(for: mood).opacity(0.4) : .clear,
                    radius: 8,
                    y: 4
                )
            
            Text(mood.emoji)
                .font(.system(size: 22))
        }
        .scaleEffect(isSelected ? 1.1 : 0.9)
        .opacity(isSelected ? 1 : 0.6)
        .animation(.spring(), value: moodNestViewModel.selectedMood)
        .onTapGesture {
            if reduceMotion {
                moodNestViewModel.selectMood(mood)
            } else {
                withAnimation(.spring()) {
                    moodNestViewModel.selectMood(mood)
                }
            }
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        .accessibilityLabel(mood.rawValue)
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

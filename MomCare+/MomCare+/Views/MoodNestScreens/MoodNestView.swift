import HealthKit
import SwiftUI
import TipKit

struct MoodNestView: View {
    // MARK: Internal

    var body: some View {
        ZStack {
            secondary.ignoresSafeArea()

            VStack {
                title

                Spacer(minLength: 30)

                faceWithSelector

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showHistorySheet) {
            NavigationStack {
                VStack(spacing: 0) {
                    CompactCalendarView(selectedDate: $selectedDateForHistory, isExpanded: $controlState.showingExpandedCalendar)

                    ContentUnavailableView(
                        "Comming Soon",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Mood history details and insights will be available in a future update. Stay tuned!"),
                    )
                }
                .navigationTitle("Mood History")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close) {
                            showHistorySheet = false
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHistorySheet = true
                } label: {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if stateOfMindPermission == .notDetermined {
                    Button {
                        askForPermission()
                    } label: {
                        Label("Permission Error", systemImage: "exclamationmark.triangle")
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button {
                    HapticsHandler.impact(.soft)
                    controlState.showingMoodnestPlaylistsView = true
                } label: {
                    Text("Next Step")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primary)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 12)
            .background(secondary)
        }

        .navigationDestination(isPresented: $controlState.showingMoodnestPlaylistsView) {
            MoodNestPlaylistsView(mood: selectedMood)
        }
    }

    var title: some View {
        Text("What is your mood?")
            .font(.title.weight(.semibold))
    }

    var faceWithSelector: some View {
        VStack(spacing: 0) {
            ZStack {
                let angryTint = Color(red: 0.85, green: 0.35, blue: 0.35)
                let sadTint = Color(red: 0.75, green: 0.85, blue: 1.0)

                Circle()
                    .fill(
                        selectedMood == .angry && isFaceAngryAnimating
                        ? angryTint
                        : selectedMood == .sad && isFaceSadAnimating
                            ? sadTint
                            : moodNestViewModel.backgroundColor
                    )
                    .animation(.easeInOut(duration: 0.25), value: isFaceAngryAnimating)
                    .animation(.easeInOut(duration: 0.25), value: isFaceSadAnimating)
                    .frame(width: 220, height: 220)

                MoodFaceView(
                    mood: selectedMood,
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

            Text(selectedMood.rawValue)
                .font(.title2.weight(.semibold))

            moodArc
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

    func moodButton(for mood: MoodType) -> some View {
        let isSelected = selectedMood == mood

        return ZStack {
            Circle()
                .fill(
                    color(for: mood)
                        .opacity(isSelected ? 0.25 : 0.12)
                )
                .frame(width: isSelected ? 70 : 52)

            Circle()
                .fill(color(for: mood))
                .frame(width: isSelected ? 58 : 44)

            miniFace(for: mood, isSelected: isSelected)
        }
        .scaleEffect(isSelected ? 1.12 : 0.9)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
        .onTapGesture {
            HapticsHandler.impact(.medium)
            withAnimation(.spring()) {
                moodNestViewModel.applyMood(mood)
                selectedMood = mood
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                faceTrigger = UUID()
            }

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

    // MARK: Private

    @EnvironmentObject private var contentService: ContentServiceHandler
    @State private var selectedMood: MoodType = .happy
    @State private var showHistorySheet = false
    @State private var selectedDateForHistory: Date = .init()
    @StateObject private var moodNestViewModel: MoodNestViewModel = .init()

    @State private var faceTrigger: UUID = .init()
    @State private var isFaceAngryAnimating = false
    @State private var isFaceSadAnimating = false
    @State private var isSadAnimating = false

    @EnvironmentObject private var controlState: ControlState

    private let primary: Color = .init(hex: "#924350")
    private let secondary: Color = .init(hex: "#FBE8E5")

    private var stateOfMindPermission: HKAuthorizationStatus {
        contentService.healthStore.authorizationStatus(for: .stateOfMindType())
    }

    private func askForPermission() {
        contentService.healthStore.requestAuthorization(toShare: [.stateOfMindType()], read: [.stateOfMindType()]) { _, _ in
        }
    }
}

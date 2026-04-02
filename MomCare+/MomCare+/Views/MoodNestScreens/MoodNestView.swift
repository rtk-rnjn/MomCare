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
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation(.easeInOut) {
                                controlState.showingExpandedCalendar.toggle()
                            }
                        } label: {
                            Image(systemName: "calendar")
                                .font(.body)
                                .foregroundStyle(Color.CustomColors.mutedRaspberry)
                                .symbolEffect(.bounce, value: controlState.showingExpandedCalendar)
                        }
                        .accessibilityLabel(controlState.showingExpandedCalendar ? "Collapse calendar" : "Expand calendar")
                        .accessibilityIdentifier("expandCalendarButton")
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            selectedDateForHistory = Date()
                        } label: {
                            Image(systemName: "\(Calendar.current.component(.day, from: Date())).calendar")
                                .font(.body)
                                .foregroundStyle(Color.CustomColors.mutedRaspberry)
                        }
                        .accessibilityLabel("Jump to today")
                        .accessibilityIdentifier("jumpToTodayButton")
                    }

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
                    Task {
                        try? await contentService.logMoodToHealthKit(mood: selectedMood)
                    }
                } label: {
                    Text("Next Step")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(reduceTransparency ? primary : primary.opacity(0.95))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .accessibilityLabel("Next step for \(selectedMood.rawValue) mood")
                .accessibilityValue(selectedMood.rawValue)
                .accessibilityHint("Opens playlists for your \(selectedMood.rawValue) mood")
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
            .accessibilityAddTraits(.isHeader)
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
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: isFaceAngryAnimating)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: isFaceSadAnimating)
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
                .accessibilityHidden(true)
            }
            .accessibilityLabel("Current mood face: \(selectedMood.rawValue)")
            .accessibilityValue(selectedMood.emoji)

            Text(selectedMood.rawValue)
                .font(.title2.weight(.semibold))
                .accessibilityHidden(true)

            moodArc
                .offset(y: -25)
                .accessibilityLabel("Mood selector")
                .accessibilityHint("Select your current mood")
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

        return Button {
            HapticsHandler.impact(.medium)
            withAnimation(reduceMotion ? nil : .spring()) {
                moodNestViewModel.applyMood(mood)
                selectedMood = mood
            }

            if !reduceMotion {
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
                        isFaceSadAnimating = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isFaceSadAnimating = false
                    }
                }
            }
        } label: {
            ZStack {
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
            .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mood.rawValue) mood")
        .accessibilityHint("Select \(mood.rawValue) as your current mood")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
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

    @EnvironmentObject private var controlState: ControlState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

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

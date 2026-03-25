import AVFoundation
import SwiftUI
import TipKit

struct MyPlanExercisePlanView: View {
    // MARK: Internal

    var body: some View {
        VStack(spacing: 12) {
            WeeklyProgressCardView(
                completedCount: completedCount,
                totalCount: contentServiceHandler.userExercises.count + 2,
                weeklyProgress: contentServiceHandler.weeklyProgress
            )
            .padding(.horizontal, 16)

            ScrollView(.vertical, showsIndicators: false) {
                exerciseCardsView
            }
            .refreshable {
                Task {
                    do {
                        try await contentServiceHandler.fetchUserExercises()
                    } catch {
                        controlState.error = error
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $showHelp) {
            MyPlanExerciseGuideView()
        }
        .fullScreenCover(isPresented: $showHistory) {
            ExerciseHistory()
        }
        .fullScreenCover(isPresented: $showWaterLog) {
            WaterLogView()
        }
        .fullScreenCover(isPresented: $showWalkingHistory) {
            WalkingHistoryView(stepsGoal: Int(contentServiceHandler.stepsGoal))
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
                .accessibilityLabel("Exercise history")
                .accessibilityHint("Opens your exercise history")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if experimentalFeatures {
                        Button {
                            showWaterLog = true
                        } label: {
                            Label("Water Intake Log", systemImage: "drop.fill")
                        }

                        Divider()
                    }

                    Button {
                        showHelp = true
                    } label: {
                        Label("Guide", systemImage: "questionmark.circle")
                    }

                } label: {
                    Image(systemName: "ellipsis")
                        .accessibilityHidden(true)
                }
                .accessibilityLabel("More options")
            }
        }
        .padding(.top, 8)
        .overlay {
            if showingExerciseInfo || showingBreathingInfo {
                exerciseInfoOverlay()
            }
        }
    }

    // MARK: Private

    @AppStorage(FeatureFlagState.experimentalFeatures.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var experimentalFeatures: Bool = false

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedExerciseInfo: UserExerciseModel?
    @State private var showingExerciseInfo = false
    @State private var showingBreathingInfo = false

    @State private var showHelp = false
    @State private var showWaterLog = false
    @State private var showHistory = false
    @State private var showWalkingHistory = false

    @State private var walkingCompleted: Bool = false

    private var completedCount: Int {
        contentServiceHandler.totalUserExercisesCompleted + (breathingCompleted ? 1 : 0) + (walkingCompleted ? 1 : 0)
    }

    private var breathingCompleted: Bool {
        let durationCompleted = contentServiceHandler.fetchBreathingCompletionDuration(for: .init())
        let totalDuration = contentServiceHandler.breathingTargetInSeconds
        return durationCompleted >= totalDuration
    }

    private var exerciseCardsView: some View {
        VStack(spacing: 14) {
            WalkingCardView(stepsToday: contentServiceHandler.stepsToday, stepsGoal: contentServiceHandler.stepsGoal)
                .onTapGesture {
                    showWalkingHistory = true
                }
                .accessibilityHint("Double tap to view walking history")
                .accessibilityAddTraits(.isButton)
                .onAppear {
                    contentServiceHandler.fetchTodaySteps()
                }

            BreathingCardView {
                withAnimation(reduceMotion ? nil : .easeInOut) {
                    showingBreathingInfo = true
                }
            }

            HStack {
                Text("Today's Exercises")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 4)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            ForEach(contentServiceHandler.userExercises) { exercise in
                ExerciseCardView(userExerciseModel: exercise) {
                    selectedExerciseInfo = exercise
                    withAnimation(reduceMotion ? nil : .easeInOut) {
                        showingExerciseInfo = true
                    }
                } onVideoDismiss: { avPlayer in
                    let currentTime = avPlayer.currentTime().seconds
                    do {
                        if currentTime.isFinite {
                            try await contentServiceHandler.updateExerciseCompletionDuration(id: exercise.id, duration: currentTime)

                            await contentServiceHandler.fetchUserExercisesMeta()
                        }
                    } catch {
                        controlState.error = error
                    }
                }
            }

            Color.clear.padding(.bottom, 10)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 50)
    }

    private func exerciseInfoOverlay() -> some View {
        ZStack {
            Color.black
                .opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(reduceMotion ? nil : .easeInOut) {
                        showingExerciseInfo = false
                    }
                }

            if let selectedExerciseInfo, showingExerciseInfo {
                unsafe ExerciseInfoSheet(userExerciseModel: selectedExerciseInfo, isPresented: $showingExerciseInfo)
                    .frame(maxWidth: 360)
                    .frame(maxHeight: 500)
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                    .padding(.horizontal, 24)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            } else if showingBreathingInfo {
                unsafe BreathingInfoSheet(isPresented: $showingBreathingInfo)
                    .frame(maxWidth: 360)
                    .frame(maxHeight: 500)
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                    .padding(.horizontal, 24)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
    }
}

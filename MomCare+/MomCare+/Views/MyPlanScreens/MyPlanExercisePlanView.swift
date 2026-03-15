import SwiftUI

struct MyPlanExercisePlanView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 12) {
            WeeklyProgressCardView(
                completedCount: contentServiceHandler.totalUserExercisesCompleted + (breathingCompleted ? 1 : 0) + (walkingCompleted ? 1 : 0),
                totalCount: contentServiceHandler.userExercises.count + 2
            )
            .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        WalkingCardView()

                        HStack {
                            Text("Today's Exercises")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)

                        BreathingCardView(onInfo: {
                            withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85)) {
                                showingBreathingInfo = true
                            }
                        })

                        ForEach(contentServiceHandler.userExercises) { exercise in
                            ExerciseCardView(
                                userExerciseModel: exercise,
                                onInfo: {
                                    selectedExerciseInfo = exercise
                                    withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85)) {
                                        showingExerciseInfo = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 50)
                }
            }
            .frame(maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
            .padding(.horizontal, 16)
        }
        .padding(.top, 8)
        .overlay {
            if showingExerciseInfo || showingBreathingInfo {
                exerciseInfoOverlay()
            }
        }
        .onAppear {
            _ = contentServiceHandler.fetchBreathingCompletionDuration(for: Date())
            walkingCompleted = contentServiceHandler.currentSteps >= contentServiceHandler.targetSteps
            breathingCompleted = contentServiceHandler.breathingCompletionDuration >= contentServiceHandler.breathingTargetInSeconds

        }
        .onChange(of: contentServiceHandler.breathingCompletionDuration) {
            breathingCompleted = contentServiceHandler.breathingCompletionDuration >= contentServiceHandler.breathingTargetInSeconds
        }
        .onChange(of: contentServiceHandler.currentSteps) {
            walkingCompleted = contentServiceHandler.currentSteps >= contentServiceHandler.targetSteps
        }
        .onChange(of: contentServiceHandler.userExercises) {
            Task {
                await contentServiceHandler.fetchTotalUserExercisesCompleted()
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedExerciseInfo: UserExerciseModel?
    @State private var showingExerciseInfo = false
    @State private var showingBreathingInfo = false

    @State private var breathingCompleted: Bool = false
    @State private var walkingCompleted: Bool = false

    private func exerciseInfoOverlay() -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85)) {
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

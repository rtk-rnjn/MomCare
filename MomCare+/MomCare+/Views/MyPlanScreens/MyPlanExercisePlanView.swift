//
//  MyPlanExercisePlanView.swift
//  MomCare+
//
//  Created by Aryan singh on 16/02/26.
//
import SwiftUI

struct MyPlanExercisePlanView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 12) {
            WeeklyProgressCardView(
                completedCount: exercisesCompleted + (breathingCompleted ? 1 : 0) + (walkingCompleted ? 1 : 0),
                totalCount: healthKitHandler.userExercises.count + 2
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
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                showingBreathingInfo = true
                            }
                        })

                        ForEach(healthKitHandler.userExercises) { exercise in
                            ExerciseCardView(
                                userExerciseModel: exercise,
                                onInfo: {
                                    selectedExerciseInfo = exercise
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
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
            _ = healthKitHandler.fetchBreathingCompletionDuration(for: Date())
            walkingCompleted = healthKitHandler.currentSteps >= healthKitHandler.targetSteps
            breathingCompleted = healthKitHandler.breathingCompletionDuration >= healthKitHandler.breathingTargetInSeconds
        }
        .task {
            exercisesCompleted = await UserExerciseModel.totalCompletion(from: healthKitHandler.userExercises)
        }
        .onChange(of: healthKitHandler.userExercises) {
            Task {
                exercisesCompleted = await UserExerciseModel.totalCompletion(from: healthKitHandler.userExercises)
            }
        }
        .onChange(of: healthKitHandler.breathingCompletionDuration) {
            breathingCompleted = healthKitHandler.breathingCompletionDuration >= healthKitHandler.breathingTargetInSeconds
        }
        .onChange(of: healthKitHandler.currentSteps) {
            walkingCompleted = healthKitHandler.currentSteps >= healthKitHandler.targetSteps
        }
    }

    // MARK: Private

    @EnvironmentObject private var healthKitHandler: HealthKitHandler

    @State private var selectedExerciseInfo: UserExerciseModel?
    @State private var showingExerciseInfo = false
    @State private var showingBreathingInfo = false

    @State private var exercisesCompleted: Int = 0
    @State private var breathingCompleted: Bool = false
    @State private var walkingCompleted: Bool = false

    private func exerciseInfoOverlay() -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
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

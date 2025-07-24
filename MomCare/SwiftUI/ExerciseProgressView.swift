import SwiftUI
import HealthKit

struct ExerciseProgressView: View {

    // MARK: Internal

    weak var delegate: ExerciseProgressViewController?

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    weekHeaderView
                    weeklyProgressRingsView
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showingCalendar = true
                            }
                        }
                    walkingCardView

                    exerciseCard(for: Exercise(name: "Breathing", type: .breathing, duration: 600, description: "Deep breathing exercises help reduce stress and anxiety during pregnancy. This gentle practice improves oxygen flow to both you and your baby while promoting relaxation and better sleep quality.", tags: ["Stress Relief", "Better Sleep", "Oxygen Flow", "Relaxation"], week: "", targetedBodyParts: ["Lungs"], assignedAt: Date()), isBreathing: true)

                    exerciseCardsView
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "E5D4D3"), Color(hex: "E5D4D3")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blur(radius: (isShowingInfo || showingCalendar) ? 3 : 0)
            .animation(.easeInOut(duration: 0.3), value: isShowingInfo || showingCalendar)

            if isShowingInfo, let exercise = showingExerciseInfo {
                exerciseInfoCard(for: exercise)
                    .transition(.asymmetric(
                        insertion: AnyTransition.scale(scale: 0.3).combined(with: AnyTransition.opacity).combined(with: AnyTransition.move(edge: .bottom)),
                        removal: AnyTransition.scale(scale: 0.8).combined(with: AnyTransition.opacity).combined(with: AnyTransition.move(edge: .top))
                    ))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowingInfo)
            }

            if showingCalendar {
                progressCalendarView
                    .transition(.asymmetric(
                        insertion: AnyTransition.scale.combined(with: AnyTransition.opacity),
                        removal: AnyTransition.scale.combined(with: AnyTransition.opacity)
                    ))
            }
        }
        .task {
            let stepsData = await delegate?.readStepCount()
            if let stepsData {
                currentSteps = Int(stepsData.current)
                targetSteps = Int(stepsData.target)
            }

            let exercises: [Exercise]? = await delegate?.fetchExercises()
            if let exercises {
                viewModel.exercises = exercises
            }

            var count = 0
            for exercise in viewModel.exercises {
                if exercise.isCompleted {
                    count += 1
                }
            }

            if currentSteps >= targetSteps {
                count += 1
            }

            viewModel.totalCompletedExercises = count
        }
    }

    // MARK: Private

    @StateObject private var viewModel: ExerciseGoalsViewModel = .init()
    @State private var showingExerciseInfo: Exercise?
    @State private var isShowingInfo = false
    @State private var showingCalendar = false

    // Calendar navigation states
    @State private var currentDate: Date = .init()
    @State private var dragOffset: CGFloat = 0

    @State private var currentSteps: Int = 0
    @State private var targetSteps: Int = 1

    private var weekHeaderView: some View {
        VStack(spacing: 6) {
            Text("Week \(MomCareUser.shared.user?.pregancyData?.week ?? -1)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "924350"))
        }
        .padding(.top, 15)
        .padding(.bottom, 5)
    }

    private var weeklyProgressRingsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Weekly Progress")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 4) {
                    Text("\(Calendar.current.component(.weekday, from: Date()))/7 days")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .opacity(0.6)
                }
            }

            // Day letters row with enhanced styling
            HStack(spacing: 8) {
                ForEach(viewModel.weeklyProgress, id: \.day) { dayProgress in
                    VStack(spacing: 8) {
                        Text(dayProgress.dayName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "924350"))

                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                                .frame(width: 32, height: 32)

                            Circle()
                                .trim(from: 0, to: min(dayProgress.completionPercentage, 1.0))
                                .stroke(
                                    Color(hex: "924350"),
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 32, height: 32)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 1.0, dampingFraction: 0.8, blendDuration: 0), value: dayProgress.completionPercentage)

                            if dayProgress.completionPercentage >= 1.0 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(hex: "924350"))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Total Goal Section
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "target")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "924350"))

                        Text("Total Goal: \(viewModel.totalCompletedExercises)/\(2 + viewModel.exercises.count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Text("")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "924350"))
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "924350"))
                            .frame(
                                width:
                                    min(geometry.size.width * CGFloat(viewModel.totalCompletedExercises) / CGFloat(2 + viewModel.exercises.count), geometry.size.width),
                                height: 6)
                            .animation(.easeInOut(duration: 1.0), value: 0.33)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
    }

    private var walkingCardView: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "924350"))

                    Text("Walking")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(currentSteps / targetSteps * 100))% Completed")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "924350"))

                    if currentSteps / targetSteps >= 1 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "924350"))
                    }
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(currentSteps)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Steps")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(targetSteps)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("Goal")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            // Walking Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "924350"))
                        .frame(
                            width: targetSteps > 0 ?
                                min(geometry.size.width * CGFloat(currentSteps) / CGFloat(targetSteps), geometry.size.width) : 0,
                            height: 6
                        )
                        .animation(.easeInOut(duration: 1.2), value: currentSteps)
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
    }

    private var exerciseCardsView: some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                Text("Today's Exercises")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Text("")
            }
            .padding(.horizontal, 4)

            ForEach(viewModel.exercises, id: \.id) { exercise in
                exerciseCard(for: exercise)
            }
        }
    }

    private var progressCalendarView: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingCalendar = false
                    }
                }

            VStack {
                Text("Calendar Coming Soon")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.7))
                    )
            }
        }
    }

    // MARK: - Helper Functions
    private func exerciseCard(for exercise: Exercise, isBreathing: Bool = false) -> some View {
        ZStack {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Beginner")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)

                    Text(exercise.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)

                    Text("\(Int(exercise.completionPercentage))% completed")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 16)

                    Button(action: {
                        if isBreathing {
                            delegate?.segueToBreathingPlayer()
                        } else {
                            Task {
                                delegate?.selectedExercise = exercise
                                await delegate?.play(exercise: exercise)
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12))

                            Text("Start")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "924350"))
                        )
                    }
                }

                Spacer()

                // Exercise Image/Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FBE8E5")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)

                    if isBreathing {
                        Image(systemName: "lungs.fill")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(Color(hex: "924350"))
                    } else {
                        Image(systemName: "figure.yoga")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(Color(hex: "924350"))
                    }
                }
            }

            // Enhanced info button
            enhancedInfoButton(exercise: exercise)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
    }

    private func enhancedInfoButton(exercise: Exercise) -> some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showingExerciseInfo = exercise
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isShowingInfo = true
                    }
                }) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 22))
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 30, height: 30)
                        )
                }
            }
            Spacer()
        }
    }

    private func exerciseInfoCard(for exercise: Exercise) -> some View {
        ZStack {
            // Background overlay with smooth fade in
            Color.black.opacity(isShowingInfo ? 0.4 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6).delay(0.1), value: isShowingInfo)
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isShowingInfo = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingExerciseInfo = nil
                    }
                }

            // Dynamic Info Card with enhanced opening effect
            VStack(spacing: 0) {
                // Main header with image, title AND close button
                HStack(spacing: 16) {
                    // Exercise Image/Icon on LEFT - Pop in effect
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "F5E6E8"))
                            .frame(width: 70, height: 70)
                            .scaleEffect(isShowingInfo ? 1 : 0.1)
                            .opacity(isShowingInfo ? 1 : 0)

                        if exercise.type == .breathing {
                            Image(systemName: "lungs.fill")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(Color(hex: "924350"))
                                .scaleEffect(isShowingInfo ? 1 : 0.1)
                                .opacity(isShowingInfo ? 1 : 0)
                                .rotationEffect(.degrees(isShowingInfo ? 0 : 180))
                        } else {
                            Image(systemName: "figure.yoga")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(Color(hex: "924350"))
                                .scaleEffect(isShowingInfo ? 1 : 0.1)
                                .opacity(isShowingInfo ? 1 : 0)
                                .rotationEffect(.degrees(isShowingInfo ? 0 : 180))
                        }
                    }
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: isShowingInfo)

                    // Content in MIDDLE - Slide from left
                    VStack(alignment: .leading, spacing: 6) {
                        Text(exercise.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .opacity(isShowingInfo ? 1 : 0)
                            .offset(x: isShowingInfo ? 0 : -30)

                        Text(exercise.level.rawValue.capitalized)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "924350"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "F5E6E8"))
                                    .scaleEffect(isShowingInfo ? 1 : 0.8)
                            )
                            .opacity(isShowingInfo ? 1 : 0)
                            .offset(x: isShowingInfo ? 0 : -20)
                    }
                    .animation(.spring(response: 0.9, dampingFraction: 0.7).delay(0.35), value: isShowingInfo)

                    Spacer()

                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isShowingInfo = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingExerciseInfo = nil
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.15))
                                    .scaleEffect(isShowingInfo ? 1 : 0.1)
                            )
                            .scaleEffect(isShowingInfo ? 1 : 0.1)
                            .opacity(isShowingInfo ? 1 : 0)
                            .rotationEffect(.degrees(isShowingInfo ? 0 : 90))
                    }
                    .animation(.spring(response: 0.7, dampingFraction: 0.5).delay(0.45), value: isShowingInfo)
                }
                .padding(18)
                .padding(.top, 6)

                VStack(alignment: .leading, spacing: 16) {
                    Text("About This Exercise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .opacity(isShowingInfo ? 1 : 0)
                        .offset(x: isShowingInfo ? 0 : -40)
                        .scaleEffect(isShowingInfo ? 1 : 0.9, anchor: .leading)
                        .animation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.5), value: isShowingInfo)

                    Text(exercise.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .opacity(isShowingInfo ? 1 : 0)
                        .offset(y: isShowingInfo ? 0 : 20)
                        .scaleEffect(isShowingInfo ? 1 : 0.95)
                        .animation(.spring(response: 1.1, dampingFraction: 0.8).delay(0.6), value: isShowingInfo)

                    // Compact Details with staggered bounce
                    HStack(spacing: 20) {
                        detailItem(icon: "clock", value: exercise.humanReadableDuration)
                            .opacity(isShowingInfo ? 1 : 0)
                            .scaleEffect(isShowingInfo ? 1 : 0.3)
                            .offset(y: isShowingInfo ? 0 : 15)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.7), value: isShowingInfo)

                        detailItem(icon: "flame", value: "Low")
                            .opacity(isShowingInfo ? 1 : 0)
                            .scaleEffect(isShowingInfo ? 1 : 0.3)
                            .offset(y: isShowingInfo ? 0 : 15)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.75), value: isShowingInfo)

                        detailItem(icon: "target", value: exercise.targetedBodyParts.joined(separator: ", "))
                            .opacity(isShowingInfo ? 1 : 0)
                            .scaleEffect(isShowingInfo ? 1 : 0.3)
                            .offset(y: isShowingInfo ? 0 : 15)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.8), value: isShowingInfo)

                        Spacer()
                    }
                    .padding(.vertical, 4)

                    // Benefits Section with cascading reveal
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Benefits")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                            .opacity(isShowingInfo ? 1 : 0)
                            .offset(x: isShowingInfo ? 0 : -30)
                            .scaleEffect(isShowingInfo ? 1 : 0.9, anchor: .leading)
                            .animation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.85), value: isShowingInfo)

                        // Benefits tags with wave animation
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 6),
                                GridItem(.flexible(), spacing: 6)
                            ],
                            spacing: 6
                        ) {
                            ForEach(Array(exercise.tags.enumerated()), id: \.offset) { index, tag in
                                benefitTag(text: tag)
                                    .opacity(isShowingInfo ? 1 : 0)
                                    .scaleEffect(isShowingInfo ? 1 : 0.1)
                                    .offset(
                                        x: isShowingInfo ? 0 : (index % 2 == 0 ? -20 : 20),
                                        y: isShowingInfo ? 0 : 20
                                    )
                                    .rotationEffect(.degrees(isShowingInfo ? 0 : (index % 2 == 0 ? -15 : 15)))
                                    .animation(
                                        .spring(response: 0.9, dampingFraction: 0.7)
                                            .delay(0.9 + Double(index) * 0.1),
                                        value: isShowingInfo
                                    )
                            }
                        }
                    }
                }
                .padding(18)
                .padding(.top, 0)
            }
            .frame(maxWidth: 350)
            .scaleEffect(isShowingInfo ? 1 : 0.4, anchor: .center)
            .opacity(isShowingInfo ? 1 : 0)
            .offset(y: isShowingInfo ? 0 : 50)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(
                        color: Color.black.opacity(isShowingInfo ? 0.15 : 0),
                        radius: isShowingInfo ? 12 : 0,
                        x: 0,
                        y: isShowingInfo ? 6 : 0
                    )
                    .scaleEffect(isShowingInfo ? 1 : 0.8)
                    .animation(.easeInOut(duration: 0.8).delay(0.05), value: isShowingInfo)
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
            .animation(.spring(response: 1.0, dampingFraction: 0.75).delay(0.1), value: isShowingInfo)
        }
    }

    private func detailItem(icon: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "924350"))

            Text(value)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func benefitTag(text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(Color(hex: "924350"))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "F5E6E8"))
            )
    }
}

struct DayProgress {
    let day: Date
    let dayName: String
    let completionPercentage: Double
}

// MARK: - View Model
class ExerciseGoalsViewModel: ObservableObject {

    // MARK: Internal

    @Published var weeklyProgress: [DayProgress] = []
    @Published var exercises: [Exercise] = []
    @Published var totalCompletedExercises: Int = 0

    // MARK: Private

    private func loadWeeklyProgress() {
        let dayNames = ["S", "M", "T", "W", "T", "F", "S"]
        let mockProgressValues = [1.0, 0.8, 1.0, 0.6, 0.0, 0.0, 0.0]

        var progress: [DayProgress] = []

        for i in 0..<7 {
            let today = Date()
            let day = Calendar.current.date(byAdding: .day, value: i, to: today) ?? today
            let dayName = dayNames[i]

            progress.append(DayProgress(
                day: day,
                dayName: dayName,
                completionPercentage: mockProgressValues[i]
            ))
        }

        weeklyProgress = progress
    }
}

//    private func loadMockExerciseGoals() {
//        exerciseGoals = [
//            ExerciseGoalInfo(
//                id: 0,
//                title: "Breathing",
//                subtitle: "Deep breathing exercise",
//                systemIcon: "lungs.fill",
//                progress: 0.0,
//                level: "Beginner",
//                description: "Deep breathing exercises help reduce stress and anxiety during pregnancy. This gentle practice improves oxygen flow to both you and your baby while promoting relaxation and better sleep quality.",
//                duration: "5 minutes",
//                intensity: "Low",
//                focus: "Relaxation",
//                tags: ["Stress Relief", "Better Sleep", "Oxygen Flow", "Relaxation"]
//            ),
//            ExerciseGoalInfo(
//                id: 1,
//                title: "Prenatal Yoga",
//                subtitle: "Gentle stretching routine",
//                systemIcon: "figure.yoga",
//                progress: 0.0,
//                level: "Beginner",
//                description: "Gentle yoga poses specifically designed for pregnant women. These poses help maintain flexibility, strengthen muscles, and prepare your body for childbirth while reducing common pregnancy discomforts.",
//                duration: "15 minutes",
//                intensity: "Low to Moderate",
//                focus: "Flexibility & Strength",
//                tags: ["Flexibility", "Muscle Strength", "Pain Relief", "Birth Prep"]
//            ),
//            ExerciseGoalInfo(
//                id: 2,
//                title: "Pelvic Floor",
//                subtitle: "Strengthening exercises",
//                systemIcon: "figure.strengthtraining.traditional",
//                progress: 0.0,
//                level: "Beginner",
//                description: "Essential exercises to strengthen your pelvic floor muscles. These exercises help prevent incontinence, support your growing baby, and aid in postpartum recovery.",
//                duration: "10 minutes",
//                intensity: "Low",
//                focus: "Pelvic Health",
//                tags: ["Pelvic Strength", "Incontinence Prevention", "Birth Recovery", "Core Support"]
//            )
//        ]
//    }
// }
//
//// MARK: - Preview
// struct ExerciseProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseProgressView()
//    }
// }

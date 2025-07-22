import SwiftUI
import HealthKit

struct PregnancyProgressView: View {
    @StateObject private var viewModel = ExerciseGoalsViewModel()
    @State private var showingExerciseInfo: ExerciseGoalInfo?
    @State private var isShowingInfo = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Week Header with enhanced styling
                    weekHeaderView
                    
                    // Weekly Progress Rings
                    weeklyProgressRingsView
                    
                    // Walking Card
                    walkingCardView
                    
                    // Exercise Cards
                    exerciseCardsView
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "F5E6E8"), Color(hex: "F9F0F1")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onAppear {
                viewModel.loadData()
            }
            .blur(radius: isShowingInfo ? 3 : 0)
            .animation(.easeInOut(duration: 0.3), value: isShowingInfo)
            
            // Exercise Info Card Overlay
            if isShowingInfo, let exercise = showingExerciseInfo {
                exerciseInfoCard(for: exercise)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowingInfo)
            }
        }
    }
    
    private var weekHeaderView: some View {
        VStack(spacing: 6) {
            Text("Week 19")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "924350"))
            
            Text("Second Trimester")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .opacity(0.8)
        }
        .padding(.top, 15)
        .padding(.bottom, 5)
    }
    
    private var weeklyProgressRingsView: some View {
        VStack(spacing: 16) {
            // Header for weekly progress
            HStack {
                Text("Weekly Progress")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("3/7 days")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Day letters row with enhanced styling
            HStack(spacing: 8) {
                ForEach(viewModel.weeklyProgress, id: \.day) { dayProgress in
                    VStack(spacing: 8) {
                        Text(dayProgress.dayName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "924350"))
                        
                        // Progress Ring
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
                            
                            // Show percentage or checkmark for completed
                            if dayProgress.completionPercentage >= 1.0 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(hex: "924350"))
                            } else if dayProgress.completionPercentage > 0 {
                                Text("\(Int(min(dayProgress.completionPercentage * 100, 100)))%")
                                    .font(.system(size: 7, weight: .medium))
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
                        
                        Text("Total Goal: 10/30")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("33%")
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
                            .frame(width: geometry.size.width * 0.33, height: 6)
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
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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
                    Text("100% Completed")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "924350"))
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "924350"))
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("1,974")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Steps")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("1,200")
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
                        .frame(width: geometry.size.width, height: 6)
                        .animation(.easeInOut(duration: 1.2), value: 1.0)
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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
                
                Text("0/\(viewModel.exerciseGoals.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            
            ForEach(viewModel.exerciseGoals, id: \.id) { exercise in
                exerciseCard(for: exercise)
            }
        }
    }
    
    private func exerciseCard(for exercise: ExerciseGoalInfo) -> some View {
        ZStack {
            // Main card content - REVERTED TO ORIGINAL
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Beginner")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    
                    Text(exercise.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                    
                    Text("\(Int(exercise.progress * 100)).0% completed")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 16)
                    
                    Button(action: {
                        // Start button action
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12))
                            
                            Text("Start")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10) // Reduced from 12 to 10
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "924350"))
                                .shadow(color: Color(hex: "924350").opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                    }
                }
                
                Spacer()
                
                // Exercise Image/Icon - REVERTED TO ORIGINAL
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FBE8E5"), Color(hex: "F5E6E8")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: exercise.systemIcon)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(Color(hex: "924350"))
                }
            }
            
            // Enhanced info button - REVERTED TO ORIGINAL
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
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                    }
                }
                Spacer()
            }
        }
        .padding(20) // REVERTED TO ORIGINAL
        .background(
            RoundedRectangle(cornerRadius: 20) // REVERTED TO ORIGINAL
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4) // REVERTED TO ORIGINAL
        )
    }
    
    // MARK: - UPDATED Exercise Info Card (Simplified with LazyVGrid)
    private func exerciseInfoCard(for exercise: ExerciseGoalInfo) -> some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isShowingInfo = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingExerciseInfo = nil
                    }
                }
            
            // Dynamic Info Card
            VStack(spacing: 0) {
                // Main header with image, title AND close button
                HStack(spacing: 16) {
                    // Exercise Image/Icon on LEFT
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "F5E6E8"))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: exercise.systemIcon)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(Color(hex: "924350"))
                    }
                    
                    // Content in MIDDLE
                    VStack(alignment: .leading, spacing: 6) {
                        Text(exercise.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(exercise.level)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "924350"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "F5E6E8"))
                            )
                    }
                    
                    Spacer()
                    
                    // Close button on RIGHT
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
                            )
                    }
                }
                .padding(18)
                .padding(.top, 6)
                
                // Description Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("About This Exercise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(exercise.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    
                    // Compact Details in a row
                    HStack(spacing: 20) {
                        detailItem(icon: "clock", value: exercise.duration)
                        detailItem(icon: "flame", value: exercise.intensity)
                        detailItem(icon: "target", value: exercise.focus)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    // Benefits Section - Using LazyVGrid instead of FlowLayout
                    benefitsSection(tags: exercise.tags)
                }
                .padding(18)
                .padding(.top, 0)
            }
            .frame(maxWidth: 350)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
    }
    
    // MARK: - Benefits Section Helper
    private func benefitsSection(tags: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Benefits")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
            
            // Using LazyVGrid for reliable layout
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 6),
                    GridItem(.flexible(), spacing: 6)
                ],
                spacing: 6
            ) {
                ForEach(tags, id: \.self) { tag in
                    benefitTag(text: tag)
                }
            }
        }
    }
    
    // MARK: - Benefit Tag Helper
    private func benefitTag(text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium)) // Same font size as level
            .foregroundColor(Color(hex: "924350"))
            .padding(.horizontal, 10) // Same padding as level
            .padding(.vertical, 4) // Same padding as level
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10) // Same corner radius as level
                    .fill(Color(hex: "F5E6E8")) // Same background as level
            )
    }
    
    // Updated helper for compact detail items with better sizing
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
}

// MARK: - Local Data Models (renamed to avoid conflicts)
struct ExerciseGoalInfo {
    let id: Int
    let title: String
    let subtitle: String
    let systemIcon: String
    let progress: Double
    let level: String
    let description: String
    let duration: String
    let intensity: String
    let focus: String
    let tags: [String]
}

struct DayProgress {
    let day: Date
    let dayName: String
    let completionPercentage: Double
}

// MARK: - View Model
class ExerciseGoalsViewModel: ObservableObject {
    @Published var weeklyProgress: [DayProgress] = []
    @Published var exerciseGoals: [ExerciseGoalInfo] = []
    @Published var currentSteps: Int = 1974
    @Published var stepsGoal: Int = 1200
    @Published var totalGoalsCompleted: Int = 10
    @Published var totalGoals: Int = 30
    
    func loadData() {
        loadMockWeeklyProgress()
        loadMockExerciseGoals()
    }
    
    private func loadMockWeeklyProgress() {
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
    
    private func loadMockExerciseGoals() {
        exerciseGoals = [
            ExerciseGoalInfo(
                id: 0,
                title: "Breathing",
                subtitle: "Deep breathing exercise",
                systemIcon: "lungs.fill",
                progress: 0.0,
                level: "Beginner",
                description: "Deep breathing exercises help reduce stress and anxiety during pregnancy. This gentle practice improves oxygen flow to both you and your baby while promoting relaxation and better sleep quality.",
                duration: "5 minutes",
                intensity: "Low",
                focus: "Relaxation",
                tags: ["Stress Relief", "Better Sleep", "Oxygen Flow", "Relaxation"]
            ),
            ExerciseGoalInfo(
                id: 1,
                title: "Prenatal Yoga",
                subtitle: "Gentle stretching routine",
                systemIcon: "figure.yoga",
                progress: 0.0,
                level: "Beginner",
                description: "Gentle yoga poses specifically designed for pregnant women. These poses help maintain flexibility, strengthen muscles, and prepare your body for childbirth while reducing common pregnancy discomforts.",
                duration: "15 minutes",
                intensity: "Low to Moderate",
                focus: "Flexibility & Strength",
                tags: ["Flexibility", "Muscle Strength", "Pain Relief", "Birth Prep"]
            ),
            ExerciseGoalInfo(
                id: 2,
                title: "Pelvic Floor",
                subtitle: "Strengthening exercises",
                systemIcon: "figure.strengthtraining.traditional",
                progress: 0.0,
                level: "Beginner",
                description: "Essential exercises to strengthen your pelvic floor muscles. These exercises help prevent incontinence, support your growing baby, and aid in postpartum recovery.",
                duration: "10 minutes",
                intensity: "Low",
                focus: "Pelvic Health",
                tags: ["Pelvic Strength", "Incontinence Prevention", "Birth Recovery", "Core Support"]
            )
        ]
    }
}

// MARK: - Preview
struct PregnancyProgressView_Previews: PreviewProvider {
    static var previews: some View {
        PregnancyProgressView()
    }
}

import SwiftUI
import HealthKit

struct PregnancyProgressView: View {
    @StateObject private var viewModel = ExerciseGoalsViewModel()
    @State private var showingExerciseInfo: ExerciseGoalInfo?
    @State private var isShowingInfo = false
    @State private var showingCalendar = false
    
    // Calendar navigation states
    @State private var currentDate = Date()
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Week Header with enhanced styling
                    weekHeaderView
                    
                    // Weekly Progress Rings - Make it tappable
                    weeklyProgressRingsView
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showingCalendar = true
                            }
                        }
                    
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
            .blur(radius: (isShowingInfo || showingCalendar) ? 3 : 0)
            .animation(.easeInOut(duration: 0.3), value: isShowingInfo || showingCalendar)
            
            // Exercise Info Card Overlay
            if isShowingInfo, let exercise = showingExerciseInfo {
                exerciseInfoCard(for: exercise)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowingInfo)
            }
            
            // Calendar Overlay
            if showingCalendar {
                progressCalendarView
                    .transition(.asymmetric(
                        insertion: AnyTransition.scale.combined(with: AnyTransition.opacity),
                        removal: AnyTransition.scale.combined(with: AnyTransition.opacity)
                    ))
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
            // Header for weekly progress with tap indicator
            HStack {
                Text("Weekly Progress")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("3/7 days")
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
                            
                            // Only show checkmark for 100% completed - NO percentages
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
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "924350"))
                        )
                    }
                }
                
                Spacer()
                
                // Exercise Image/Icon - REMOVED SHADOW
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
                
                Image(systemName: exercise.systemIcon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(Color(hex: "924350"))
                }
            }
            
            // Enhanced info button - REMOVED SHADOW
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
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
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
    
    // MARK: - Progress Calendar View (Updated with Month/Year Navigation)
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
            
            // Calendar Card
            VStack(spacing: 0) {
                // Header with Month/Year Navigation
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Exercise Progress")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            // Previous Month Button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "924350"))
                            }
                            
                            // Current Month/Year
                            Text(currentMonthYearString)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(minWidth: 140)
                            
                            // Next Month Button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "924350"))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Close Button
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingCalendar = false
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
                .padding(20)
                
                // Calendar Grid with Swipe Gesture
                VStack(spacing: 0) {
                    // Week day headers
                    HStack(spacing: 0) {
                        ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                            Text(String(day.prefix(1)))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }
                    
                    // Calendar days with animation
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(getDaysInMonth(), id: \.self) { day in
                            if day > 0 {
                                calendarDayView(
                                    day: day,
                                    progress: viewModel.getProgressForDate(year: currentYear, month: currentMonth, day: day),
                                    isToday: isToday(day: day),
                                    isCurrentMonth: true
                                )
                            } else {
                                // Empty space for days from previous month
                                Color.clear
                                    .frame(width: 36, height: 36)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width  // Changed from .x to .width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                
                                if value.translation.width > threshold {  // Changed from .x to .width
                                    // Swipe right - previous month
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                                    }
                                } else if value.translation.width < -threshold {  // Changed from .x to .width
                                    // Swipe left - next month
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                                    }
                                }
                                
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    dragOffset = 0
                                }
                            }
                    )
                }
                
                // Legend
                HStack(spacing: 16) {
                    legendItem(color: Color(hex: "924350"), text: "Completed")
                    legendItem(color: Color(hex: "924350").opacity(0.5), text: "Partial")
                    legendItem(color: Color.gray.opacity(0.3), text: "Not Started")
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Month Summary Stats
                monthSummaryView
            }
            .frame(maxWidth: 400)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
            .padding(.horizontal, 20)
        }
    }
    
    // Calendar day view with enhanced features
    private func calendarDayView(day: Int, progress: Double, isToday: Bool, isCurrentMonth: Bool) -> some View {
        ZStack {
            // Today indicator
            if isToday {
                Circle()
                    .stroke(Color(hex: "924350"), lineWidth: 3)
                    .frame(width: 38, height: 38)
            }
            
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                .frame(width: 36, height: 36)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progress >= 1.0 ? Color(hex: "924350") : Color(hex: "924350").opacity(0.6),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 36, height: 36)
                .rotationEffect(.degrees(-90))
            
            // Day number
            Text("\(day)")
                .font(.system(size: 12, weight: isToday ? .bold : .medium))
                .foregroundColor(isToday ? Color(hex: "924350") : .primary)
            
            // Checkmark for completed days
            if progress >= 1.0 {
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(Color(hex: "924350"))
                    .offset(x: 12, y: -12)
            }
        }
    }
    
    // Legend item
    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    // Month Summary View
    private var monthSummaryView: some View {
        HStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("\(completedDaysInMonth)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "924350"))
                
                Text("Completed")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 4) {
                Text("\(partialDaysInMonth)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "924350").opacity(0.7))
                
                Text("Partial")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 4) {
                Text("\(totalDaysInMonth)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Total Days")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Calendar Helper Properties and Functions
    private var currentMonthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var currentMonth: Int {
        Calendar.current.component(.month, from: currentDate)
    }
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: currentDate)
    }
    
    private func getDaysInMonth() -> [Int] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let numberOfDays = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 30
        let firstDayWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        
        var days: [Int] = []
        
        // Add empty spaces for days before the first day of the month
        for _ in 0..<firstDayWeekday {
            days.append(0)
        }
        
        // Add all days of the month
        for day in 1...numberOfDays {
            days.append(day)
        }
        
        return days
    }
    
    private func isToday(day: Int) -> Bool {
        let today = Date()
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: today)
        let currentComponents = Calendar.current.dateComponents([.year, .month], from: currentDate)
        
        return todayComponents.year == currentComponents.year &&
               todayComponents.month == currentComponents.month &&
               todayComponents.day == day
    }
    
    private var completedDaysInMonth: Int {
        let numberOfDays = Calendar.current.range(of: .day, in: .month, for: currentDate)?.count ?? 30
        return (1...numberOfDays).filter { viewModel.getProgressForDate(year: currentYear, month: currentMonth, day: $0) >= 1.0 }.count
    }
    
    private var partialDaysInMonth: Int {
        let numberOfDays = Calendar.current.range(of: .day, in: .month, for: currentDate)?.count ?? 30
        return (1...numberOfDays).filter { 
            let progress = viewModel.getProgressForDate(year: currentYear, month: currentMonth, day: $0)
            return progress > 0.0 && progress < 1.0 
        }.count
    }
    
    private var totalDaysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: currentDate)?.count ?? 30
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
    
    // Monthly progress data organized by year/month/day
    private var yearlyProgress: [Int: [Int: [Int: Double]]] = [:]
    
    func loadData() {
        loadMockWeeklyProgress()
        loadMockExerciseGoals()
        loadMockYearlyProgress()
    }
    
    private func loadMockYearlyProgress() {
        // Generate mock data for 2024 and 2025
        for year in [2024, 2025] {
            yearlyProgress[year] = [:]
            for month in 1...12 {
                yearlyProgress[year]?[month] = [:]
                let daysInMonth = Calendar.current.range(of: .day, in: .month, for: createDate(year: year, month: month, day: 1))?.count ?? 30
                
                for day in 1...daysInMonth {
                    // Generate realistic progress patterns
                    let progress = generateRealisticProgress(year: year, month: month, day: day)
                    yearlyProgress[year]?[month]?[day] = progress
                }
            }
        }
    }
    
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func generateRealisticProgress(year: Int, month: Int, day: Int) -> Double {
        // Create more realistic patterns
        let date = createDate(year: year, month: month, day: day)
        let weekday = Calendar.current.component(.weekday, from: date)
        
        // Higher completion rates on weekdays, lower on weekends
        let baseRate: Double = weekday == 1 || weekday == 7 ? 0.4 : 0.7
        
        // Add some randomness but weighted towards the base rate
        let randomFactor = Double.random(in: 0...1)
        let weightedProgress = (baseRate + randomFactor) / 2
        
        // Quantize to meaningful values
        if weightedProgress < 0.2 { return 0.0 }
        else if weightedProgress < 0.4 { return 0.3 }
        else if weightedProgress < 0.6 { return 0.6 }
        else if weightedProgress < 0.8 { return 0.8 }
        else { return 1.0 }
    }
    
    func getProgressForDate(year: Int, month: Int, day: Int) -> Double {
        return yearlyProgress[year]?[month]?[day] ?? 0.0
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

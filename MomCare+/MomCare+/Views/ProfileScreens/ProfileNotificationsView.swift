import SwiftUI
import UserNotifications

private enum NotificationKey {
    static let globallyEnabled = "notif.globallyEnabled"
    static let exerciseEnabled = "notif.exerciseEnabled"
    static let exerciseTime = "notif.exerciseTime"
    static let exerciseFrequency = "notif.exerciseFrequency"
    static let exerciseSound = "notif.exerciseSound"
    static let mealReminders = "notif.mealReminders"
    static let remoteEnabled = "notif.remoteEnabled"
}

enum ReminderFrequency: String, Codable, CaseIterable, Identifiable {
    case daily
    case weekdays
    case weekends

    // MARK: Internal

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .daily: "Every Day"
        case .weekdays: "Weekdays Only"
        case .weekends: "Weekends Only"
        }
    }

    var description: String {
        switch self {
        case .daily: "Monday through Sunday"
        case .weekdays: "Monday through Friday"
        case .weekends: "Saturday and Sunday"
        }
    }

    var weekdays: [Int]? {
        switch self {
        case .daily: nil
        case .weekdays: [2, 3, 4, 5, 6]
        case .weekends: [1, 7]
        }
    }
}

struct MealReminder: Codable {
    // MARK: Lifecycle

    init(
        isEnabled: Bool = false,
        time: Date = .now,
        frequency: ReminderFrequency = .daily,
        soundEnabled: Bool = true
    ) {
        self.isEnabled = isEnabled
        self.time = time
        self.frequency = frequency
        self.soundEnabled = soundEnabled
    }

    // MARK: Internal

    var isEnabled: Bool
    var time: Date
    var frequency: ReminderFrequency
    var soundEnabled: Bool

    static func defaultTime(for meal: MealType) -> Date {
        let hour = switch meal {
        case .breakfast: 8
        case .lunch: 13
        case .dinner: 19
        case .snacks: 16
        }
        return Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
    }

    static func `default`(for meal: MealType) -> MealReminder {
        MealReminder(time: defaultTime(for: meal))
    }
}

struct ExerciseReminder: Codable {
    // MARK: Lifecycle

    init(
        isEnabled: Bool = false,
        time: Date = .now,
        frequency: ReminderFrequency = .daily,
        soundEnabled: Bool = true
    ) {
        self.isEnabled = isEnabled
        self.time = time
        self.frequency = frequency
        self.soundEnabled = soundEnabled
    }

    // MARK: Internal

    static var `default`: ExerciseReminder {
        ExerciseReminder(
            time: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: .now) ?? .now
        )
    }

    var isEnabled: Bool
    var time: Date
    var frequency: ReminderFrequency
    var soundEnabled: Bool
}

@MainActor
final class NotificationManager {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared: NotificationManager = .init()

    func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .ephemeral, .provisional: return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .badge, .sound, .provisional])) ?? false
        default: return false
        }
    }

    func requestRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    func scheduleMeal(
        _ meal: MealType,
        time: Date,
        frequency: ReminderFrequency = .daily,
        soundEnabled: Bool = true
    ) {
        let content = UNMutableNotificationContent()
        content.title = mealTitle(for: meal)
        content.body = mealBody(for: meal)
        content.sound = soundEnabled ? .default : nil
        cancelMeal(meal)
        scheduleRepeating(baseID: mealID(meal), content: content, time: time, frequency: frequency)
    }

    func cancelMeal(_ meal: MealType) {
        let ids = [mealID(meal)] + (1...7).map { "\(mealID(meal)).\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    func scheduleExercise(
        time: Date,
        frequency: ReminderFrequency = .daily,
        soundEnabled: Bool = true
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Exercise Time 🏃‍♀️"
        content.body = "A short workout goes a long way. Let's keep moving today!"
        content.sound = soundEnabled ? .default : nil
        cancelExercise()
        scheduleRepeating(baseID: exerciseID, content: content, time: time, frequency: frequency)
    }

    func cancelExercise() {
        let ids = [exerciseID] + (1...7).map { "\(exerciseID).\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func save(mealReminders: [MealType: MealReminder]) {
        let encoded = try? JSONEncoder().encode(mealReminders.mapKeys(\.rawValue))
        UserDefaults.standard.set(encoded, forKey: NotificationKey.mealReminders)
    }

    func loadMealReminders() -> [MealType: MealReminder] {
        guard
            let data = UserDefaults.standard.data(forKey: NotificationKey.mealReminders),
            let decoded = try? JSONDecoder().decode([String: MealReminder].self, from: data)
        else {
            return MealType.allCases.reduce(into: [:]) { $0[$1] = .default(for: $1) }
        }

        return MealType.allCases.reduce(into: [:]) {
            $0[$1] = decoded[$1.rawValue] ?? .default(for: $1)
        }
    }

    func save(exercise: ExerciseReminder) {
        let encoded = try? JSONEncoder().encode(exercise)
        UserDefaults.standard.set(encoded, forKey: NotificationKey.exerciseTime)
    }

    func loadExercise() -> ExerciseReminder {
        guard
            let data = UserDefaults.standard.data(forKey: NotificationKey.exerciseTime),
            let decoded = try? JSONDecoder().decode(ExerciseReminder.self, from: data)
        else {
            return .default
        }

        return decoded
    }

    func mealTitle(for meal: MealType) -> String {
        switch meal {
        case .breakfast: "Good morning! 🌅 Log your breakfast"
        case .lunch: "Lunchtime 🥗"
        case .dinner: "Dinner time 🍽️"
        case .snacks: "Snack break 🍎"
        }
    }

    func mealBody(for meal: MealType) -> String {
        switch meal {
        case .breakfast: "Start your day right — log your breakfast."
        case .lunch: "Time to refuel. Don't forget to log your lunch."
        case .dinner: "Wrap up the day with a healthy dinner."
        case .snacks: "Quick snack? Log it to stay on track."
        }
    }

    // MARK: Private

    private let exerciseID = "com.app.reminder.exercise"

    private func mealID(_ meal: MealType) -> String {
        "com.app.reminder.meal.\(meal.rawValue)"
    }

    private func scheduleRepeating(
        baseID: String,
        content: UNMutableNotificationContent,
        time: Date,
        frequency: ReminderFrequency
    ) {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: time)
        let minute = cal.component(.minute, from: time)

        if let weekdays = frequency.weekdays {
            for weekday in weekdays {
                var comps = DateComponents()
                comps.weekday = weekday
                comps.hour = hour
                comps.minute = minute
                add(UNNotificationRequest(
                    identifier: "\(baseID).\(weekday)",
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                ))
            }
        } else {
            var comps = DateComponents()
            comps.hour = hour
            comps.minute = minute
            add(UNNotificationRequest(
                identifier: baseID,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            ))
        }
    }

    private func add(_ request: UNNotificationRequest) {
        UNUserNotificationCenter.current().add(request)
    }
}

private extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        reduce(into: [:]) { $0[transform($1.key)] = $1.value }
    }
}

struct ProfileNotificationsView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                Toggle("Enable Notifications", isOn: globalToggleBinding)

                if globallyEnabled {
                    Toggle("Promotional Notifications", isOn: remoteToggleBinding)
                        .transition(transition)
                }
            }

            if globallyEnabled {
                Section("Meal Reminders") {
                    ForEach(MealType.allCases, id: \.self) { meal in
                        MealReminderRow(
                            meal: meal,
                            reminder: reminderBinding(for: meal)
                        )
                    }
                }
                .transition(transition)

                Section("Fitness") {
                    ExerciseReminderRow(exercise: exerciseBinding)
                }
                .transition(transition)
            }
        }
        .onChange(of: UIApplication.shared.isRegisteredForRemoteNotifications) {
            if UIApplication.shared.isRegisteredForRemoteNotifications == false {
                Task {
                    await unRegister()
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .animation(animation, value: globallyEnabled)
        .task {
            mealReminders = manager.loadMealReminders()
            exercise = manager.loadExercise()
        }
        .alert("Notifications Disabled", isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.canOpenURL(url)
                }
            }
            Button("Cancel", role: .cancel) {
                globallyEnabled = false
            }
        } message: {
            Text("Please enable notifications in Settings to receive reminders.")
        }
    }

    // MARK: Private

    @AppStorage(NotificationKey.globallyEnabled) private var globallyEnabled = false
    @AppStorage(NotificationKey.remoteEnabled) private var remoteEnabled = false

    @State private var mealReminders: [MealType: MealReminder] = [:]
    @State private var exercise: ExerciseReminder = .default
    @State private var showSettingsAlert = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let manager: NotificationManager = .shared

    private var reduceMotionEnabled: Bool {
        reduceMotion
    }

    private var animation: Animation? {
        reduceMotionEnabled ? nil : .smooth(duration: 0.3)
    }

    private var transition: AnyTransition {
        unsafe reduceMotionEnabled
            ? .opacity
            : .asymmetric(
                insertion: .push(from: .bottom).combined(with: .opacity),
                removal: .push(from: .top).combined(with: .opacity)
            )
    }

    private var globalToggleBinding: Binding<Bool> {
        Binding(
            get: { globallyEnabled },
            set: { enabled in
                Task {
                    if enabled {
                        let granted = await manager.requestAuthorizationIfNeeded()
                        if granted {
                            globallyEnabled = true
                        } else {
                            let status = await manager.currentAuthorizationStatus()
                            if status == .denied {
                                showSettingsAlert = true
                            }
                            globallyEnabled = false
                        }
                    } else {
                        globallyEnabled = false
                        remoteEnabled = false
                        MealType.allCases.forEach { mealReminders[$0]?.isEnabled = false }
                        exercise.isEnabled = false
                        manager.save(mealReminders: mealReminders)
                        manager.save(exercise: exercise)
                        manager.cancelAll()
                        UIApplication.shared.unregisterForRemoteNotifications()
                    }
                }
            }
        )
    }

    private var remoteToggleBinding: Binding<Bool> {
        Binding(
            get: { remoteEnabled },
            set: { enabled in
                remoteEnabled = enabled
                if enabled {
                    manager.requestRemoteNotifications()
                } else {
                    UIApplication.shared.unregisterForRemoteNotifications()
                }
            }
        )
    }

    private var exerciseBinding: Binding<ExerciseReminder> {
        Binding(
            get: { exercise },
            set: { newValue in
                exercise = newValue
                manager.save(exercise: newValue)
                if newValue.isEnabled {
                    manager.scheduleExercise(
                        time: newValue.time,
                        frequency: newValue.frequency,
                        soundEnabled: newValue.soundEnabled
                    )
                } else {
                    manager.cancelExercise()
                }
            }
        )
    }

    private func unRegister() async {
        let _: NetworkResponse<Bool>? = try? await MCNetworkManager.shared.delete(url: Endpoint.apns.urlString, headers: MCAuthenticationService.authorizationHeaders)
    }

    private func reminderBinding(for meal: MealType) -> Binding<MealReminder> {
        Binding(
            get: { mealReminders[meal] ?? .default(for: meal) },
            set: { newValue in
                mealReminders[meal] = newValue
                manager.save(mealReminders: mealReminders)
                if newValue.isEnabled {
                    manager.scheduleMeal(
                        meal,
                        time: newValue.time,
                        frequency: newValue.frequency,
                        soundEnabled: newValue.soundEnabled
                    )
                } else {
                    manager.cancelMeal(meal)
                }
            }
        )
    }
}

private struct MealReminderRow: View {
    // MARK: Internal

    let meal: MealType
    let reminder: Binding<MealReminder>

    var body: some View {
        NavigationLink {
            MealReminderDetailView(meal: meal, reminder: reminder)
        } label: {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.rawValue.capitalized)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                        .animation(animation, value: reminder.wrappedValue.isEnabled)
                        .animation(animation, value: reminder.wrappedValue.time)
                        .animation(animation, value: reminder.wrappedValue.frequency)
                }
            } icon: {
                Image(systemName: meal.iconName)
                    .foregroundStyle(meal.accentColor)
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var animation: Animation? {
        reduceMotion ? nil : .smooth(duration: 0.3)
    }

    private var subtitle: String {
        guard reminder.wrappedValue.isEnabled else {
            return "Off"
        }

        let time = reminder.wrappedValue.time.formatted(date: .omitted, time: .shortened)
        return "\(reminder.wrappedValue.frequency.label) at \(time)"
    }
}

private struct ExerciseReminderRow: View {
    // MARK: Internal

    let exercise: Binding<ExerciseReminder>

    var body: some View {
        NavigationLink {
            ExerciseReminderDetailView(exercise: exercise)
        } label: {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Exercise Reminder")
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                        .animation(animation, value: exercise.wrappedValue.isEnabled)
                        .animation(animation, value: exercise.wrappedValue.time)
                        .animation(animation, value: exercise.wrappedValue.frequency)
                }
            } icon: {
                Image(systemName: "figure.run")
                    .foregroundStyle(.orange)
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var animation: Animation? {
        reduceMotion ? nil : .smooth(duration: 0.3)
    }

    private var subtitle: String {
        guard exercise.wrappedValue.isEnabled else {
            return "Off"
        }

        let time = exercise.wrappedValue.time.formatted(date: .omitted, time: .shortened)
        return "\(exercise.wrappedValue.frequency.label) at \(time)"
    }
}

struct MealReminderDetailView: View {
    // MARK: Internal

    let meal: MealType

    @Binding var reminder: MealReminder

    var body: some View {
        List {
            Section {
                Toggle("Enable Reminder", isOn: enabledBinding)
            } footer: {
                Text(
                    reminder.isEnabled
                        ? "Fires \(reminder.frequency.label.lowercased()) at \(reminder.time.formatted(date: .omitted, time: .shortened))."
                        : "You'll receive a notification at the selected time."
                )
                .contentTransition(.numericText())
                .animation(animation, value: reminder.isEnabled)
                .animation(animation, value: reminder.time)
                .animation(animation, value: reminder.frequency)
            }

            if reminder.isEnabled {
                Section {
                    DatePicker(
                        "Time",
                        selection: $reminder.time,
                        displayedComponents: .hourAndMinute
                    )
                } footer: {
                    Text("The reminder repeats based on the frequency you choose below.")
                }
                .transition(transition)

                Section("Frequency") {
                    Picker("Frequency", selection: $reminder.frequency) {
                        ForEach(ReminderFrequency.allCases) { freq in
                            VStack(alignment: .leading) {
                                Text(freq.label)
                                Text(freq.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(freq)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                .transition(transition)

                Section {
                    Toggle("Play Sound", isOn: $reminder.soundEnabled)
                } footer: {
                    Text("Play a sound when the reminder fires.")
                }
                .transition(transition)

                NotificationPreviewSection(
                    title: manager.mealTitle(for: meal),
                    description: manager.mealBody(for: meal),
                    icon: meal.iconName,
                    color: meal.accentColor
                )
                .transition(transition)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(meal.rawValue.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .animation(animation, value: reminder.isEnabled)
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let manager: NotificationManager = .shared

    private var animation: Animation? {
        reduceMotion ? nil : .smooth(duration: 0.3)
    }

    private var transition: AnyTransition {
        unsafe reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .push(from: .bottom).combined(with: .opacity),
                removal: .push(from: .top).combined(with: .opacity)
            )
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { reminder.isEnabled },
            set: { enabled in
                reminder.isEnabled = enabled
                if enabled {
                    manager.scheduleMeal(
                        meal,
                        time: reminder.time,
                        frequency: reminder.frequency,
                        soundEnabled: reminder.soundEnabled
                    )
                } else {
                    manager.cancelMeal(meal)
                }
            }
        )
    }
}

struct ExerciseReminderDetailView: View {
    // MARK: Internal

    @Binding var exercise: ExerciseReminder

    var body: some View {
        List {
            Section {
                Toggle("Enable Reminder", isOn: enabledBinding)
            } footer: {
                Text(
                    exercise.isEnabled
                        ? "Fires \(exercise.frequency.label.lowercased()) at \(exercise.time.formatted(date: .omitted, time: .shortened))."
                        : "You'll receive a notification at the selected time."
                )
                .contentTransition(.numericText())
                .animation(animation, value: exercise.isEnabled)
                .animation(animation, value: exercise.time)
                .animation(animation, value: exercise.frequency)
            }

            if exercise.isEnabled {
                Section {
                    DatePicker(
                        "Time",
                        selection: $exercise.time,
                        displayedComponents: .hourAndMinute
                    )
                } footer: {
                    Text("The reminder repeats based on the frequency you choose below.")
                }
                .transition(transition)

                Section("Frequency") {
                    Picker("Frequency", selection: $exercise.frequency) {
                        ForEach(ReminderFrequency.allCases) { freq in
                            VStack(alignment: .leading) {
                                Text(freq.label)
                                Text(freq.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(freq)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                .transition(transition)

                Section {
                    Toggle("Play Sound", isOn: $exercise.soundEnabled)
                } footer: {
                    Text("Play a sound when the reminder fires.")
                }
                .transition(transition)

                NotificationPreviewSection(
                    title: "Exercise Time 🏃‍♀️",
                    description: "A short workout goes a long way. Let's keep moving today!",
                    icon: "figure.run",
                    color: .orange
                )
                .transition(transition)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .animation(animation, value: exercise.isEnabled)
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let manager: NotificationManager = .shared

    private var animation: Animation? {
        reduceMotion ? nil : .smooth(duration: 0.3)
    }

    private var transition: AnyTransition {
        unsafe reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .push(from: .bottom).combined(with: .opacity),
                removal: .push(from: .top).combined(with: .opacity)
            )
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { exercise.isEnabled },
            set: { enabled in
                exercise.isEnabled = enabled
                if enabled {
                    manager.scheduleExercise(
                        time: exercise.time,
                        frequency: exercise.frequency,
                        soundEnabled: exercise.soundEnabled
                    )
                } else {
                    manager.cancelExercise()
                }
            }
        )
    }
}

/// Shared preview card used by both meal and exercise detail views.
private struct NotificationPreviewSection: View {
    // MARK: Internal

    let title: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(color)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                reduceTransparency
                    ? Color(.systemGray5)
                    : Color(.systemBackground).opacity(0.001) // keeps tap area without visual change
            )
        } header: {
            Text("Preview")
        } footer: {
            Text("This is how the notification will appear on your device.")
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
}

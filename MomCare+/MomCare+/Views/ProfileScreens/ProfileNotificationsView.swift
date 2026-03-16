import SwiftUI
import UserNotifications

struct ProfileNotificationsView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section {
                Toggle("Enable Notifications", isOn: $isEnabled)
                    .onChange(of: isEnabled) { _, value in
                        Task {
                            await handleToggle(value)
                        }
                    }
            } footer: {
                Text("Reminders help you stay on track with meals and exercise.")
            }

            if isEnabled {
                Section("Reminders") {
                    Toggle("Meal Logging Reminder", isOn: $mealReminderEnabled)
                        .onChange(of: mealReminderEnabled) { _, enabled in
                            if enabled {
                                scheduleMealReminder()
                            } else {
                                cancelNotification(id: NotificationID.mealReminder)
                            }
                        }

                    if mealReminderEnabled {
                        DatePicker("Meal Time", selection: $mealReminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: mealReminderTime) { scheduleMealReminder() }
                    }

                    Toggle("Exercise Reminder", isOn: $exerciseReminderEnabled)
                        .onChange(of: exerciseReminderEnabled) { _, enabled in
                            if enabled {
                                scheduleExerciseReminder()
                            } else {
                                cancelNotification(id: NotificationID.exerciseReminder)
                            }
                        }

                    if exerciseReminderEnabled {
                        DatePicker("Exercise Time", selection: $exerciseReminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: exerciseReminderTime) { scheduleExerciseReminder() }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadStatus() }
        .alert("Notifications Disabled", isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {
                isEnabled = false
            }
        } message: {
            Text("Please enable notifications in Settings to receive reminders.")
        }
    }

    // MARK: Private

    private enum NotificationID {
        static let mealReminder = "com.momcare.notification.mealReminder"
        static let exerciseReminder = "com.momcare.notification.exerciseReminder"
    }

    @State private var isEnabled = false
    @State private var mealReminderEnabled = false
    @State private var exerciseReminderEnabled = false
    @State private var mealReminderTime: Date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var exerciseReminderTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showSettingsAlert = false

}

private extension ProfileNotificationsView {

    func loadStatus() {
        isEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        mealReminderEnabled = UserDefaults.standard.bool(forKey: "mealReminderEnabled")
        exerciseReminderEnabled = UserDefaults.standard.bool(forKey: "exerciseReminderEnabled")

        if let saved = UserDefaults.standard.object(forKey: "mealReminderTime") as? Date {
            mealReminderTime = saved
        }
        if let saved = UserDefaults.standard.object(forKey: "exerciseReminderTime") as? Date {
            exerciseReminderTime = saved
        }
    }

    func handleToggle(_ value: Bool) async {
        if value {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    isEnabled = true
                    UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            isEnabled = granted
                            UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
                            if !granted {
                                showSettingsAlert = true
                            }
                        }
                    }
                default:
                    isEnabled = false
                    UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                    showSettingsAlert = true
                }
            }
        } else {
            isEnabled = false
            UserDefaults.standard.set(false, forKey: "notificationsEnabled")
            mealReminderEnabled = false
            exerciseReminderEnabled = false
            UserDefaults.standard.set(false, forKey: "mealReminderEnabled")
            UserDefaults.standard.set(false, forKey: "exerciseReminderEnabled")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
                NotificationID.mealReminder,
                NotificationID.exerciseReminder
            ])
        }
    }

    func scheduleMealReminder() {
        UserDefaults.standard.set(mealReminderEnabled, forKey: "mealReminderEnabled")
        UserDefaults.standard.set(mealReminderTime, forKey: "mealReminderTime")

        guard mealReminderEnabled else { return }

        cancelNotification(id: NotificationID.mealReminder)

        let content = UNMutableNotificationContent()
        content.title = "Time to Log Your Meal 🍽️"
        content.body = "Don't forget to track what you've eaten today to meet your nutrition goals."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: mealReminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.mealReminder, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                
                DebugLogger.shared.log("Failed to schedule meal reminder: \(error.localizedDescription)", level: .error, category: .error)
            }
        }
    }

    func scheduleExerciseReminder() {
        UserDefaults.standard.set(exerciseReminderEnabled, forKey: "exerciseReminderEnabled")
        UserDefaults.standard.set(exerciseReminderTime, forKey: "exerciseReminderTime")

        guard exerciseReminderEnabled else { return }

        cancelNotification(id: NotificationID.exerciseReminder)

        let content = UNMutableNotificationContent()
        content.title = "Exercise Time 🏃‍♀️"
        content.body = "A short workout goes a long way. Let's keep moving today!"
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: exerciseReminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.exerciseReminder, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                DebugLogger.shared.log("Failed to schedule exercise reminder: \(error.localizedDescription)", level: .error, category: .error)
            }
        }
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}

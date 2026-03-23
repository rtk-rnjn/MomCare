import Foundation
import HealthKit
import UserNotifications
import Combine

struct WaterLogEntry: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let milliliters: Double

    var formattedDateTime: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }

    var formattedAmount: String {
        if milliliters >= 1000 {
            return Measurement(value: milliliters / 1000, unit: UnitVolume.liters)
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        numberFormatStyle: .number.precision(.fractionLength(1))
                    )
                )
        } else {
            return Measurement(value: milliliters, unit: UnitVolume.milliliters)
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        numberFormatStyle: .number.precision(.fractionLength(0))
                    )
                )
        }
    }
}

@MainActor
final class WaterStore: ObservableObject {

    // MARK: Internal

    static let waterTips: [(icon: String, tip: String)] = [
        ("drop.fill", "Add a slice of lemon or cucumber to make plain water more appealing."),
        ("clock.fill", "Drink a glass first thing in the morning before breakfast."),
        ("fork.knife", "Have a glass of water with every meal and snack."),
        ("figure.walk", "Drink an extra 200–300 ml for every 30 minutes of light activity."),
        ("moon.fill", "Keep a water bottle on your nightstand for night-time sips."),
        ("exclamationmark.triangle.fill", "Dark urine is a sign you need more water — aim for pale yellow."),
        ("heart.fill", "Proper hydration reduces swelling and supports healthy blood pressure."),
        ("leaf.fill", "Herbal teas and broths count toward your daily fluid intake.")
    ]

    @Published var todayTotal: Double = 0
    @Published var dailyTarget: Double = 2500
    @Published var todayLogs: [WaterLogEntry] = []
    @Published var isLoading = false
    @Published var notificationsEnabled = false
    @Published var reminderIntervalHours: Int = 2
    @Published var error: (any Error)?

    var progress: Double {
        guard dailyTarget > 0 else { return 0 }
        return min(todayTotal / dailyTarget, 1.0)
    }

    var remaining: Double { max(dailyTarget - todayTotal, 0) }

    func setup() async {
        await fetchWater()
        await checkNotificationStatus()
    }

    func log(milliliters: Double, at date: Date = Date()) async {
        guard milliliters > 0 else { return }
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: milliliters)
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: date, end: date)

        do {
            try await healthStore.save(sample)

            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                todayTotal += milliliters
                todayLogs.insert(
                    WaterLogEntry(id: sample.uuid, date: date, milliliters: milliliters),
                    at: 0
                )

                todayLogs.sort { $0.date > $1.date }
            }
        } catch {
            print("[WaterStore] Save failed:", error)
        }
    }

    func delete(entry: WaterLogEntry) async {
        let predicate = HKQuery.predicateForObject(with: entry.id)
        let query = HKSampleQuery(
            sampleType: waterType,
            predicate: predicate,
            limit: 1,
            sortDescriptors: nil
        ) { [weak self] _, samples, _ in
            guard let self, let sample = samples?.first else { return }
            Task { @MainActor in
                do {
                    try await self.healthStore.delete(sample)
                    self.todayTotal = max(self.todayTotal - entry.milliliters, 0)
                    self.todayLogs.removeAll { $0.id == entry.id }
                } catch {
                    self.error = error
                }
            }
        }
        healthStore.execute(query)
    }

    func fetchWater(for date: Date = .init()) async {
        isLoading = true
        defer { isLoading = false }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let (total, entries): (Double, [WaterLogEntry]) = await withCheckedContinuation { continuation in
            let q = HKSampleQuery(
                sampleType: waterType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let hk = samples as? [HKQuantitySample] ?? []
                let total = hk.reduce(0.0) { $0 + $1.quantity.doubleValue(for: .literUnit(with: .milli)) }
                let entries = hk.map {
                    WaterLogEntry(id: $0.uuid, date: $0.startDate, milliliters: $0.quantity.doubleValue(for: .literUnit(with: .milli)))
                }
                continuation.resume(returning: (total, entries))
            }
            healthStore.execute(q)
        }

        todayTotal = total
        todayLogs = entries
    }

    func checkNotificationStatus() async {
        let s = await UNUserNotificationCenter.current().notificationSettings()
        notificationsEnabled = s.authorizationStatus == .authorized
    }

    func toggleReminders(_ enabled: Bool) async {
        if enabled {
            let granted = (try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            notificationsEnabled = granted
            if granted { await scheduleReminders() }
        } else {
            cancelReminders()
            notificationsEnabled = false
        }
    }

    func scheduleReminders() async {
        cancelReminders()
        guard notificationsEnabled else { return }
        let center = UNUserNotificationCenter.current()
        var hour = 7
        while hour <= 22 {
            let content = UNMutableNotificationContent()
            content.title = "Hydration time 💧"
            content.body = Self.randomReminderMessage()
            content.sound = .default
            content.interruptionLevel = .passive
            var dc = DateComponents()
            dc.hour = hour
            dc.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            let request = UNNotificationRequest(identifier: "water_\(hour)", content: content, trigger: trigger)
            try? await center.add(request)
            hour += reminderIntervalHours
        }
    }

    func cancelReminders() {
        let ids = stride(from: 7, through: 22, by: reminderIntervalHours).map { "water_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: Private

    private let healthStore: HKHealthStore = .init()
    private let waterType: HKQuantityType = .init(.dietaryWater)

    private static func randomReminderMessage() -> String {
        let messages = [
            "Time for a little sip, mama 💕",
            "Your baby loves when you stay hydrated 🌸",
            "A glass of water keeps tiredness away ✨",
            "Hydration check — you've got this! 💧",
            "Little sips, big impact. Drink up! 🌷"
        ]
        return messages.randomElement()!
    }
}

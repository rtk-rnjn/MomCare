import HealthKit

extension ContentServiceHandler {
    nonisolated func logWaterIntake(milliliters: Double, at date: Date = Date()) async throws -> WaterLogEntry {
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: milliliters)
        let sample = HKQuantitySample(type: .init(.dietaryWater), quantity: quantity, start: date, end: date)

        try await healthStore.save(sample)
        fetchWaterIntake()

        return WaterLogEntry(id: sample.uuid, date: date, milliliters: milliliters)
    }

    nonisolated func fetchWaterIntake(for date: Date = .init()) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: HKQuantityType(.dietaryWater),
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sort]
        ) { _, samples, _ in
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }

            let total = samples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: .literUnit(with: .milli)) }
            let entries = samples.map {
                WaterLogEntry(id: $0.uuid, date: $0.startDate, milliliters: $0.quantity.doubleValue(for: .literUnit(with: .milli)))
            }

            DispatchQueue.main.async {
                self.waterIntakeTodayInMilliliters = total
                if Calendar.current.isDate(date, inSameDayAs: .init()) {
                    self.todayWaterIntakeLogs = entries
                }
                self.queryWaterIntakeEntries = entries
            }
        }
        healthStore.execute(query)
    }

    nonisolated func deleteWaterIntake(_ entry: WaterLogEntry) async throws {
        let predicate = HKQuery.predicateForObject(with: entry.id)
        let query = HKSampleQuery(
            sampleType: HKQuantityType(.dietaryWater),
            predicate: predicate,
            limit: 1,
            sortDescriptors: nil
        ) { _, samples, _ in
            guard let sample = samples?.first else {
                return
            }

            Task {
                try? await self.healthStore.delete(sample)
                await MainActor.run {
                    self.waterIntakeTodayInMilliliters = max(self.waterIntakeTodayInMilliliters - entry.milliliters, 0)
                }
            }
        }
        healthStore.execute(query)
        fetchWaterIntake()
    }
}

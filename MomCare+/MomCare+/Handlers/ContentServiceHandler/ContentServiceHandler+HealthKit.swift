import HealthKit

extension ContentServiceHandler {
    func requestHealthKitAccess() async throws {
        let readQuantityIdentifiers: [HKQuantityTypeIdentifier] = [
            .activeEnergyBurned, .stepCount, .appleExerciseTime, .height, .bodyMass, .dietaryWater,
            .dietaryEnergyConsumed, .dietaryProtein, .dietaryCarbohydrates, .dietaryFatTotal, .dietarySugar, .dietarySodium
        ]

        let writeQuantityIdentifiers: [HKQuantityTypeIdentifier] = [
            .height, .bodyMass, .dietaryWater,
            .dietaryEnergyConsumed, .dietaryProtein, .dietaryCarbohydrates, .dietaryFatTotal, .dietarySugar, .dietarySodium
        ]

        let readCategoryIdentifiers: [HKCategoryTypeIdentifier] = [
            .mindfulSession, .pregnancy
        ]

        let writeCategoryIdentifiers: [HKCategoryTypeIdentifier] = [
            .mindfulSession, .pregnancy
        ]

        let readCharacteristicIdentifiers: [HKCharacteristicTypeIdentifier] = [
            .biologicalSex, .dateOfBirth
        ]

        let readQuantityTypes = readQuantityIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) }
        let writeQuantityTypes = writeQuantityIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) }

        let readCategoryTypes = readCategoryIdentifiers.compactMap { HKObjectType.categoryType(forIdentifier: $0) }
        let writeCategoryTypes = writeCategoryIdentifiers.compactMap { HKObjectType.categoryType(forIdentifier: $0) }

        let readCharacteristicTypes = readCharacteristicIdentifiers.compactMap { HKObjectType.characteristicType(forIdentifier: $0) }

        let readTypes: Set<HKObjectType> =
            Set(readQuantityTypes)
            .union(readCategoryTypes)
            .union(readCharacteristicTypes)

        let writeTypes: Set<HKSampleType> =
            Set(writeQuantityTypes)
            .union(writeCategoryTypes)

        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    nonisolated func startStepCountObservation() async throws {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            fatalError()
        }

        let now = Date()
        let startOfDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDate, end: now, options: .strictStartDate)

        let query = HKObserverQuery(sampleType: stepType, predicate: predicate) { _, _, error in
            if error != nil {
                return
            }
            self.fetchTodaySteps()
        }
        healthStore.execute(query)
        try await healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate)

        fetchTodaySteps()
    }

    nonisolated func fetchTodaySteps() {
        fetchHealthData(quantityTypeIdentifier: .stepCount, unit: .count()) { count in
            DispatchQueue.main.async {
                self.stepsToday = count
            }
        }
    }

    nonisolated func fetchHealthData(
        quantityTypeIdentifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        startDate: Date = Calendar.current.startOfDay(for: Date()),
        endDate: Date = .init(),
        completionHandler: @escaping @Sendable (Double) -> Void
    ) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            completionHandler(value)
        }

        healthStore.execute(query)
    }

    nonisolated func writeHealthData(
        quantityTypeIdentifier: HKQuantityTypeIdentifier,
        value: Double,
        unit: HKUnit
    ) async throws {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            return
        }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: start, end: end)

        try await healthStore.save(sample)
    }
}

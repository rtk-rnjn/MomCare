import HealthKit
import OSLog

private let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier ?? "MomCare", category: "HealthKit")

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

        let symptomsReadWrite: [HKCategoryTypeIdentifier] = [
             .lowerBackPain,
             .constipation,
             .abdominalCramps,
             .dizziness,
             .hotFlashes,
             .appetiteChanges,
             .headache,
             .bladderIncontinence,
             .heartburn,
             .pelvicPain,
             .drySkin,
             .acne,
             .breastPain,
             .fatigue,
             .sleepChanges,
             .nausea,
             .vomiting,
             .shortnessOfBreath,
             .rapidPoundingOrFlutteringHeartbeat,
             .fever,
             .chills,
             .generalizedBodyAche,
             .nightSweats,
             .moodChanges,
             .hairLoss
        ]

        let stateOfMind = HKStateOfMindType.stateOfMindType()

        let readQuantityTypes = readQuantityIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) }
        let writeQuantityTypes = writeQuantityIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) }

        let readCategoryTypes = readCategoryIdentifiers.compactMap { HKObjectType.categoryType(forIdentifier: $0) }
        let writeCategoryTypes = writeCategoryIdentifiers.compactMap { HKObjectType.categoryType(forIdentifier: $0) }

        let readCharacteristicTypes = readCharacteristicIdentifiers.compactMap { HKObjectType.characteristicType(forIdentifier: $0) }

        let readSymptomTypes = symptomsReadWrite.compactMap { HKObjectType.categoryType(forIdentifier: $0) }
        let writeSymptomTypes = symptomsReadWrite.compactMap { HKObjectType.categoryType(forIdentifier: $0) }

        let readTypes: Set<HKObjectType> =
            Set(readQuantityTypes)
            .union(readCategoryTypes)
            .union(readCharacteristicTypes)
            .union([stateOfMind])
            .union(readSymptomTypes)

        let writeTypes: Set<HKSampleType> =
            Set(writeQuantityTypes)
            .union(writeCategoryTypes)
            .union([stateOfMind])
            .union(writeSymptomTypes)

        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    nonisolated func startStepCountObservation() async throws {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            logger.error("Failed to create HKQuantityType for stepCount; skipping observation setup.")
            return
        }

        let startOfDate = Calendar.current.startOfDay(for: .init())
        let endOfDate = Calendar.current.date(byAdding: .day, value: 1, to: startOfDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDate, end: endOfDate, options: .strictStartDate)

        let query = HKObserverQuery(sampleType: stepType, predicate: predicate) { _, completionHandler, error in
            defer { completionHandler() }
            if let error {
                logger.error("Error in step count observer query: \(error.localizedDescription)")
            }
            self.fetchTodaySteps()
        }
        healthStore.execute(query)
        try await healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate)

        fetchTodaySteps()
    }

    nonisolated func fetchTodaySteps() {
        let startDate = Calendar.current.startOfDay(for: .init())
        let endDate = Date()

        fetchHealthData(quantityTypeIdentifier: .stepCount, unit: .count(), startDate: startDate, endDate: endDate) { count in
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
        unit: HKUnit,
        start: Date = .init(),
        end: Date = .init()
    ) async throws {
        let quantityType = HKQuantityType(quantityTypeIdentifier)

        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: start, end: end)

        try await healthStore.save(sample)
    }

    nonisolated func writeHealthData( // swiftlint:disable:this function_parameter_count
        categoryTypeIdentifier: HKCategoryTypeIdentifier,
        value: Int,
        start: Date,
        end: Date,
        device: HKDevice?,
        metadata: [String: Any]?
    ) async throws {
        let categoryType = HKCategoryType(categoryTypeIdentifier)

        let sample = HKCategorySample(type: categoryType, value: value, start: start, end: end, device: device, metadata: metadata)

        try await healthStore.save(sample)
    }

    nonisolated func sync(heightInCentimeters height: Double) async throws {
        guard let heightType = HKObjectType.quantityType(forIdentifier: .height) else {
            return
        }

        let quantity = HKQuantity(unit: .meterUnit(with: .centi), doubleValue: height)

        let now = Date()
        let sample = HKQuantitySample(type: heightType, quantity: quantity, start: now, end: now)

        try await healthStore.save(sample)
    }

    nonisolated func sync(weightInKilograms weight: Double) async throws {
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            return
        }

        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: weight)

        let now = Date()
        let sample = HKQuantitySample(type: weightType, quantity: quantity, start: now, end: now)

        try await healthStore.save(sample)
    }
}

extension ContentServiceHandler {
    nonisolated func saveSymptom(_ model: SymptomModel) async throws {
        guard
            let symptomId = model.symptomId,
            let symptom = PregnancySymptoms.allSymptoms.first(where: { $0.id == symptomId }),
            let identifiers = symptom.healthKitIdentifier
        else {
            return
        }

        let userModel: UserModel? = await Database.shared[.userModel]

        var metadata: [String: Any] = [
            HKMetadataKeyExternalUUID: model.id.uuidString,
            "momcare.symptomId": symptomId,
            "momcare.symptomName": symptom.name
        ]

        if let id = userModel?.id {
            metadata["momcare.userId"] = id
        }

        let samples: [HKCategorySample] = identifiers.compactMap { identifier in
            guard let type = HKObjectType.categoryType(forIdentifier: identifier) else {
                return nil
            }

            return HKCategorySample(
                type: type,
                value: HKCategoryValueSeverity.mild.rawValue,
                start: model.date,
                end: model.date,
                metadata: metadata
            )
        }

        guard !samples.isEmpty else {
            return
        }

        try await healthStore.save(samples)
    }

    nonisolated func fetchSymptoms(for date: Date) async throws -> [HKCategorySample] {
        let userModel: UserModel? = await Database.shared[.userModel]
        guard let userId = userModel?.id else {
            return []
        }

        let identifiers = PregnancySymptoms.allSymptoms
            .compactMap(\.healthKitIdentifier)
            .flatMap { $0 }

        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!

        var results = [HKCategorySample]()

        try await withThrowingTaskGroup(of: [HKCategorySample].self) { group in
            for identifier in identifiers {
                group.addTask { [healthStore] in
                    guard let type = HKObjectType.categoryType(forIdentifier: identifier) else {
                        return []
                    }

                    let datePredicate = HKQuery.predicateForSamples(
                        withStart: start,
                        end: end,
                        options: .strictStartDate
                    )

                    let userPredicate = HKQuery.predicateForObjects(
                        withMetadataKey: "momcare.userId",
                        operatorType: .equalTo,
                        value: userId
                    )

                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                        datePredicate,
                        userPredicate
                    ])

                    return try await withCheckedThrowingContinuation { continuation in
                        let query = HKSampleQuery(
                            sampleType: type,
                            predicate: predicate,
                            limit: HKObjectQueryNoLimit,
                            sortDescriptors: nil
                        ) { _, samples, error in
                            if let error {
                                continuation.resume(throwing: error)
                                return
                            }

                            continuation.resume(returning: samples as? [HKCategorySample] ?? [])
                        }

                        healthStore.execute(query)
                    }
                }
            }

            for try await samples in group {
                results.append(contentsOf: samples)
            }
        }

        return results
    }

    nonisolated func deleteSymptom(_ model: SymptomModel) async throws {
        let userModel: UserModel? = await Database.shared[.userModel]
        guard let userId = userModel?.id else {
            return
        }

        let uuidPredicate = HKQuery.predicateForObjects(
            withMetadataKey: HKMetadataKeyExternalUUID,
            allowedValues: [model.id.uuidString]
        )

        let userPredicate = HKQuery.predicateForObjects(
            withMetadataKey: "momcare.userId",
            operatorType: .equalTo,
            value: userId
        )

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            uuidPredicate,
            userPredicate
        ])

        let types = PregnancySymptoms.allSymptoms
            .compactMap(\.healthKitIdentifier)
            .flatMap { $0 }

        for identifier in types {
            guard let type = HKObjectType.categoryType(forIdentifier: identifier) else {
                continue
            }

            let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: type,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { _, samples, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    continuation.resume(returning: samples as? [HKCategorySample] ?? [])
                }

                healthStore.execute(query)
            }

            guard !samples.isEmpty else {
                continue
            }

            try await healthStore.delete(samples)
        }
    }

    func editSymptom(old: SymptomModel, new: SymptomModel) async throws {
        try await deleteSymptom(old)
        try await saveSymptom(new)
    }
}

extension ContentServiceHandler {
    nonisolated func saveBreathingSession(
        start: Date,
        end: Date,
    ) async throws {
        let userModel: UserModel? = await Database.shared[.userModel]
        guard let userId = userModel?.id else {
            return
        }
        guard let type = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            return
        }

        let metadata: [String: Any] = [
            "momcare.userId": userId,
            "momcare.activity": "breathing",
            HKMetadataKeyExternalUUID: UUID().uuidString
        ]

        let sample = HKCategorySample(
            type: type,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end,
            metadata: metadata
        )

        try await healthStore.save(sample)
    }

    nonisolated func fetchBreathingCompletionSeconds(for date: Date) async throws -> TimeInterval {
        let userModel: UserModel? = await Database.shared[.userModel]
        guard let userId = userModel?.id else {
            return 0
        }
        guard let type = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            return 0
        }

        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!

        let datePredicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        let userPredicate = HKQuery.predicateForObjects(
            withMetadataKey: "momcare.userId",
            operatorType: .equalTo,
            value: userId
        )

        let activityPredicate = HKQuery.predicateForObjects(
            withMetadataKey: "momcare.activity",
            operatorType: .equalTo,
            value: "breathing"
        )

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            datePredicate,
            userPredicate,
            activityPredicate
        ])

        let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: samples as? [HKCategorySample] ?? [])
            }

            healthStore.execute(query)
        }

        let internval = samples.reduce(0.0) { partial, sample in
            partial + sample.endDate.timeIntervalSince(sample.startDate)
        }

        if Calendar.current.isDate(date, inSameDayAs: Date()) {
            await MainActor.run {
                self.breathingTodayInSeconds = internval
            }
        }

        return internval
    }

    nonisolated func fetchBreathingProgress(for date: Date, withTarget target: TimeInterval) async throws -> Double {
        let completedSeconds = try await fetchBreathingCompletionSeconds(for: date)
        return min(completedSeconds / target, 1.0)
    }
}

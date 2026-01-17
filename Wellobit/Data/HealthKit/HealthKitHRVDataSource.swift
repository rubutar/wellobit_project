final class HealthKitHRVDataSource: HRVDataSource {

    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    func fetchTodayHRV(
        startDate: Date,
        endDate: Date
    ) async throws -> [HRVPoint] {

        let sdnnType = HKQuantityType.quantityType(
            forIdentifier: .heartRateVariabilitySDNN
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sdnnType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let points = (samples as? [HKQuantitySample])?
                    .map { sample in
                        HRVPoint(
                            date: sample.startDate,
                            value: sample.quantity.doubleValue(for: .secondUnit(with: .milli)),
                            type: .sdnn
                        )
                    } ?? []

                continuation.resume(returning: points)
            }

            healthStore.execute(query)
        }
    }
}

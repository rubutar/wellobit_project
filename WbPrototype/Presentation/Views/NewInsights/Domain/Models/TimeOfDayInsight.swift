import Foundation

/// HRV insight for a single time-of-day window.
struct TimeOfDayInsight: Identifiable {
    let id: UUID
    let segment: TimeOfDaySegment
    let status: HRVStatusNew
}

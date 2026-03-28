import Foundation

/// Aggregated weekly HRV summary shown at the bottom of the Insights screen.
struct InsightsSummary {
    let weekStart: Date
    let weekEnd: Date
    let averageHRV: Int
    let deltaVsLastWeek: Int    // positive = improvement
    let bestDayName: String     // e.g. "Sat"
    let bestDayStatus: HRVStatusNew

    var weekRangeFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return "\(f.string(from: weekStart)) - \(f.string(from: weekEnd))"
    }
}

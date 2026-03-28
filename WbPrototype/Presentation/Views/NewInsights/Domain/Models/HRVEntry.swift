import Foundation

/// A single HRV data point representing one day in the chart.
struct HRVEntry: Identifiable {
    let id: UUID
    let date: Date
    let value: Int          // HRV in milliseconds
    let quality: HRVQuality

    var dayAbbreviation: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return String(f.string(from: date).prefix(1)).uppercased()
    }

    var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }
}

import Foundation

/// Full HRV breakdown for a single day, split into time-of-day segments.
struct DayInsight: Identifiable {
    let id: UUID
    let date: Date
    let avgHRV: Int
    let segments: [TimeOfDayInsight]

    var dayName: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: date)
    }

    var shortDate: String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: date)
    }
}

/// Four time-of-day windows used to break down daily HRV data.
enum TimeOfDaySegment: Int, CaseIterable {
    case earlyMorning = 0   // 12 am – 4 am
    case morning            // 4 am – 9 am
    case afternoon          // 9 am – 5 pm
    case evening            // 5 pm – 12 am

    var timeLabel: String {
        switch self {
        case .earlyMorning: return "12 am – 06 am"
        case .morning:      return "06 am – 12 pm"
        case .afternoon:    return "12 pm – 6 pm"
        case .evening:      return "6 pm – 12 pm"
        }
    }

    var segmentTitle: String {
        switch self {
        case .earlyMorning: return "Deep Recovery"
        case .morning:      return "Early morning reset"
        case .afternoon:    return "Day performance"
        case .evening:      return "Wind down"
        }
    }
}

import Foundation

struct SleepScore {
    let value: Int            // 0–100
    let label: SleepScoreLabel
}

enum SleepScoreLabel: String {
    case excellent
    case good
    case fair
    case poor
}

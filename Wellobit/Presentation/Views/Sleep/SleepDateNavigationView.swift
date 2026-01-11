import SwiftUI

struct SleepDateNavigationView: View {

    let date: Date
    let onPrevious: () -> Void
    let onNext: () -> Void

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }

            Spacer()

            Text(title)
                .font(.headline)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .opacity(isToday ? 0.3 : 1)
            }
            .disabled(isToday)
        }
        .padding(.horizontal)
    }

    private var title: String {
        if isToday {
            return "Today"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: date)
    }
}

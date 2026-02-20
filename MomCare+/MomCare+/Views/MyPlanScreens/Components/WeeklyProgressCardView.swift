import SwiftUI

struct DayProgress: Identifiable {
    let id: UUID = .init()
    let date: Date
    let completionPercentage: Double = 0

    var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"

        let dayName = formatter.string(from: date)
        return String(dayName.prefix(3))
    }

}

struct WeeklyProgressCardView: View {

    // MARK: Internal

    let completedCount: Int
    let totalCount: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Weekly Progress")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                let weekday = Calendar.current.component(.weekday, from: Date())
                Text("\(weekday)/7 days")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 0) {
                ForEach(weeklyProgress) { day in
                    DayRingView(dayName: day.dayName, progress: day.completionPercentage, date: day.date)
                        .frame(maxWidth: .infinity)
                }
            }

            VStack(spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "target")
                            .font(.subheadline)
                            .foregroundColor(Color.CustomColors.mutedRaspberry)
                            .accessibilityHidden(true)

                        Text("Total: \(completedCount)/\(totalCount)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Text("\(Int(overallProgress * 100))%")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color.CustomColors.mutedRaspberry)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))

                        Capsule()
                            .fill(Color.CustomColors.mutedRaspberry)
                            .frame(width: geo.size.width * overallProgress)
                    }
                }
                .frame(height: 8)
                .accessibilityHidden(true)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .accessibilityElement(children: .contain)
        .task {
            let range = Utils.weekRange(containing: Date())
            var temp = [DayProgress]()
            for date in range {
                temp.append(DayProgress(date: date))
            }
            weeklyProgress = temp
        }
    }

    // MARK: Private

    @State private var weeklyProgress: [DayProgress] = []

    private var overallProgress: Double {
        guard totalCount > 0 else { return 0 }
        return min(Double(completedCount) / Double(totalCount), 1.0)
    }

}

private struct DayRingView: View {
    let dayName: String
    let progress: Double
    let date: Date

    var body: some View {
        VStack(spacing: 6) {
            Text(dayName)
                .font(.caption.weight(.semibold))
                .foregroundColor(Calendar.current.isDate(date, inSameDayAs: Date()) ? .black : Color.CustomColors.mutedRaspberry)

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        Color.CustomColors.mutedRaspberry,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                if progress >= 1.0 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color.CustomColors.mutedRaspberry)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: 30, height: 30)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(dayName)
        .accessibilityValue(progress >= 1.0 ? "Complete" : "\(Int(progress * 100)) percent")
    }
}

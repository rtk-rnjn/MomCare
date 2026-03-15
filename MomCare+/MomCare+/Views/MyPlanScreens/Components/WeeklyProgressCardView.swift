import SwiftUI

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
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                let weekday = Calendar.current.component(.weekday, from: Date())
                Text("\(weekday)/7 days")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
                    .contentTransition(reduceMotion ? .identity : .numericText(value: Double(weekday)))
                    .animation(reduceMotion ? nil : .easeInOut, value: weekday)
            }

            HStack(spacing: 0) {
                ForEach(contentServiceHandler.weeklyProgress) { day in
                    DayRingView(dayName: day.dayName, progress: day.completionPercentage, date: day.date)
                        .frame(maxWidth: .infinity)
                }
            }
            .accessibilityElement(children: .contain)

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
                            .contentTransition(reduceMotion ? .identity : .numericText(value: Double(completedCount)))
                            .animation(reduceMotion ? nil : .easeInOut, value: completedCount)
                    }

                    Spacer()

                    Text("\(Int(overallProgress * 100))%")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color.CustomColors.mutedRaspberry)
                        .contentTransition(reduceMotion ? .identity : .numericText(value: overallProgress))
                        .animation(reduceMotion ? nil : .easeInOut, value: overallProgress)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))

                        Capsule()
                            .fill(Color.CustomColors.mutedRaspberry)
                            .frame(width: geo.size.width * overallProgress)
                            .animation(reduceMotion ? nil : .easeInOut, value: overallProgress)
                    }
                }
                .frame(height: 8)
                .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Overall progress")
            .accessibilityValue("\(completedCount) of \(totalCount) exercises completed, \(Int(overallProgress * 100)) percent")
            .accessibilityAddTraits(.updatesFrequently)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var overallProgress: Double {
        guard totalCount > 0 else { return 0 }
        return min(Double(completedCount) / Double(totalCount), 1.0)
    }

}

private struct DayRingView: View {

    // MARK: Internal

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
                    .animation(reduceMotion ? nil : .easeInOut, value: progress)

                if progress >= 1.0 {
                    Image(systemName: "checkmark")
                        .font(.caption2.bold())
                        .foregroundColor(Color.CustomColors.mutedRaspberry)
                }
            }
            .frame(width: 30, height: 30)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(dayName)
        .accessibilityValue(progress >= 1.0 ? "completed" : "\(Int(progress * 100)) percent")
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

struct DayProgress: Identifiable {
    let id: UUID = .init()
    let date: Date
    var completionPercentage: Double

    var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"

        let dayName = formatter.string(from: date)
        return String(dayName.prefix(3))
    }

}

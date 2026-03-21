import SwiftUI

struct DashboardWeekCardView: View {

    let week: Int?
    let day: Int?
    let trimester: String?

    var body: some View {
        VStack(spacing: 0) {

            VStack(alignment: .leading, spacing: 8) {
                Text("Week \(week ?? 0)")
                    .font(.title2)

                Text("Day \(day ?? 0)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 14)

            Spacer(minLength: 0)

            ZStack(alignment: .trailing) {
                Rectangle()
                    .fill(Color("secondaryAppColor"))
                    .frame(height: 52)

                HStack {
                    Text("Trimester \(trimester ?? "-")")
                        .font(.title3.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .padding(.leading, 16)

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color("secondaryAppColor"))
                            .frame(width: 38, height: 38)

                        Image(systemName: "calendar")
                            .foregroundColor(.primary)
                            .font(.title3)
                    }
                    .accessibilityHidden(true)
                    .padding(.trailing, 12)
                    .offset(y: -20)
                }
            }
        }
        .frame(minHeight: 160)
        .background(Color(.systemBackground))
        .dashboardCardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pregnancy progress")
        .accessibilityValue("Week \(week ?? 0), Day \(day ?? 0), Trimester \(trimester ?? "unknown")")
        .accessibilityAddTraits([.isButton, .updatesFrequently])
        .accessibilityHint("Double tap to view detailed pregnancy progress")
        .accessibilityIdentifier("dashboardWeekCard")
    }
}

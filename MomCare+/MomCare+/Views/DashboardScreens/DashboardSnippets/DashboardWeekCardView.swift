import SwiftUI
import TipKit

struct DashboardWeekCardView<TipContent: Tip>: View {
    let week: Int?
    let day: Int?
    let trimester: String?

    let tip: TipContent?

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Week")
                        .font(.title2)
                    if let week {
                        Text(week, format: .number)
                            .font(.title2)
                    }
                }

                HStack {
                    Text("Day")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    if let day {
                        Text(day, format: .number)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
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
                        .compatPopoverTip(tip, arrowEdge: .top)

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color("secondaryAppColor"))
                            .frame(width: 38, height: 38)

                        Image(systemName: "calendar")
                            .foregroundStyle(.primary)
                            .font(.title3)
                    }
                    .accessibilityHidden(true)
                    .padding(.trailing, 12)
                    .offset(y: -20)
                }
            }
        }
        .frame(height: 160)
        .background(Color(.systemBackground))
        .dashboardCardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pregnancy progress")
        .accessibilityValue(accessiblityValue)
        .accessibilityAddTraits([.isButton, .updatesFrequently])
        .accessibilityHint("Double tap to view detailed pregnancy progress")
        .accessibilityIdentifier("dashboardWeekCard")
    }

    private var accessiblityValue: String {
        "Week \(week ?? 0), Day \(day ?? 0), Trimester \(trimester ?? "unknown")"
    }
}

extension View {

    @ViewBuilder
    func compatPopoverTip<TipContent>(
        _ tip: TipContent?,
        arrowEdge: Edge = .top
    ) -> some View where TipContent: Tip {
        if #available(iOS 26.0, *) {
            self.popoverTip(tip, arrowEdge: arrowEdge)
        } else {
            if let tip {
                self.popoverTip(tip, arrowEdge: arrowEdge)
            } else {
                self
            }
        }
    }
}


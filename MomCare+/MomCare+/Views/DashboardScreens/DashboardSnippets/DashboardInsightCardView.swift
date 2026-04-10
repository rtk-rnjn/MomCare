import SwiftUI

struct DashboardInsightCardView: View {
    // MARK: Internal

    let title: LocalizedStringKey
    let message: String
    let systemImageName: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(reduceMotion ? .identity : .interpolate)
                    .animation(reduceMotion ? nil : .easeInOut, value: message)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color("secondaryAppColor"))
                    .frame(height: 56)

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .padding(.leading, 16)
                    .padding(.bottom, 18)
                    .contentTransition(reduceMotion ? .identity : .interpolate)
                    .animation(reduceMotion ? nil : .easeInOut, value: title)

                ZStack {
                    Circle()
                        .fill(Color("secondaryAppColor"))
                        .frame(width: 38, height: 38)

                    Image(systemName: systemImageName)
                        .foregroundStyle(.primary)
                        .font(.title3)
                }
                .accessibilityHidden(true)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 12)
                .offset(y: -37)
            }
        }
        .background(Color(.systemBackground))
        .dashboardCardStyle()
        .frame(minHeight: 190)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(message)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
}

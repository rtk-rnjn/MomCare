

import SwiftUI

struct DashboardInsightCardView: View {
    let title: String
    let message: String
    let icon: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.75),
                        value: message
                    )
            }
            .padding(16)
            .frame(height: 135, alignment: .top)

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

                ZStack {
                    Circle()
                        .fill(Color("secondaryAppColor"))
                        .frame(width: 38, height: 38)

                    Image(systemName: icon)
                        .foregroundColor(.primary)
                        .font(.system(size: 21, weight: .regular))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 12)
                .offset(y: -37)
            }
        }
        .background(Color(.systemBackground))
        .dashboardCardStyle()
        .frame(minHeight: 190)
    }
}

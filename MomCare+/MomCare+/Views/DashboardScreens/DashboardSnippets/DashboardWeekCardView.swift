import SwiftUI

struct DashboardWeekCardView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 0) {
            // Top Content
            VStack(alignment: .leading, spacing: 8) {
                Text("Week \(authenticationService.userModel?.pregnancyProgress.week ?? 0)")
                    .font(.title2)

                Text("Day \(authenticationService.userModel?.pregnancyProgress.day ?? 0)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 14)

            Spacer(minLength: 0)

            // Bottom Bar
            ZStack(alignment: .trailing) {
                Rectangle()
                    .fill(Color("secondaryAppColor"))
                    .frame(height: 52)

                HStack {
                    Text("Trimester \(authenticationService.userModel?.pregnancyProgress.trimester ?? "-")")
                        .font(.system(size: 18, weight: .semibold))
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
                            .font(.system(size: 21, weight: .regular))
                    }
                    .padding(.trailing, 12)
                    .offset(y: -20)
                }
            }
        }
        .frame(minHeight: 160)
        .background(Color(.systemBackground))
        .dashboardCardStyle()
    }

    // MARK: Private

    @EnvironmentObject private var authenticationService: AuthenticationService

}

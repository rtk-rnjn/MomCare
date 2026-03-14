import EventKit
import SwiftUI

struct DashboardEventCardView: View {

    // MARK: Internal

    let upcomingEvent: EKEvent?

    var body: some View {
        VStack(spacing: 0) {
            // Top Content
            VStack(alignment: .leading, spacing: 6) {
                if let event = upcomingEvent {
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .contentTransition(.interpolate)
                        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.85), value: eventKitHandler.eventStore)

                    if let startDate = event.startDate {
                        Text(startDate, format: .relative(presentation: .numeric))
                            .contentTransition(.numericText())
                            .animation(reduceMotion ? nil : .easeInOut, value: startDate)

//                        Text(startDate.formatted(date: .abbreviated, time: .shortened))
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                            .contentTransition(.interpolate)
//                            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: eventKitHandler.eventStore)
                    }

                } else {
                    Text("No Upcoming Events")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
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
                    Button {
                        showEventSheet = true
                    } label: {
                        Text("Add Event")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(MomCareAccent.primary)
                    }
                    .padding(.leading, 16)
                    .buttonStyle(.plain)

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color("secondaryAppColor"))
                            .frame(width: 38, height: 38)

                        Image(systemName: "calendar.badge.clock")
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
        .accessibilityLabel(upcomingEvent.map { "Upcoming event: \($0.title ?? "untitled")" } ?? "No upcoming events")
        .accessibilityValue(
            upcomingEvent?.startDate.map { date in
                "In \(date.formatted(.relative(presentation: .numeric)))"
            } ?? ""
        )
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to add a new event")
        .accessibilityIdentifier("dashboardEventCard")
        .sheet(
            isPresented: $showEventSheet,
            onDismiss: {
                try? eventKitHandler.fetchAllEvents()
            },
            content: {
                TriTrackAddCalendarItemSheetView(selectedDate: $date)
                    .presentationDetents([.medium, .large])
                    .scrollDismissesKeyboard(.immediately)
                    .interactiveDismissDisabled(true)
            }
        )
    }

    // MARK: Private

    @State private var date: Date = .init()

    @EnvironmentObject private var eventKitHandler: EventKitHandler
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showEventSheet: Bool = false

}

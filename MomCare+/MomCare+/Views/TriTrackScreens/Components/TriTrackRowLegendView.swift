import SwiftUI

struct TriTrackRowLegendView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    intro
                    dateCapsuleSection
                    Divider()
                    eventStatusSection
                    Divider()
                    reminderStatusSection
                    Divider()
                    symbolsSection
                    Divider()
                    opacitySection
                    Divider()
                    reminderSwipeActionsSection
                    Divider()
                    eventSwipeActionsSection
                    Divider()
                    calendarItemContextMenuSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("How to Read Your Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                        .accessibilityLabel("Close legend")
                        .accessibilityHint("Dismisses this guide")
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Each row in your calendar uses colors and symbols to give you instant context — no tapping required.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var dateCapsuleSection: some View {
        LegendSection(title: "Date Badge", systemImage: "calendar") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {
                    LegendRow(
                        badge: DateBadgePreview(day: "14", month: "JUL", color: Color.CustomColors.mutedRaspberry, textColor: .white),
                        label: "Today",
                        description: "The badge turns raspberry/pink when the date matches today."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: DateBadgePreview(day: "22", month: "AUG", color: Color(.systemGray6), textColor: .primary),
                        label: "Another day",
                        description: "A neutral gray badge for any date that is not today."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: CalendarIconBadge(),
                        label: "No date set",
                        description: "A calendar icon appears when a reminder has no due date."
                    )
                }
            }
        }
    }

    private var eventStatusSection: some View {
        LegendSection(title: "Event Status", systemImage: "clock") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {
                    LegendRow(
                        badge: StatusDotBadge(color: .green),
                        label: "Upcoming · Today",
                        description: "A green dot and \"Today\" label appear when the event is still ahead of you on the current day."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: StatusDotBadge(color: .red),
                        label: "Ended",
                        description: "A red dot and \"Ended\" label appear once the event start time has passed. The entire row also dims to 60% opacity."
                    )
                }
            }
        }
    }

    private var reminderStatusSection: some View {
        LegendSection(title: "Reminder Status", systemImage: "checklist") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {
                    LegendRow(
                        badge: DateBadgePreview(day: "14", month: "JUL", color: Color.CustomColors.mutedRaspberry, textColor: .white),
                        label: "Due today",
                        description: "Raspberry badge — the reminder is due today."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: DateBadgePreview(day: "10", month: "JUN", color: .red.opacity(0.15), textColor: .red),
                        label: "Overdue",
                        description: "Red tinted badge — the due date has passed and the reminder is not completed."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: DateBadgePreview(day: "10", month: "JUN", color: .orange.opacity(0.15), textColor: .orange),
                        label: "Overdue · Repeating",
                        description: "Orange tinted badge — the due date has passed but this reminder repeats, so future occurrences still exist."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: DateBadgePreview(day: "20", month: "AUG", color: Color(.systemGray6), textColor: .primary),
                        label: "Future",
                        description: "Neutral gray badge — the reminder is upcoming with no recurrence."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: DateBadgePreview(day: "20", month: "AUG", color: .blue.opacity(0.15), textColor: .blue),
                        label: "Future · Repeating",
                        description: "Blue tinted badge — the reminder is upcoming and repeats indefinitely."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: DateBadgePreview(day: "20", month: "AUG", color: .purple.opacity(0.15), textColor: .purple),
                        label: "Future · Repeating with end",
                        description: "Purple tinted badge — the reminder repeats but has a set end date."
                    )
                }
            }
        }
    }

    private var symbolsSection: some View {
        LegendSection(title: "Symbols", systemImage: "info.circle") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {
                    LegendRow(
                        badge: SymbolBadge(systemName: "checkmark.circle.fill", color: .green),
                        label: "Completed",
                        description: "Tap the circle on the right to mark a reminder as done. A filled green checkmark means it is complete."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: SymbolBadge(systemName: "circle", color: .gray.opacity(0.5)),
                        label: "Incomplete · On time",
                        description: "An empty gray circle means the reminder is not yet done and is not overdue."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: SymbolBadge(systemName: "circle", color: .red),
                        label: "Incomplete · Overdue",
                        description: "An empty red circle means the reminder is not done and its due date has passed."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: SymbolBadge(systemName: "repeat", color: .secondary),
                        label: "Repeating reminder",
                        description: "This reminder recurs on a schedule."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: SymbolBadge(systemName: "stop.circle", color: .secondary),
                        label: "Recurrence ends",
                        description: "This repeating reminder has a defined end date."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: SymbolBadge(systemName: "chevron.right", color: .gray.opacity(0.5)),
                        label: "Tap for details",
                        description: "A chevron on an event row means tapping opens the full event detail sheet."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: SymbolBadge(systemName: "exclamationmark.2", color: .red),
                        label: "Accessibility: overdue & repeating",
                        description: "When \"Differentiate without color\" is enabled, a double exclamation mark appears for overdue reminders that also repeat."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: SymbolBadge(systemName: "xmark.circle", color: .red),
                        label: "Accessibility: event ended",
                        description: "When \"Differentiate without color\" is enabled, an X-circle icon replaces the colored bullet to indicate a past event."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: SymbolBadge(systemName: "checkmark.circle", color: .green),
                        label: "Accessibility: event upcoming",
                        description: "When \"Differentiate without color\" is enabled, a checkmark-circle replaces the colored bullet for an upcoming event."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.primary, lineWidth: 2)
                            .frame(width: 50, height: 50),
                        label: "Accessibility: today",
                        description: "When \"Differentiate without color\" is enabled, today's event badge gains a solid border outline in addition to its raspberry fill."
                    )
                }
            }
        }
    }

    private var opacitySection: some View {
        LegendSection(title: "Row Opacity", systemImage: "circle.lefthalf.filled") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {
                    LegendRow(
                        badge: OpacityBadge(opacity: 1.0),
                        label: "Active",
                        description: "Full opacity — the event or reminder is current or upcoming."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: OpacityBadge(opacity: 0.6),
                        label: "Passed / Completed",
                        description: "Rows dim to 60% once an event has started or a reminder is marked complete, keeping the list scannable without removing context."
                    )
                }
            }
        }
    }

    private var reminderSwipeActionsSection: some View {
        LegendSection(title: "Swipe Actions", systemImage: "hand.point.right") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {
                    LegendRow(
                        badge: SymbolBadge(systemName: "checkmark.circle.fill", color: .green),
                        label: "Swipe right to complete",
                        description: "Swipe an active reminder row to the right to mark it as completed."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: SymbolBadge(systemName: "arrow.uturn.left.circle.fill", color: .blue),
                        label: "Swipe left to undo",
                        description: "Swipe a completed reminder row to the left to mark it as not done."
                    )
                }
            }
        }
    }

    private var eventSwipeActionsSection: some View {
        LegendSection(title: "Event Swipe Actions", systemImage: "hand.point.right") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {
                    LegendRow(
                        badge: SymbolBadge(systemName: "xmark.circle.fill", color: .red),
                        label: "Swipe right to hide past event",
                        description: "Swipe a past event row to the right to hide it from the calendar view."
                    )
                    LegendDivider()
                    LegendRow(
                        badge: SymbolBadge(systemName: "arrow.uturn.left.circle.fill", color: .blue),
                        label: "Swipe left to undo",
                        description: "Swipe a hidden past event row to the left to make it visible again."
                    )
                }
            }
        }
    }

    private var calendarItemContextMenuSection: some View {
        LegendSection(title: "Quick Actions Menu", systemImage: "ellipsis.circle") {
            LegendCard {
                VStack(alignment: .leading, spacing: 16) {
                    LegendRow(
                        badge: SymbolBadge(systemName: "hand.tap.fill", color: .purple),
                        label: "Tap and hold an item",
                        description: "Press and hold a reminder or event to open the quick actions menu."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: SymbolBadge(systemName: "list.bullet.rectangle", color: .blue),
                        label: "Quick actions",
                        description: "The menu provides shortcuts such as viewing details, marking reminders as complete, opening the item in Calendar or Reminders, or deleting it."
                    )

                    LegendDivider()

                    LegendRow(
                        badge: SymbolBadge(systemName: "eye.fill", color: .green),
                        label: "Preview information",
                        description: "A preview of the reminder or event appears above the menu so you can quickly check details without opening the full screen."
                    )
                }
            }
        }
    }
}

private struct LegendSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}

private struct LegendCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
    }
}

private struct LegendRow<Badge: View>: View {
    let badge: Badge
    let label: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            badge
                .frame(width: 50, height: 50)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label). \(description)")
    }
}

private struct LegendDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 64)
            .accessibilityHidden(true)
    }
}

private struct DateBadgePreview: View {
    let day: String
    let month: String
    let color: Color
    let textColor: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(day)
                .font(.headline.weight(.bold))
            Text(month)
                .font(.caption)
        }
        .frame(width: 50, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
        )
        .foregroundColor(textColor)
    }
}

private struct CalendarIconBadge: View {
    var body: some View {
        Image(systemName: "calendar")
            .font(.headline)
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .foregroundColor(.primary)
    }
}

private struct StatusDotBadge: View {
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(width: 50, height: 50, alignment: .center)
    }
}

private struct SymbolBadge: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.title)
            .foregroundStyle(color)
            .frame(width: 50, height: 50)
    }
}

private struct OpacityBadge: View {
    let opacity: Double

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.CustomColors.mutedRaspberry)
                .frame(width: 8, height: 32)
            VStack(alignment: .leading, spacing: 3) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.label))
                    .frame(width: 28, height: 8)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.secondaryLabel))
                    .frame(width: 20, height: 6)
            }
        }
        .opacity(opacity)
        .frame(width: 50, height: 50)
    }
}

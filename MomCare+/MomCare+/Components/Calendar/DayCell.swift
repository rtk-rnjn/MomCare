import SwiftUI

struct DayCell: View {

    // MARK: Internal

    let date: Date
    @Binding var selectedDate: Date

    var showWeekday: Bool

    var body: some View {
        VStack(spacing: showWeekday ? 6 : 2) {
            if showWeekday {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondary)
            }

            Text(date.formatted(.dateTime.day()))
                .font(.body.weight(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : (isToday ? Color.CustomColors.mutedRaspberry : .primary))
                .frame(width: 36, height: 36)
                .background(Circle().fill(isSelected ? Color.CustomColors.mutedRaspberry : Color.clear))

        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDateLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Selects this date")
        .onTapGesture {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                selectedDate = date
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var accessibilityDateLabel: String {
        var label = date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
        if isSelected { label += ", selected" }
        if isToday { label += ", today" }
        return label
    }

    private var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

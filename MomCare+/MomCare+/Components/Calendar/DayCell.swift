import SwiftUI

struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    var showWeekday: Bool = true

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: showWeekday ? 6 : 2) {
                if showWeekday {
                    Text(date.formatted(.dateTime.weekday(.short)))
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.secondary)
                }

                Text(date.formatted(.dateTime.day()))
                    .font(.body.weight(isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : (isToday ? Color.CustomColors.mutedRaspberry : .primary))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.CustomColors.mutedRaspberry : Color.clear)
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

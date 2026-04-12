import Foundation

struct WaterLogEntry: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let milliliters: Double

    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var formattedAmount: String {
        if milliliters >= 1000 {
            Measurement(value: milliliters / 1000, unit: UnitVolume.liters)
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        numberFormatStyle: .number.precision(.fractionLength(1))
                    )
                )
        } else {
            Measurement(value: milliliters, unit: UnitVolume.milliliters)
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        numberFormatStyle: .number.precision(.fractionLength(0))
                    )
                )
        }
    }
}

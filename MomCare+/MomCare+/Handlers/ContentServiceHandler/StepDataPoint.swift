import Foundation

struct StepDataPoint: Identifiable {
    let id: UUID = .init()
    let date: Date
    let steps: Int

    var shortLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE"
        return fmt.string(from: date)
    }
}

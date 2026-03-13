import SwiftUI
import EventKit

struct TimelineItem: Identifiable, Sendable {
    var id: UUID = .init()
	var title: String
	var startDate: Date
	var endDate: Date
	var isAllDay: Bool = false
	var color: Color

	var location: String?
	var isPrimary: Bool
}

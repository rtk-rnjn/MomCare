import SwiftUI

enum TimelineTransitionID: Hashable {
	case background
	case custom(String)
}

struct TimelineTransitionModifier: ViewModifier {

	// MARK: Lifecycle

	init(id: TimelineTransitionID = .background, in namespace: Namespace.ID) {
		self.id = id
		self.namespace = namespace
	}

    // MARK: Internal

    let id: TimelineTransitionID
	let namespace: Namespace.ID

    func body(content: Content) -> some View {
		content
			.matchedGeometryEffect(id: id, in: namespace)
	}
}

extension View {
	func timelineTransition(
		id: TimelineTransitionID = .background,
		in namespace: Namespace.ID
	) -> some View {
		modifier(TimelineTransitionModifier(id: id, in: namespace))
	}
}

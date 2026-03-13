import SwiftUI

struct AccessRestrictedModifier<Overlay: View>: ViewModifier {

	// MARK: Lifecycle

	init(
		isRestricted: Bool,
		blurRadius: CGFloat = 3,
		@ViewBuilder overlay: @escaping () -> Overlay
	) {
		self.isRestricted = isRestricted
		self.blurRadius = blurRadius
		self.overlay = overlay
	}

	// MARK: Internal

	let isRestricted: Bool
	let blurRadius: CGFloat
	let overlay: () -> Overlay

	func body(content: Content) -> some View {
		ZStack {
			content
				.blur(radius: isRestricted ? blurRadius : 0)
				.drawingGroup(opaque: false)

			if isRestricted {
				overlay()
			}
		}
	}
}

extension View {
	func accessRestricted<Overlay: View>(
		_ isRestricted: Bool,
		blurRadius: CGFloat = 3,
		@ViewBuilder overlay: @escaping () -> Overlay
	) -> some View {
		modifier(
			AccessRestrictedModifier(
				isRestricted: isRestricted,
				blurRadius: blurRadius,
				overlay: overlay
			)
		)
	}
}

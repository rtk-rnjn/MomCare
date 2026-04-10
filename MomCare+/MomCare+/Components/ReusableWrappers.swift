import SwiftUI
import UIKit

struct InfoRowDate: View {
    // MARK: Internal

    let title: LocalizedStringKey
    let date: Date
    let isEditing: Bool
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)

            Spacer()

            Text(formatted)
                .foregroundStyle(isEditing ? Color("primaryAppColor") : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEditing else {
                return
            }

            onTap()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            Text(title) + Text(", ") + Text(formatted)
        )
        .accessibilityAddTraits(isEditing ? .isButton : [])
        .accessibilityHint(isEditing ? "Activates date picker" : "")
    }

    // MARK: Private

    private var formatted: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

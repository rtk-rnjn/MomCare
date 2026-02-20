

import SwiftUI
import UIKit

struct ProfileTableViewWrapper: UIViewControllerRepresentable {
    var authenticationService: AuthenticationService

    func makeUIViewController(context _: Context) -> UINavigationController {
        let profileVC = ProfileTableView()
        profileVC.authenticationService = authenticationService
        let nav = UINavigationController(rootViewController: profileVC)
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}
}

struct InfoRow: View {
    let title: String
    let value: String
    let isEditing: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .foregroundColor(isEditing ? Color("primaryAppColor") : .secondary)
        }
    }
}

struct InfoRowDate: View {

    // MARK: Internal

    let title: String
    let date: Date
    let isEditing: Bool
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)

            Spacer()

            Text(formatted)
                .foregroundColor(isEditing ? Color("primaryAppColor") : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEditing else { return }
            onTap()
        }
    }

    // MARK: Private

    private var formatted: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

}

struct ProfileEditableTextRow: View {
    let title: String
    @Binding var text: String

    let isEditing: Bool
    let displayText: String?

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)

            Spacer()

            if isEditing {
                TextField("Enter", text: $text)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(MomCareAccent.primary)
            } else {
                Text(displayText ?? "Not Set")
                    .foregroundColor(.secondary)
            }
        }
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

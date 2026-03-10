import SwiftUI
import UIKit

struct ProfileTableViewWrapper: UIViewControllerRepresentable {
    var authenticationService: AuthenticationService
    var controlState: ControlState

    func makeUIViewController(context _: Context) -> UINavigationController {
        let profileViewController = ProfileTableView()
        profileViewController.authenticationService = authenticationService
        profileViewController.controlState = controlState

        let navigationController = UINavigationController(rootViewController: profileViewController)
        navigationController.navigationBar.prefersLargeTitles = false
        return navigationController
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
    let displayText: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)

            Spacer()

            TextField(displayText, text: $text)
                .multilineTextAlignment(.trailing)
                .foregroundColor(isEditing ? MomCareAccent.primary : .secondary)
                .disabled(!isEditing)
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

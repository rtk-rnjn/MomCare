import SwiftUI
import UIKit

struct NavBarProfileAccessory: UIViewControllerRepresentable {

    // MARK: Internal

    let action: () -> Void

    func makeUIViewController(context _: Context) -> UIViewController {
        Controller(action: action)
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}

    // MARK: Private

    private final class Controller: UIViewController {

        // MARK: Lifecycle

        init(action: @escaping () -> Void) {
            self.action = action
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        // MARK: Internal

        let action: () -> Void

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            guard let navBar = navigationController?.navigationBar else { return }

            let isLarge = navBar.bounds.height > 60

            let yOffset: CGFloat = isLarge ? 22 : -7
            button.transform = CGAffineTransform(translationX: 0, y: yOffset)
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            attachButtonIfNeeded()
        }

        // MARK: Private

        private let button: UIButton = .init(type: .system)

        private func attachButtonIfNeeded() {
            guard
                let navBar = navigationController?.navigationBar,
                button.superview == nil
            else { return }

            let image = UIImage(
                systemName: "person.crop.circle.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            )
            button.setImage(image, for: .normal)

            button.tintColor = UIColor(named: "primaryAppColor")
            button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            navBar.addSubview(button)

            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -16),
                button.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
                button.widthAnchor.constraint(equalToConstant: 40),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])
        }

        @objc private func tapped() {
            action()
        }
    }
}

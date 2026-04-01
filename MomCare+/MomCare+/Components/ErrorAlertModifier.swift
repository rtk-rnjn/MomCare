import SwiftUI

struct ErrorAlertModifier<ActionView: View>: ViewModifier {
    // MARK: Internal

    @Binding var error: (any Error)?

    let actions: (any Error) -> ActionView

    func body(content: Content) -> some View {
        content
            .alert(
                alertTitle,
                isPresented: isPresented,
                presenting: error
            ) { error in
                actions(error)
            } message: { error in
                Text(alertMessage(for: error))
            }
    }

    // MARK: Private

    private var isPresented: Binding<Bool> {
        Binding(
            get: { error != nil },
            set: { newValue in
                if newValue == false {
                    error = nil
                }
            }
        )
    }

    private var alertTitle: String {
        if let localized = error as? (any LocalizedError),
           let description = localized.errorDescription {
            return description
        }
        return error?.localizedDescription ?? "Error"
    }

    private func alertMessage(for error: any Error) -> String {
        if let localized = error as? (any LocalizedError) {
            let parts = [
                localized.failureReason,
                localized.recoverySuggestion
            ]
            .compactMap { $0 }
            .joined(separator: "\n\n")

            return parts.isEmpty ? error.localizedDescription : parts
        }

        return error.localizedDescription
    }
}

extension View {
    func errorAlert(error: Binding<(any Error)?>) -> some View {
        modifier(
            ErrorAlertModifier(error: error) { _ in
                Button(role: .close) {
                    error.wrappedValue = nil
                }
            }
        )
    }

    func errorAlert<Actions: View>(error: Binding<(any Error)?>, @ViewBuilder actions: @escaping (any Error) -> Actions) -> some View {
        modifier(ErrorAlertModifier(error: error, actions: actions))
    }
}

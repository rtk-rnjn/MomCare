import SwiftUI

struct ErrorAlertModifier: ViewModifier {

    @Binding var error: (any Error)?

    func body(content: Content) -> some View {
        content
        .alert(
            "Error",
            isPresented: Binding(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            ),
            presenting: error
        ) { _ in
            Button(role: .close) {
                error = nil
            }
        } message: { error in
            VStack(alignment: .leading, spacing: 6) {

                if let error = error as? (any LocalizedError) {
                    if let reason = error.failureReason {
                        Text(reason)
                    }

                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

extension View {

    func errorAlert(error: Binding<(any Error)?>) -> some View {
        modifier(ErrorAlertModifier(error: error))
    }
}

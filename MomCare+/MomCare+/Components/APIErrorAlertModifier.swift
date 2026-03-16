import SwiftUI

struct APIErrorAlertModifier: ViewModifier {

    @Binding var error: (any APIError)?

    func body(content: Content) -> some View {
        content
        .alert(
            error?.errorDescription ?? "Error",
            isPresented: Binding(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            ),
            presenting: error
        ) { _ in
            Button("OK", role: .cancel) {
                error = nil
            }
        } message: { error in
            VStack(alignment: .leading, spacing: 6) {

                if let reason = error.failureReason {
                    Text(reason)
                }

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
//                        .font(.footnote)
//                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

extension View {

    func apiErrorAlert(error: Binding<(any APIError)?>) -> some View {
        modifier(APIErrorAlertModifier(error: error))
    }
}

import SwiftUI

struct DebugRow: View {
    let label: String
    let value: String
    var valueColor: Color = .secondary

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }
}

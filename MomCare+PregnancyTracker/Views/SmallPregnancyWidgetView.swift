import SwiftUI
import WidgetKit

struct SmallPregnancyWidgetView: View {
    let entry: TriTrackEntry

    var body: some View {
        VStack(spacing: 6) {
            Text("Week \(entry.week)")
                .font(.title2)
                .fontWeight(.bold)

            Text("Day \(entry.day)")
                .font(.headline)

            Text("Trimester: \(entry.trimester)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

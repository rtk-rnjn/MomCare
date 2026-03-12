import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: TriTrackEntry

    var body: some View {
        if entry.isValid {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Week \(entry.week)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Day \(entry.day)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 8)

                Text(entry.fruitComparison.isEmpty ? "" : "Size of a \(entry.fruitComparison)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer(minLength: 6)

                Text("Trimester \(entry.trimester)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 139 / 255, green: 69 / 255, blue: 87 / 255))
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "heart.circle")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("Open MomCare\nto get started")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {

    // MARK: Internal

    let entry: TriTrackEntry

    var body: some View {
        if entry.isValid {
            VStack(alignment: .leading, spacing: 0) {
                headerSection

                Divider()
                    .padding(.vertical, 12)

                babySection

                if hasMeasurements {
                    Divider()
                        .padding(.vertical, 12)

                    measurementsSection
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "heart.circle")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)

                Text("Open MomCare to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: Private

    private var hasMeasurements: Bool {
        let hasHeight = (entry.babyHeightCm ?? 0) > 0
        let hasWeight = (entry.babyWeightG ?? 0) > 0
        return hasHeight || hasWeight
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Week \(entry.week), Day \(entry.day)")
                .font(.title2)
                .fontWeight(.bold)

            Text("Trimester \(entry.trimester)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 139 / 255, green: 69 / 255, blue: 87 / 255))
        }
    }

    private var babySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Baby this week")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            if !entry.fruitComparison.isEmpty {
                HStack(alignment: .center, spacing: 12) {
                    fruitImage
                        .frame(width: 44, height: 44)

                    Text("Size of a \(entry.fruitComparison)")
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }
            } else {
                Text("Data unavailable")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var measurementsSection: some View {
        HStack(spacing: 28) {
            if let heightCm = entry.babyHeightCm, heightCm > 0 {
                measurementItem(
                    label: "HEIGHT",
                    value: unsafe String(format: "%.1f cm", heightCm)
                )
            }

            if let weightG = entry.babyWeightG, weightG > 0 {
                measurementItem(
                    label: "WEIGHT",
                    value: weightG >= 1000
                        ? unsafe String(format: "%.2f kg", weightG / 1000)
                        : unsafe String(format: "%.0f g", weightG)
                )
            }
        }
    }

    @ViewBuilder
    private var fruitImage: some View {
        if let imageURL = entry.fruitImageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFit()

                case .empty, .failure:
                    Image(systemName: "leaf.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.green)

                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: "leaf.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.green)
        }
    }

    private func measurementItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
    }

}

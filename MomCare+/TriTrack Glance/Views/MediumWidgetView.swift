import SwiftUI
import WidgetKit

struct MediumWidgetView: View {

    // MARK: Internal

    let entry: TriTrackEntry

    var body: some View {
        if entry.isValid {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Week \(entry.week)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Day \(entry.day)")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Spacer(minLength: 4)

                    Text("Trimester \(entry.trimester)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 139 / 255, green: 69 / 255, blue: 87 / 255))
                }
                .frame(maxHeight: .infinity, alignment: .leading)
                .padding(.trailing, 12)

                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Baby this week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    if !entry.fruitComparison.isEmpty {
                        HStack(alignment: .center, spacing: 8) {
                            fruitImage
                                .frame(width: 32, height: 32)

                            Text("Size of a \(entry.fruitComparison)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } else {
                        Text("Data unavailable")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            HStack(spacing: 12) {
                Image(systemName: "heart.circle")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("Open MomCare to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: Private

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
}

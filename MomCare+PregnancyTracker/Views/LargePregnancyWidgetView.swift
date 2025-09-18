import SwiftUI

struct LargePregnancyWidgetView: View {
    let entry: TriTrackEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Week \(entry.week), Day \(entry.day)")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Trimester: \(entry.trimester)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Next Reminder")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let reminder = entry.nextReminder {
                    Text(reminder.title ?? "No title")
                        .font(.body)
                        .fontWeight(.medium)
                } else {
                    Text("No upcoming reminders")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Baby this week")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let fruitName = entry.babyFruitName, !fruitName.isEmpty {
                    HStack(spacing: 8) {
                        if let imageURL = entry.babyFruitImageURL, !imageURL.isEmpty,
                           let url = URL(string: imageURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 40, height: 40)

                                case let .success(image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                case .failure:
                                    Image(systemName: "photo")
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.secondary)

                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        Text("Size of a \(fruitName)")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                } else {
                    Text("Baby size unavailable")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

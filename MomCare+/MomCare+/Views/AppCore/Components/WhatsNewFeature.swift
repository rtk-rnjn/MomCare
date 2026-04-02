import SwiftUI

struct WhatsNewFeature: Identifiable {
    let id: UUID = .init()
    let icon: String
    let iconColor: Color
    let iconBackgroundColor: Color
    let title: String
    let description: String
}

struct WhatsNewConfiguration {
    let appVersion: String
    let headline: String
    let subheadline: String
    let features: [WhatsNewFeature]
    let continueButtonTitle: String
    let footnote: String?
}

struct WhatsNewView: View {
    // MARK: Internal

    let configuration: WhatsNewConfiguration = .v1_0_1

    var body: some View {
        featureList
        .navigationTitle("\(configuration.headline) \(configuration.appVersion)")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: Private

    private var featureList: some View {
        List {
            Section {
                ForEach(Array(configuration.features.enumerated()), id: \.element.id) { _, feature in
                    FeatureRow(feature: feature)
                }
            } header: {
                Text(configuration.subheadline)
            }
        }
    }
}

struct FeatureRow: View {
    let feature: WhatsNewFeature

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(feature.iconBackgroundColor)
                    .frame(width: 56, height: 56)

                Image(systemName: feature.icon)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(feature.iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

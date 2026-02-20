import SwiftUI

struct BaseInfoSheetLayout<HeaderIcon: View>: View {
    let title: String
    let subtitle: String
    let description: String
    let duration: String
    let intensity: String
    let target: String
    let tags: [String]
    let pastelColor: Color
    let accentColor: Color
    let onClose: () -> Void

    @ViewBuilder var headerIcon: HeaderIcon

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    aboutSection
                    statsSection
                    benefitsSection
                }
                .padding(20)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private extension BaseInfoSheetLayout {
    var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(pastelColor)
                    .frame(width: 60, height: 60)

                headerIcon
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(pastelColor)
                    )
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Circle().fill(Color(.systemGray6)))
            }
        }
        .padding(20)
    }

    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.subheadline.weight(.semibold))

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(icon: "clock", value: duration, accentColor: accentColor)
            StatItem(icon: "flame", value: intensity, accentColor: accentColor)
            StatItem(icon: "target", value: target, accentColor: accentColor)
        }
    }

    var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Benefits")
                .font(.subheadline.weight(.semibold))

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 8),
                          GridItem(.flexible(), spacing: 8)],
                spacing: 8
            ) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption.weight(.medium))
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(pastelColor)
                        )
                }
            }
        }
    }
}

struct ExerciseInfoSheet: View {

    // MARK: Internal

    let userExerciseModel: UserExerciseModel?

    @Binding var isPresented: Bool

    var body: some View {
        BaseInfoSheetLayout(
            title: exercise?.name ?? "Exercise",
            subtitle: exercise?.level.rawValue ?? "-",
            description: exercise?.description ?? "No description available.",
            duration: exercise?.humanReadableDuration ?? "",
            intensity: "Low",
            target: exercise?.targetedBodyParts.joined(separator: ", ") ?? "",
            tags: exercise?.tags ?? [],
            pastelColor: pastelColor,
            accentColor: accentColor,
            onClose: { isPresented = false }
        ) {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 24))
                    .foregroundColor(accentColor)
            }
        }
        .task {
            exercise = await userExerciseModel?.exerciseModel
            uiImage = await exercise?.image
        }
    }

    // MARK: Private

    @State private var exercise: ExerciseModel?
    @State private var uiImage: UIImage?

    private let pastelColor: Color = .init(hex: "F0D5C8")
    private let accentColor: Color = .init(hex: "9B6B52")

}

struct BreathingInfoSheet: View {

    // MARK: Internal

    @Binding var isPresented: Bool

    var body: some View {
        BaseInfoSheetLayout(
            title: "Breathing",
            subtitle: "Beginner",
            description: description,
            duration: "10 min",
            intensity: "Low",
            target: "Lungs",
            tags: tags,
            pastelColor: pastelColor,
            accentColor: accentColor,
            onClose: { isPresented = false }
        ) {
            Image(systemName: "lungs.fill")
                .font(.system(size: 24))
                .foregroundColor(accentColor)
        }
    }

    // MARK: Private

    private let description =
        "Deep breathing exercises help reduce stress and anxiety during pregnancy. This gentle practice improves oxygen flow to both you and your baby while promoting relaxation and better sleep quality."

    private let tags = [
        "Stress Relief",
        "Better Sleep",
        "Oxygen Flow",
        "Relaxation"
    ]

    private let pastelColor: Color = .init(hex: "D0E1F0")
    private let accentColor: Color = .init(hex: "4A7A9B")

}

private struct StatItem: View {
    let icon: String
    let value: String
    var accentColor: Color = .secondary

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(accentColor)

            Text(value)
                .font(.caption2.weight(.medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

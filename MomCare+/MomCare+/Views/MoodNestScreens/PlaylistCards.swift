import SwiftUI
import UIKit

struct PlaylistCard: View {
    // MARK: Internal

    let playlist: PlaylistModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: max(0, UIScreen.current.bounds.width / 2 - 28), height: 130)
                    .clipped()
            } else {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .scaledToFill()
                    .frame(width: max(0, UIScreen.current.bounds.width / 2 - 28), height: 130)
                    .clipped()
            }

            if reduceTransparency {
                Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .frame(height: 40)
            } else {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.8),
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            }

            Text(playlist.name)
                .font(.callout.weight(.bold))
                .foregroundStyle(.white)
                .padding(12)
                .lineLimit(2)
        }
        .frame(height: 130)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(playlist.name)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(String(localized: "a11y_open_playlist_hint"))
        .task {
            uiImage = await playlist.image
        }
    }

    // MARK: Private

    @State private var uiImage: UIImage?
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
}



import SwiftUI
import UIKit

struct PlaylistHeroCard: View {

    // MARK: Internal

    let playlist: PlaylistModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.1),
                    Color.clear,
                ],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .task {
            uiImage = await playlist.image
        }
    }

    // MARK: Private

    @State private var uiImage: UIImage?

}

struct PlaylistCard: View {

    // MARK: Internal

    let playlist: PlaylistModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: max(0, UIScreen.main.bounds.width / 2 - 28), height: 130)
                    .clipped()
            } else {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .scaledToFill()
                    .frame(width: max(0, UIScreen.main.bounds.width / 2 - 28), height: 130)
                    .clipped()
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.1),
                    Color.clear,
                ],
                startPoint: .bottom,
                endPoint: .top
            )

            Text(playlist.name)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(12)
                .lineLimit(2)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
        }
        .frame(height: 130)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .task {
            uiImage = await playlist.image
        }
    }

    // MARK: Private

    @State private var uiImage: UIImage?

}

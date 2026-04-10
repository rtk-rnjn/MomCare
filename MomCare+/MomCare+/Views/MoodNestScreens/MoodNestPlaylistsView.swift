import SwiftUI
import TipKit
import UIKit

struct MoodNestPlaylistsView: View {
    // MARK: Internal

    let mood: MoodType

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: reduceTransparency
                        ? [MomCareAccent.secondary, MomCareAccent.secondary]
                        : [
                            MomCareAccent.secondary.opacity(1.0),
                            MomCareAccent.secondary.opacity(1.0),
                            MomCareAccent.secondary.opacity(0.9),
                            MomCareAccent.secondary.opacity(0.7),
                            MomCareAccent.secondary.opacity(0.5),
                            MomCareAccent.secondary.opacity(0.3),
                            Color.clear
                        ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(maxHeight: 350)
                .ignoresSafeArea(edges: .top)
                .accessibilityHidden(true)

                Spacer()
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    captionSection
                    heroSection
                    featuredSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(AppTab.mood.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                try await contentService.fetchMoodNestData(for: mood)
            } catch {
                controlState.error = error
            }

            if #available(iOS 18.0, *) {
                try? await contentService.logMoodToHealthKit(mood: mood)
            }

            if let heroPlaylist = contentService.playlists.randomElement() {
                self.heroPlaylist = heroPlaylist
                uiImage = await heroPlaylist.image
            }
        }
    }

    var captionSection: some View {
        Text(contentService.moodNestCaption)
            .font(.title.weight(.bold))
            .foregroundStyle(.primary)
            .lineLimit(3)
            .minimumScaleFactor(0.8)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }

    var heroSection: some View {
        Group {
            if let heroPlaylist {
                heroSection(for: heroPlaylist)
            }
        }
    }

    var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("More Playlists")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(contentService.playlists) { playlist in
                    NavigationLink(destination: MoodNestSongsView(playlist: playlist)) {
                        PlaylistCard(playlist: playlist)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(playlist.name)
                    .accessibilityHint("Opens \(playlist.name) playlist")
                }
            }
        }
    }

    func heroSection(for hero: PlaylistModel) -> some View {
        NavigationLink(destination: MoodNestSongsView(playlist: hero)) {
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    if let uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
                            .clipped()
                            .accessibilityHidden(true)
                    } else {
                        Image(systemName: "music.quarternote.3")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
                            .clipped()
                            .accessibilityHidden(true)
                    }

                    LinearGradient(
                        colors: reduceTransparency
                            ? [Color.black.opacity(0.9), Color.black.opacity(0.6)]
                            : [
                                Color.black.opacity(0.8),
                                Color.black.opacity(0.4),
                                Color.black.opacity(0.1),
                                Color.clear
                            ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 16) {
                        Text(hero.name)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                        Button {
                            musicPlayerHandler.preparePlaylistAndPlay(hero)
                            controlState.showingPopupBar = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.caption.weight(.bold))
                                    .accessibilityHidden(true)
                                Text("Play Now")
                                    .font(.body.weight(.bold))
                            }
                            .foregroundStyle(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .accessibilityLabel("Play \(hero.name)")
                        .accessibilityHint("Starts playing this playlist")
                        .accessibilityIdentifier("playNowButton")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
            }
            .aspectRatio(5 / 3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.outer, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.outer, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(hero.name)
        .accessibilityHint("Opens \(hero.name) playlist")
    }

    // MARK: Private

    @EnvironmentObject private var musicPlayerHandler: MusicPlayerHandler
    @EnvironmentObject private var contentService: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @State private var heroPlaylist: PlaylistModel?
    @State private var uiImage: UIImage?
}

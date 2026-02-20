import SwiftUI
import UIKit

struct MoodResultView: View {

    // MARK: Lifecycle

    init(mood: MoodType) {
        _vm = StateObject(wrappedValue: MoodResultViewModel(mood: mood))
    }

    // MARK: Internal

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [
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
                .frame(height: 350)
                .ignoresSafeArea(edges: .top)

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
        .navigationTitle("MoodNest")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.loadData()

            let heroPlaylist = vm.playlists.randomElement()
            if let heroPlaylist {
                self.heroPlaylist = heroPlaylist
                uiImage = await heroPlaylist.image
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var musicPlayerHandler: MusicPlayerHandler
    @StateObject private var vm: MoodResultViewModel
    @State private var heroPlaylist: PlaylistModel?
    @State private var uiImage: UIImage?
}

private extension MoodResultView {
    var captionSection: some View {
        Text(vm.caption)
            .font(.title.bold())
            .foregroundColor(.primary)
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension MoodResultView {
    var heroSection: some View {
        Group {
            if let heroPlaylist {
                heroSection(for: heroPlaylist)
            }
        }
    }

    func heroSection(for hero: PlaylistModel) -> some View {
        NavigationLink(destination: PlaylistDetailView(playlist: hero)) {
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
                        colors: [
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
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                        Button {
                            musicPlayerHandler.preparePlaylistAndPlay(hero)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .accessibilityHidden(true)
                                Text("Play Now")
                                    .font(.body.bold())
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .accessibilityLabel("Play \(hero.name)")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
            }
            .aspectRatio(5 / 3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Featured playlist: \(hero.name)")
        .accessibilityHint("Tap to view playlist")
    }
}

private extension MoodResultView {
    var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("More Playlists")
                .font(.title3.bold())
                .foregroundColor(.primary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(vm.playlists) { playlist in
                    NavigationLink(destination: PlaylistDetailView(playlist: playlist)) {
                        PlaylistCard(playlist: playlist)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(playlist.name)
                    .accessibilityHint("Tap to view playlist")
                }
            }
        }
    }
}

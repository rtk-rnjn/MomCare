
import AVFoundation
import LNPopupUI
import SwiftUI
import UIKit

struct PlaylistDetailView: View {

    // MARK: Lifecycle

    init(playlist: PlaylistModel) {
        self.playlist = playlist
    }

    // MARK: Internal

    @State var playlist: PlaylistModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 12)
                .padding(.horizontal, 16)

            Spacer()
                .frame(height: 16)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    controlsSection
                        .padding(.top, 20)
                        .padding(.bottom, 16)

                    ForEach(songs) { track in
                        PlaylistTrackRow(songModel: track)
                            .padding(.horizontal, 20)

                        Divider()
                            .padding(.leading, 80)
                    }
                    .animation(animation, value: songs)

                    Spacer()
                        .frame(height: 100)
                }
            }
            .frame(maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .ignoresSafeArea(edges: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 80)
                    .ignoresSafeArea()
            }
        }
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            uiImage = await playlist.image
        }
    }

    // MARK: Private

    @EnvironmentObject private var musicKitHandler: MusicPlayerHandler

    @State private var uiImage: UIImage?

    private var animation: Animation = .easeIn(duration: 0.25)

    private var songs: [SongModel] {
        playlist.songs
    }

}

private extension PlaylistDetailView {
    var accentColor: Color {
        Color(red: 139 / 255, green: 69 / 255, blue: 87 / 255)
    }

    var headerSection: some View {
        HStack(spacing: 18) {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
            } else {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(playlist.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                Text("\(songs.count) songs • \(totalDuration)")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.85))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }

            Spacer()
        }
        .padding(20)
    }

    private var totalDuration: String {
        let total = songs.reduce(0) { $0 + ($1.metadata?.duration ?? 0) }
        let minutes = Int(total) / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remaining = minutes % 60
            return "\(hours) hr \(remaining) min"
        }
        return "\(minutes) min"
    }
}

private extension PlaylistDetailView {
    var controlsSection: some View {
        HStack(spacing: 12) {
            playButton
            shuffleButton
        }
        .padding(.horizontal, 24)
    }

    var playButton: some View {
        Button {
            musicKitHandler.preparePlaylistAndPlay(playlist)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text("Play")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.black)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }

    var shuffleButton: some View {
        Button {
            playlist.songs.shuffle()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "shuffle")
                    .font(.system(size: 15, weight: .semibold))
                Text("Shuffle")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct PlaylistTrackRow: View {

    // MARK: Internal

    var accentColor: Color = .init(red: 139 / 255, green: 69 / 255, blue: 87 / 255)
    let songModel: SongModel

    var body: some View {
        Button {
            musicKitHandler.preparePlaylistAndPlay(nil, song: songModel)
        } label: {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: songModel.songImageUri!)!)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
                    .overlay(
                        Group {
                            if musicKitHandler.currentSong == songModel {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(accentColor.opacity(0.3))
                                    .overlay(nowPlayingIndicator)
                            }
                        }
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(songModel.songName)
                        .font(.system(size: 16, weight: musicKitHandler.currentSong == songModel ? .bold : .regular))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)

                    Text(songModel.metadata?.author ?? "Unknown Artist")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                Text(Utils.formattedTime(songModel.metadata?.duration ?? 0))
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .monospacedDigit()

                Button {} label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white.opacity(0.6))
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .task {
            url = await songModel.url
            uiImage = await songModel.image
        }
    }

    // MARK: Private

    @EnvironmentObject private var musicKitHandler: MusicPlayerHandler

    @State private var url: URL? = nil
    @State private var uiImage: UIImage? = nil

    @ViewBuilder
    private var nowPlayingIndicator: some View {
        if #available(iOS 17.0, *) {
            Image(systemName: musicKitHandler.isPlaying ? "waveform" : "pause.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .symbolEffect(
                    .variableColor.iterative,
                    options: .repeating,
                    isActive: musicKitHandler.isPlaying
                )
        } else {
            Image(systemName: musicKitHandler.isPlaying ? "waveform" : "pause.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

import AVFoundation
import AVKit
import LNPopupUI
import MediaPlayer
import SwiftUI
import UIKit

struct MusicPlayerView: View {

    // MARK: Internal

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 30)

            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - 48, height: UIScreen.main.bounds.width - 48)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                    .accessibilityHidden(true)
            }

            Spacer()

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(musicPlayerHandler.currentSong?.metadata?.title ?? "Not Playing")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(musicPlayerHandler.currentSong?.metadata?.author ?? "")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(musicPlayerHandler.currentSong?.metadata?.title ?? "Not Playing") by \(musicPlayerHandler.currentSong?.metadata?.author ?? "Unknown")")

                Spacer()

                Button {} label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.6))
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel("More options")
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)

            VStack(spacing: 6) {
                Slider(value: Binding(
                    get: { musicPlayerHandler.player?.currentTime().seconds ?? 0 },
                    set: { musicPlayerHandler.seek(by: $0) }
                ), in: 0 ... (musicPlayerHandler.totalDuration))
                    .tint(.white.opacity(0.8))
                    .accessibilityLabel("Playback position")

                HStack {
                    Text(Utils.formattedTime(musicPlayerHandler.player?.currentTime().seconds ?? 0))
                    Spacer()
                    Text(Utils.formattedTime(musicPlayerHandler.player?.currentItem?.duration.seconds ?? 0))
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .monospacedDigit()
                .accessibilityHidden(true)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)

            HStack(spacing: 50) {
                Button {
                    musicPlayerHandler.skipToNext()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Previous track")

                Button {
                    _ = musicPlayerHandler.togglePlayPause()
                    controlState.showingPopupBar = true
                } label: {
                    Image(systemName: musicPlayerHandler.player?.timeControlStatus == .playing ? "pause.fill" : "play.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                }
                .accessibilityLabel(musicPlayerHandler.player?.timeControlStatus == .playing ? "Pause" : "Play")

                Button {
                    musicPlayerHandler.skipToPrevious()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Next track")
            }
            .animation(nil, value: musicPlayerHandler.player?.timeControlStatus == .playing)
            .padding(.bottom, 40)

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .accessibilityHidden(true)

                    SystemVolumeSlider()
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .accessibilityLabel("Volume")

                    HStack(spacing: 12) {
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .accessibilityHidden(true)
                        SystemRoutePicker()
                            .frame(width: 30, height: 30)
                            .accessibilityLabel("Audio output")
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 60)
                    .overlay(Color.black.opacity(0.3))
                    .ignoresSafeArea()
            } else {
                Color.blue
                    .ignoresSafeArea()
            }
        }
        .task {
            if let song = musicPlayerHandler.currentSong {
                uiImage = await song.image
            }
        }
        .popupItems(selection: $musicPlayerHandler.currentSong) {
            for song in musicPlayerHandler.playlist {
                PopupItem(id: song, progress: Float(musicPlayerHandler.player?.currentTime().seconds ?? 0)) {
                    Text(song.metadata?.title ?? "Song Title")
                } subtitle: {
                    Text(song.metadata?.author ?? "Unknown Author")
                } buttons: {
                    ToolbarItemGroup {}
                }
            }
        }
        .popupBarMinimizationEnabled(true)
    }

    // MARK: Private

    @EnvironmentObject private var musicPlayerHandler: MusicPlayerHandler
    @EnvironmentObject private var controlState: ControlState

    @State private var uiImage: UIImage?

    private var accentColor: Color {
        Color(red: 139 / 255, green: 69 / 255, blue: 87 / 255)
    }

}

struct SystemVolumeSlider: UIViewRepresentable {
    func makeUIView(context _: Context) -> MPVolumeView {
        let volumeView = MPVolumeView(frame: .zero)

        volumeView.sizeToFit()
        volumeView.showsVolumeSlider = true
        volumeView.tintColor = .white
        return volumeView
    }

    func updateUIView(_: MPVolumeView, context _: Context) {}
}

struct SystemRoutePicker: UIViewRepresentable {
    func makeUIView(context _: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.tintColor = .white
        picker.activeTintColor = .white
        return picker
    }

    func updateUIView(_: AVRoutePickerView, context _: Context) {}
}

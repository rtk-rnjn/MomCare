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
            Image(uiImage: musicPlayerHandler.currentSongUIImage ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .popupTransitionTarget()
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .accessibilityLabel("\(musicPlayerHandler.currentSong?.metadata?.title ?? "Song") album artwork")

            Spacer()

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(musicPlayerHandler.currentSong?.metadata?.title ?? "Unknown Title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(musicPlayerHandler.currentSong?.metadata?.author ?? "")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }

                Spacer()

                Button {} label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.6))
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel(String(localized: "a11y_song_options_label"))
                .frame(minWidth: 44, minHeight: 44)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)

            VStack(spacing: 6) {
                Slider(value: Binding(
                    get: { musicPlayerHandler.player?.currentTime().seconds ?? 0 },
                    set: { musicPlayerHandler.seek(by: $0) }
                ), in: 0 ... (musicPlayerHandler.totalDuration))
                    .tint(.white.opacity(0.8))
                    .accessibilityLabel(String(localized: "a11y_playback_progress_label"))
                    .accessibilityValue(Utils.formattedTime(musicPlayerHandler.player?.currentTime().seconds ?? 0))
                    .accessibilityHint(String(localized: "a11y_drag_to_seek_hint"))
                    .accessibilityAddTraits(.updatesFrequently)

                HStack {
                    Text(Utils.formattedTime(musicPlayerHandler.player?.currentTime().seconds ?? 0))
                    Spacer()
                    Text(Utils.formattedTime(musicPlayerHandler.player?.currentItem?.duration.seconds ?? 0))
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .monospacedDigit()
                .accessibilityHidden(true)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)

            HStack(spacing: 50) {
                Button {
                    musicPlayerHandler.skipToPrevious()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                }
                .accessibilityLabel(String(localized: "a11y_previous_track_label"))
                .frame(minWidth: 44, minHeight: 44)

                Button {
                    controlState.showingPopupBar = true
                    musicPlayerHandler.togglePlayPause()
                } label: {
                    Image(systemName: musicPlayerHandler.player?.timeControlStatus == .playing ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .animation(
                            reduceMotion ? .linear(duration: 0.05) : .easeInOut,
                            value: musicPlayerHandler.player?.timeControlStatus
                        )
                }
                .accessibilityLabel(musicPlayerHandler.player?.timeControlStatus == .playing ? String(localized: "Pause") : String(localized: "Play"))
                .accessibilityIdentifier("playPauseButton")

                Button {
                    musicPlayerHandler.skipToNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                }
                .accessibilityLabel(String(localized: "a11y_next_track_label"))
                .frame(minWidth: 44, minHeight: 44)
            }
            .animation(nil, value: musicPlayerHandler.player?.timeControlStatus == .playing)
            .padding(.bottom, 40)

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundStyle(.white.opacity(0.7))
                        .accessibilityHidden(true)

                    SystemVolumeSlider()
                        .layoutPriority(1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .accessibilityLabel(String(localized: "a11y_volume_label"))

                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundStyle(.white.opacity(0.7))
                        .accessibilityHidden(true)

                    SystemRoutePicker()
                        .frame(width: 30, height: 30)
                        .accessibilityLabel(String(localized: "a11y_audio_output_label"))
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            if let uiImage = musicPlayerHandler.currentSongUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: reduceTransparency ? 0 : 60)
                    .overlay(Color.black.opacity(reduceTransparency ? 0.6 : 0.3))
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
                    .popupTransitionTarget()
            } else {
                Color.blue
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }
        }
        .task {
            if let song = musicPlayerHandler.currentSong {
                uiImage = await song.image
                musicPlayerHandler.currentSongUIImage = uiImage
            }
        }
        .popupItem {
            PopupItem(
                id: musicPlayerHandler.currentSong,
                title: musicPlayerHandler.currentSong?.metadata?.title ?? "Song Title",
                subtitle: popupBarPlacement == .regular ? musicPlayerHandler.currentSong?.metadata?.author : nil,
                image: Image(uiImage: musicPlayerHandler.currentSongUIImage ?? UIImage()),
                progress: Float(musicPlayerHandler.playbackProgress)
            ) {
                ToolbarItemGroup(placement: .popupBar) {
                    if popupBarPlacement == .regular {
                        Button {
                            musicPlayerHandler.skipToPrevious()
                        } label: {
                            Image(systemName: "backward.fill")
                                .foregroundStyle(.black)
                        }
                        .accessibilityLabel(String(localized: "a11y_previous_track_label"))
                    }

                    Button {
                        musicPlayerHandler.togglePlayPause()
                    } label: {
                        if musicPlayerHandler.isWaiting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Image(systemName: musicPlayerHandler.isPlaying ? "pause.fill" : "play.fill")
                                .foregroundStyle(.black)
                        }
                    }
                    .disabled(musicPlayerHandler.isWaiting)
                    .accessibilityLabel(musicPlayerHandler.isPlaying ? String(localized: "Pause") : String(localized: "Play"))

                    if popupBarPlacement == .regular {
                        Button {
                            musicPlayerHandler.skipToNext()
                        } label: {
                            Image(systemName: "forward.fill")
                                .foregroundStyle(.black)
                        }
                        .accessibilityLabel(String(localized: "a11y_next_track_label"))
                    }

                    Button {
                        controlState.showingPopup = false
                        controlState.showingPopupBar = false
                        musicPlayerHandler.stop()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(.black)
                    }
                    .accessibilityLabel(String(localized: "a11y_stop_close_player_label"))
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.popupBarPlacement) private var popupBarPlacement

    @EnvironmentObject private var musicPlayerHandler: MusicPlayerHandler
    @EnvironmentObject private var controlState: ControlState

    @State private var uiImage: UIImage?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
}

struct SystemVolumeSlider: UIViewRepresentable {
    func makeUIView(context _: Context) -> MPVolumeView {
        let volumeView = MPVolumeView()

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

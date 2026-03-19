import SwiftUI

struct FeatureFlagsView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section {
                Text("Changes apply immediately within this session. Persistent flags are saved to UserDefaults.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                FlagToggle(
                    label: "Experimental Features",
                    icon: "flask",
                    tint: .purple,
                    isOn: $experimentalFeatures
                )
                FlagToggle(
                    label: "Debug Logging",
                    icon: "doc.text.magnifyingglass",
                    tint: .blue,
                    isOn: $debugLogging
                )
            } header: {
                Text("Experimental Flags")
                    .font(.headline)
            } footer: {
                Text("Use with caution. These features may be unstable or cause unexpected behavior.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                FlagToggle(
                    label: "Force Dark Mode",
                    icon: "moon.fill",
                    tint: .indigo,
                    isOn: Binding(
                        get: { forceDarkMode },
                        set: { newVal in
                            forceDarkMode = newVal
                            forceLightMode = !newVal
                        }
                    )
                )
                FlagToggle(
                    label: "Force Light Mode",
                    icon: "sun.max.fill",
                    tint: .yellow,
                    isOn: Binding(
                        get: { forceLightMode },
                        set: { newVal in
                            forceLightMode = newVal
                            forceDarkMode = !newVal
                        }
                    )
                )
            } header: {
                Text("Appearance Overrides")
                    .font(.headline)
            } footer: {
                Text("Force the app to use a specific color scheme, regardless of system settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                FlagToggle(
                    label: "Force Large Titles",
                    icon: "textformat.size.larger",
                    tint: .green,
                    isOn: $forceUseLargeTitle
                )
            } header: {
                Text("UI Tweaks")
                    .font(.headline)
            } footer: {
                Text("Force the app to use large titles in navigation bars.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

        }
        .navigationTitle("Feature Flags")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    @AppStorage(FeatureFlagState.experimentalFeatures.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var experimentalFeatures: Bool = false
    @AppStorage(FeatureFlagState.debugLogging.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var debugLogging: Bool = false
    @AppStorage(FeatureFlagState.forceUseLargeTitle.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var forceUseLargeTitle: Bool = false

    @AppStorage(FeatureFlagState.forceDarkMode.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var forceDarkMode: Bool = false
    @AppStorage(FeatureFlagState.forceLightMode.rawValue, store: UserDefaults(suiteName: "group.MomCare")) private var forceLightMode: Bool = true

}

private struct FlagToggle: View {
    let label: String
    let icon: String
    let tint: Color

    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                Text(label)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(tint)
            }
        }
    }
}

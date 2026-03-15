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

            Section("Experimental") {
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
                FlagToggle(
                    label: "UI Debugging Overlays",
                    icon: "square.dashed",
                    tint: .orange,
                    isOn: $uiDebuggingOverlays
                )
            }

            Section("Appearance") {
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
            }

        }
        .navigationTitle("Feature Flags")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    @AppStorage(FeatureFlagState.experimentalFeatures.rawValue) private var experimentalFeatures: Bool = false
    @AppStorage(FeatureFlagState.debugLogging.rawValue) private var debugLogging: Bool = false
    @AppStorage(FeatureFlagState.uiDebuggingOverlays.rawValue) private var uiDebuggingOverlays: Bool = false
    @AppStorage(FeatureFlagState.forceDarkMode.rawValue) private var forceDarkMode: Bool = false
    @AppStorage(FeatureFlagState.forceLightMode.rawValue) private var forceLightMode: Bool = true

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

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
                    isOn: $store.featureFlags.experimentalFeatures
                )
                FlagToggle(
                    label: "Debug Logging",
                    icon: "doc.text.magnifyingglass",
                    tint: .blue,
                    isOn: $store.featureFlags.debugLogging
                )
                FlagToggle(
                    label: "Use Mock APIs",
                    icon: "server.rack",
                    tint: .cyan,
                    isOn: $store.featureFlags.useMockAPIs
                )
                FlagToggle(
                    label: "UI Debugging Overlays",
                    icon: "square.dashed",
                    tint: .orange,
                    isOn: $store.featureFlags.uiDebuggingOverlays
                )
            }

            Section("Appearance") {
                FlagToggle(
                    label: "Force Dark Mode",
                    icon: "moon.fill",
                    tint: .indigo,
                    isOn: Binding(
                        get: { store.featureFlags.forceDarkMode },
                        set: { newVal in
                            store.featureFlags.forceDarkMode = newVal
                            if newVal { store.featureFlags.forceLightMode = false }
                        }
                    )
                )
                FlagToggle(
                    label: "Force Light Mode",
                    icon: "sun.max.fill",
                    tint: .yellow,
                    isOn: Binding(
                        get: { store.featureFlags.forceLightMode },
                        set: { newVal in
                            store.featureFlags.forceLightMode = newVal
                            if newVal { store.featureFlags.forceDarkMode = false }
                        }
                    )
                )
            }

            Section {
                Button(role: .destructive) {
                    store.featureFlags = FeatureFlagState()
                } label: {
                    Label("Reset All Flags", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .navigationTitle("Feature Flags")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    @EnvironmentObject private var store: DebugMenuStore

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

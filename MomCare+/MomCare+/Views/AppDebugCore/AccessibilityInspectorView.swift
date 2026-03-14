// AccessibilityInspectorView.swift

import SwiftUI
import UIKit
import Combine

struct AccessibilityInspectorView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section("Assistive Technologies") {
                AccessibilityRow(label: "VoiceOver", isEnabled: unsafe UIAccessibility.isVoiceOverRunning)
                AccessibilityRow(label: "Switch Control", isEnabled: unsafe UIAccessibility.isSwitchControlRunning)
                AccessibilityRow(label: "AssistiveTouch", isEnabled: unsafe UIAccessibility.isAssistiveTouchRunning)
                AccessibilityRow(label: "Guided Access", isEnabled: unsafe UIAccessibility.isGuidedAccessEnabled)
            }

            Section("Visual Adjustments") {
                AccessibilityRow(label: "Reduce Motion", isEnabled: unsafe UIAccessibility.isReduceMotionEnabled)
                AccessibilityRow(label: "Reduce Transparency", isEnabled: unsafe UIAccessibility.isReduceTransparencyEnabled)
                AccessibilityRow(label: "Bold Text", isEnabled: unsafe UIAccessibility.isBoldTextEnabled)
                AccessibilityRow(label: "Button Shapes", isEnabled: unsafe UIAccessibility.buttonShapesEnabled)
                AccessibilityRow(label: "Differentiate Without Color", isEnabled: unsafe UIAccessibility.shouldDifferentiateWithoutColor)
            }

            Section("Audio & Captions") {
                AccessibilityRow(label: "Mono Audio", isEnabled: unsafe UIAccessibility.isMonoAudioEnabled)
                AccessibilityRow(label: "Closed Captions", isEnabled: unsafe UIAccessibility.isClosedCaptioningEnabled)
            }

            Section("Typography") {
                DebugRow(label: "Dynamic Type Size", value: dynamicTypeLabel)
            }
        }
        .navigationTitle("Accessibility Inspector")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in refresh.toggle() }
        .id(refresh) // forces redraw
    }

    // MARK: Private

    // Refresh every second so toggles in Settings are reflected quickly
    @State private var refresh = false

    private let timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()

    private var dynamicTypeLabel: String {
        // Map UIContentSizeCategory to a readable label
        let cat = UIApplication.shared.preferredContentSizeCategory
        switch cat {
        case .extraSmall: return "XS"
        case .small: return "S"
        case .medium: return "M"
        case .large: return "L (Default)"
        case .extraLarge: return "XL"
        case .extraExtraLarge: return "XXL"
        case .extraExtraExtraLarge: return "XXXL"
        case .accessibilityMedium: return "AX-M"
        case .accessibilityLarge: return "AX-L"
        case .accessibilityExtraLarge: return "AX-XL"
        case .accessibilityExtraExtraLarge: return "AX-XXL"
        case .accessibilityExtraExtraExtraLarge: return "AX-XXXL"
        default: return cat.rawValue
        }
    }
}

// MARK: - Helper Row

private struct AccessibilityRow: View {
    let label: String
    let isEnabled: Bool

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(isEnabled ? Color.green : Color.secondary.opacity(0.4))
                    .frame(width: 8, height: 8)
                Text(isEnabled ? "On" : "Off")
                    .font(.subheadline)
                    .foregroundStyle(isEnabled ? .green : .secondary)
            }
        }
    }
}

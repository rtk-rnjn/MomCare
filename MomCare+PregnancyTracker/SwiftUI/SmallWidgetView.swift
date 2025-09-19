//
//  SmallWidgetView.swift
//  MomCare
//
//  Created by Nupur on 13/09/25.
//

import SwiftUI
import WidgetKit

struct SmallPregnancyWidgetView: View {
    let entry: TriTrackEntry

    @State private var animatedProgress: CGFloat = 0
    @State private var pulse: Bool = false
    @State private var breathe: Bool = false

    private let segmentColors: [Color] = [
        Color(hex: "#D27C8C"),
        Color(hex: "#C98393"),
        Color(hex: "#B26B7B"),
        Color(hex: "#9C5A69")
    ]

    var body: some View {
        ZStack {
            // MARK: - Glassmorphism Background
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(Color(hex: "#E9D3D3").opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )

            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let circleSize = size * 0.75
                let lineWidth = size * 0.07

                ZStack {
                    // Background Segments
                    backgroundSegments(circleSize: circleSize, lineWidth: lineWidth)

                    // Progress Arc with pulse
                    progressArc(circleSize: circleSize)
                        .scaleEffect(pulse ? 1.03 : 1.0)

                    // Center Text with breathing animation
                    centerText(circleSize: circleSize)
                        .scaleEffect(breathe ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: breathe)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8)) {
                        animatedProgress = CGFloat(min(Double(entry.week) / 40.0, 1.0))
                    }
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        pulse.toggle()
                    }
                    breathe.toggle()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
    }

    // MARK: - Background Segments
    private func backgroundSegments(circleSize: CGFloat, lineWidth: CGFloat) -> some View {
        ForEach(0..<4) { i in
            Circle()
                .trim(from: CGFloat(i) * 0.25, to: CGFloat(i + 1) * 0.25)
                .stroke(
                    segmentColors[i].opacity(0.25),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: circleSize, height: circleSize)
        }
    }

    // MARK: - Progress Arc
    private func progressArc(circleSize: CGFloat) -> some View {
        Circle()
            .trim(from: 0, to: animatedProgress)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#6F4685"),
                        Color(hex: "#C54B8C"),
                        Color(hex: "#6C3082")
                    ]),
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 10, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .frame(width: circleSize, height: circleSize)
            .shadow(color: Color.pink.opacity(0.3), radius: pulse ? 8 : 3)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
    }

    // MARK: - Center Text
    private func centerText(circleSize: CGFloat) -> some View {
        VStack(spacing: -3) {
            Text("Week \(entry.week)")
                .font(.system(.subheadline, design: .rounded))
                .monospacedDigit()
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#924350"))

            Text("Day \(entry.day)")
                .font(.system(.subheadline, design: .rounded))
                .monospacedDigit()
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#924350"))

            Text("Trimester \(entry.trimester)")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "#924350"))
        }
        .frame(width: circleSize * 0.8, height: circleSize * 0.8)
    }
}

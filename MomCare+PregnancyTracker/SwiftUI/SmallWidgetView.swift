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

    private let segmentColors: [Color] = [
        Color(hex: "#D27C8C"),
        Color(hex: "#C98393"),
        Color(hex: "#B26B7B"),
        Color(hex: "#9C5A69")
    ]

    var body: some View {
        ZStack {
            Color(hex: "#E9D3D3")
                .ignoresSafeArea()

            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let circleSize = size * 0.78
                let lineWidth = size * 0.07

                ZStack {
                    backgroundSegments(circleSize: circleSize, lineWidth: lineWidth)
                    progressArc(circleSize: circleSize)
                    centerText(circleSize: circleSize)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Extracted Subviews

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

    private func progressArc(circleSize: CGFloat) -> some View {
        // Calculate progress based on week (0 to 40 weeks)
        let progress = min(Double(entry.week) / 40.0, 1.0)

        return Circle()
            .trim(from: 0, to: CGFloat(progress)) // use calculated progress
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
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
    }


    private func centerText(circleSize: CGFloat) -> some View {
        VStack(spacing: -3) {
            Text("Week \(entry.week)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#924350"))

            Text("Day \(entry.day)")
                .font(.subheadline)
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

import SwiftUI
import UIKit

struct SemiCircleEyeRepresentable: UIViewRepresentable {
    let useSemiCircle: Bool
    let color: UIColor
    let reduceMotion: Bool

    func makeUIView(context _: Context) -> SemiCircleAnimationView {
        let view = SemiCircleAnimationView()
        view.setColor(color: color.cgColor)
        return view
    }

    func updateUIView(_ uiView: SemiCircleAnimationView, context _: Context) {
        uiView.setColor(color: color.cgColor)

        if useSemiCircle {
            uiView.animateToSemiCircle(animated: !reduceMotion)
        } else {
            uiView.animateToFullCircle(animated: !reduceMotion)
        }
    }
}

struct MiniMoodFaceView: View {
    let mood: MoodType
    let color: Color
    let isActive: Bool

    var body: some View {
        VStack(spacing: 5) {
            // Eyes
            HStack(spacing: 10) {
                eye(isLeft: true)
                eye(isLeft: false)
            }

            Group {
                if mood == .happy {
                    SmileShape()
                        .stroke(
                            color,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 14, height: 7)
                        .offset(y: -3)
                } else {
                    SadSmileShape()
                        .stroke(
                            color,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 14, height: 7)
                        .offset(y: -1)
                }
            }
        }
        .opacity(isActive ? 1.0 : 0.7)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    func eye(isLeft: Bool) -> some View {
        switch mood {
        case .happy:
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)

        case .sad:
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

        case .stressed:
            Capsule()
                .fill(color)
                .frame(width: 12, height: 4)

        case .angry:
            HalfCircle()
                .fill(color)
                .frame(width: 12, height: 12)
                .rotationEffect(
                    isLeft ? .degrees(30) : .degrees(-30)
                )
        }
    }
}

struct HalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()

        return path
    }
}

struct ArcEyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )

        return path
    }
}

struct SadSmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY + rect.height / 2),
            radius: rect.width / 2,
            startAngle: .degrees(200),
            endAngle: .degrees(-20),
            clockwise: false
        )

        return path
    }
}

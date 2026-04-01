import SwiftUI

struct EyeView: View {
    let isSemiCircleEyes: Bool
    let faceColor: Color
    let eyeScale: CGSize

    var rotation: Angle

    var body: some View {
        SemiCircleEyeRepresentable(
            useSemiCircle: isSemiCircleEyes,
            color: UIColor(faceColor)
        )
        .frame(maxWidth: 130, maxHeight: 130)
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(eyeScale)
        .rotationEffect(rotation)
        .accessibilityHidden(true)
    }
}

struct SmileView: View {
    let rotation: Angle
    let color: Color

    var body: some View {
        SmileShape()
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: 13, // ✅ thinner = cleaner emoji look
                    lineCap: .round
                )
            )
            .frame(width: 42, height: 16) // ✅ correct proportions
            .rotationEffect(rotation)
            .accessibilityHidden(true)
    }
}

struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.maxY * 2.0)
        )
        return path
    }
}

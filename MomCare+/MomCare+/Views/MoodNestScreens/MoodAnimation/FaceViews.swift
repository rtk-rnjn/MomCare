import SwiftUI

struct EyeView: View {
    @ObservedObject var moodNestViewModel: MoodNestViewModel

    let isLeft: Bool

    var rotation: Angle {
        isLeft ? moodNestViewModel.eyeRotationLeft : moodNestViewModel.eyeRotationRight
    }

    var body: some View {
        SemiCircleEyeRepresentable(
            useSemiCircle: moodNestViewModel.useSemiCircleEyes,
            color: UIColor(moodNestViewModel.faceColor)
        )
        .frame(width: 130, height: 130)
        .scaleEffect(moodNestViewModel.eyeScale)
        .rotationEffect(rotation)
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
                    lineWidth: 18,
                    lineCap: .round
                )
            )
            .frame(width: 70, height: 30)
            .rotationEffect(rotation)
    }
}

struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.maxY * 2)
        )
        return path
    }
}

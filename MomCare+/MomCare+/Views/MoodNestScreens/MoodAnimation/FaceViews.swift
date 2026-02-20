

import SwiftUI

struct EyeView: View {
    @ObservedObject var vm: MoodNestViewModel

    let isLeft: Bool

    var rotation: Angle {
        isLeft ? vm.eyeRotationLeft : vm.eyeRotationRight
    }

    var body: some View {
        SemiCircleEyeRepresentable(
            useSemiCircle: vm.useSemiCircleEyes,
            color: UIColor(vm.faceColor)
        )
        .frame(width: 130, height: 130)
        .scaleEffect(vm.eyeScale)
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

import SwiftUI
import UIKit

struct SemiCircleEyeRepresentable: UIViewRepresentable {
    let useSemiCircle: Bool
    let color: UIColor

    func makeUIView(context _: Context) -> SemiCircleAnimationView {
        let view = SemiCircleAnimationView()
        view.setColor(color: color.cgColor)
        return view
    }

    func updateUIView(_ uiView: SemiCircleAnimationView, context _: Context) {
        uiView.setColor(color: color.cgColor)

        if useSemiCircle {
            uiView.animateToSemiCircle()
        } else {
            uiView.animateToFullCircle()
        }
    }
}

//struct ArcShape: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        
//        let radius = rect.width * 0.4
//        let center = CGPoint(x: rect.midX, y: rect.maxY - 20)
//        
//        path.addArc(
//            center: center,
//            radius: radius,
//            startAngle: .degrees(200),
//            endAngle: .degrees(-20),
//            clockwise: false
//        )
//        
//        return path
//    }
//}

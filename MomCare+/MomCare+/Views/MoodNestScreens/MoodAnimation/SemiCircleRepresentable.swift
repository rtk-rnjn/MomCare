

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

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

struct ArcSmile: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(20),
            endAngle: .degrees(160),
            clockwise: false
        )
        
        return path
    }
}

struct MiniMoodFaceView: View {
    let mood: MoodType
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            
            //Eyes
            HStack(spacing: 10) {
                eye(isLeft: true)
                eye(isLeft: false)
            }
            
            //Mouth
            SmileShape()
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                    )
                )
                .frame(width: 14, height: 7)
                .rotationEffect(mouthRotation)
                .offset(y: mood == .happy ? -3 : -1)
        }
    }
    
    // MARK: - Eyes
    
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
                .frame(width: 12, height: 12)
            
        case .stressed:
            Capsule()
                .fill(color)
                .frame(width: 12, height: 4)
            
        case .angry:
            HalfCircle()
                .fill(color)
                .frame(width: 12, height: 12)
                .rotationEffect(isLeft ? .degrees(30) : .degrees(-30))
        }
    }
    
    // MARK: - Mouth
    
    var mouthRotation: Angle {
        switch mood {
        case .happy:
            return .degrees(0)
        case .sad, .stressed, .angry:
            return .degrees(180)
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

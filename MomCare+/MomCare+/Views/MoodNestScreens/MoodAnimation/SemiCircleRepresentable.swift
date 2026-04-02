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

// MARK: - Mini Mood Face

struct MiniMoodFaceView: View {
    let mood: MoodType
    let color: Color
    let isActive: Bool
    let trigger: UUID

    enum AngryPhase {
        case idle       // normal angry
        case relaxed    // neutral
        case intense    // over-angry spike
    }
    enum SadPhase {
        case idle
        case crying
        case release
    }

    @State private var angryPhase: AngryPhase = .idle
    @State private var sadPhase: SadPhase = .idle

    var body: some View {
        VStack(spacing: 5) {

            // Eyes
            ZStack {
                HStack(spacing: 10) {
                    eye(isLeft: true)
                    eye(isLeft: false)
                }

                // 💧 Tear (right eye)
                if mood == .sad && sadPhase != .idle {
                    Circle()
                        .fill(Color(hex: "#7FAEDB"))
                        .frame(width: 5, height: 7)
                        .offset(
                            x: 8,
                            y: sadPhase == .release ? 16 : 2
                        )
                        .opacity(sadPhase == .release ? 0 : 1)
                        .scaleEffect(sadPhase == .crying ? 1.2 : 0.8)
                        .animation(.easeIn(duration: 0.4), value: sadPhase)
                }
            }
            .offset(y: sadPhase == .crying ? -2 : 0) // 👈 POP UP
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: sadPhase)

            // Mouth
            SmileShape()
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 14, height: 7)
                .rotationEffect(mouthRotation)
                .offset(y: mood == .happy ? -3 : -1)
        }

        // 👇 Initial state
        .onAppear {
            if mood == .angry {
                angryPhase = .idle
            }
        }

        // 👇 Trigger animation
        .onChange(of: trigger) { _, _ in
            if mood == .angry {
                triggerAngryAnimation()
            } else if mood == .sad {
                triggerSadAnimation()
            }
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
            if sadPhase == .idle {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
            } else {
                ArcEyeShape()
                    .stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: 12, height: 8)
                    .scaleEffect(sadPhase == .crying ? 1.1 : 1.0)
            }

        case .stressed:
            Capsule()
                .fill(color)
                .frame(width: 12, height: 4)

        case .angry:
            HalfCircle()
                .fill(color)
                .frame(width: 12, height: 12)
                .rotationEffect(
                    isLeft
                    ? .degrees(rotationForPhase(isLeft: true))
                    : .degrees(rotationForPhase(isLeft: false))
                )
                .scaleEffect(scaleForPhase())
        }
    }

    // MARK: - Animation Logic

    func triggerAngryAnimation() {
        guard mood == .angry else { return }

        // Step 1: Relax 😐 (slower + smoother)
        withAnimation(.easeInOut(duration: 0.18)) {
            angryPhase = .relaxed
        }

        // Step 2: INTENSE 😡🔥 (less aggressive spring)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                angryPhase = .intense
            }
        }

        // Step 3: Settle 😤 (smooth return)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.25)) {
                angryPhase = .idle
            }
        }
    }
    func triggerSadAnimation() {
        guard mood == .sad else { return }

        // Step 1: pop + eyes change
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            sadPhase = .crying
        }

        // Step 2: tear falls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()

            withAnimation(.easeIn(duration: 0.45)) {
                sadPhase = .release
            }
        }

        // Step 3: reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 0.25)) {
                sadPhase = .idle
            }
        }
    }

    // MARK: - Phase Helpers

    func rotationForPhase(isLeft: Bool) -> Double {
        switch angryPhase {
        case .idle:
            return isLeft ? 30 : -30
        case .relaxed:
            return isLeft ? 10 : -10
        case .intense:
            return isLeft ? 55 : -55
        }
    }

    func scaleForPhase() -> CGFloat {
        switch angryPhase {
        case .idle:
            return 1.0
        case .relaxed:
            return 1.05
        case .intense:
            return 0.8
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

// MARK: - Half Circle Shape

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
            startAngle: .degrees(200),
            endAngle: .degrees(-20),
            clockwise: false
        )

        return path
    }
}

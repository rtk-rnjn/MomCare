import SwiftUI

struct WaterDropShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let cx = rect.midX

        let circleR = w * 0.42
        let circleCY = h * 0.62

        var path = Path()

        path.move(to: CGPoint(x: cx, y: 0))

        path.addCurve(
            to: CGPoint(x: cx - circleR, y: circleCY),
            control1: CGPoint(x: cx - w * 0.08, y: h * 0.18),
            control2: CGPoint(x: cx - circleR, y: circleCY - h * 0.22)
        )

        path.addArc(
            center: CGPoint(x: cx, y: circleCY),
            radius: circleR,
            startAngle: .degrees(0),
            endAngle: .degrees(0-360),
            clockwise: true
        )

        path.addCurve(
            to: CGPoint(x: cx, y: 0),
            control1: CGPoint(x: cx + circleR, y: circleCY - h * 0.22),
            control2: CGPoint(x: cx + w * 0.08, y: h * 0.18)
        )

        path.closeSubpath()
        return path
    }
}

struct WaterDropFillView: View {

    // MARK: Internal

    var progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack {
                WaterDropShape()
                    .fill(Color(hex: "D6EAF8").opacity(0.55))

                TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                    Canvas { ctx, size in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        drawWave(ctx: &ctx, size: size, t: t)
                    }
                }
                .clipShape(WaterDropShape())

                VStack {
                    Spacer()
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(size: geo.size.width * 0.19, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color(hex: "4A90C4").opacity(0.4), radius: 4, x: 0, y: 2)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.5), value: Int(animatedProgress * 100))
                        .padding(.bottom, geo.size.height * 0.12)
                }

            }
        }
        .onChange(of: progress) { _, new in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.72)) {
                animatedProgress = new
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.3, dampingFraction: 0.75).delay(0.3)) {
                animatedProgress = progress
            }
        }
    }

    // MARK: Private

    @State private var animatedProgress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let bubbleSeeds: [(Double, Double, Double, Double, Double)] = (0..<18).map { i in
        let seed = Double(i)
        return (
            fmod(abs(sin(seed * 17.3)), 1.0),
            Double.random(in: 2.0...5.5),
            Double.random(in: 3.5...8.5),
            Double.random(in: 0...9),
            seed * 1.618
        )
    }

    private func drawWave(ctx: inout GraphicsContext, size: CGSize, t: Double) {
        let fillY = size.height * (1.0 - animatedProgress)

        let back = wavePath(size: size, fillY: fillY - 8, amplitude: 10, frequency: 0.9, phase: t * 0.75 + 1.8)
        ctx.fill(back, with: .color(Color(hex: "7BB8E8").opacity(0.5)))

        let front = wavePath(size: size, fillY: fillY,
                             amplitude: 8, frequency: 1.15, phase: t * 1.2)
        ctx.fill(front, with: .color(Color(hex: "5B9BD5").opacity(0.9)))

        drawShimmer(ctx: &ctx, size: size, fillY: fillY, t: t)
        drawBubbles(ctx: &ctx, size: size, fillY: fillY, t: t)
    }

    private func wavePath(
        size: CGSize, fillY: Double,
        amplitude: Double, frequency: Double, phase: Double
    ) -> Path {
        var path = Path()
        let steps = Int(size.width / 2) + 2
        for i in 0...steps {
            let x = Double(i) * (size.width / Double(steps))
            let y = fillY + sin((x / size.width * frequency * .pi * 2) + phase) * amplitude
            i == 0 ? path.move(to: .init(x: x, y: y)) : path.addLine(to: .init(x: x, y: y))
        }
        path.addLine(to: .init(x: size.width, y: size.height))
        path.addLine(to: .init(x: 0, y: size.height))
        path.closeSubpath()
        return path
    }

    private func drawShimmer(ctx: inout GraphicsContext, size: CGSize, fillY: Double, t: Double) {
        guard animatedProgress > 0.04 else { return }
        for i in 0..<4 {
            let seed = Double(i) * 97.3
            let x = (sin(seed) * 0.5 + 0.5) * size.width
            let baseY = fillY + 16 + (sin(seed * 0.5) * 0.5 + 0.5) * (size.height - fillY - 30)
            let drift = sin(t * 0.45 + seed) * 14
            let alpha = (sin(t * 0.3 + seed * 0.35) * 0.5 + 0.5) * 0.12
            var s = Path()
            s.move(to: .init(x: x + drift, y: baseY))
            s.addLine(to: .init(x: x + drift + 4, y: baseY + 28))
            ctx.stroke(s, with: .color(Color.white.opacity(alpha)), lineWidth: 1.0)
        }
    }

    private func drawBubbles(ctx: inout GraphicsContext, size: CGSize, fillY: Double, t: Double) {
        guard animatedProgress > 0.06 else { return }
        for (xFrac, radius, lifespan, birthOff, driftPhase) in bubbleSeeds {
            let elapsed = (t - birthOff).truncatingRemainder(dividingBy: lifespan)
            let cycleT = elapsed / lifespan
            let yRange = size.height - fillY
            let rawY = fillY + yRange * (1.0 - cycleT)
            let drift = sin(cycleT * .pi * 2.0 + driftPhase) * 9
            let x = xFrac * size.width + drift
            let alpha = min(cycleT * 5, 1.0) * max(1.0 - cycleT * 2.8, 0.0) * 0.75
            guard alpha > 0.01 else { continue }
            let r = radius
            let rect = CGRect(x: x - r, y: rawY - r, width: r * 2, height: r * 2)
            let ell = Path(ellipseIn: rect)
            ctx.fill(ell, with: .color(Color.white.opacity(alpha * 0.28)))
            ctx.stroke(ell, with: .color(Color.white.opacity(alpha * 0.6)), lineWidth: 0.7)
        }
    }
}

struct WaterRippleEffect: View {

    // MARK: Internal

    var body: some View {
        Circle()
            .stroke(Color(hex: "5B9BD5"), lineWidth: 1.5)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    scale = 2.0
                    opacity = 0
                }
            }
    }

    // MARK: Private

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0.55

}

struct SplashParticleView: View {

    // MARK: Internal

    var body: some View {
        ZStack {
            ForEach(offsets.indices, id: \.self) { i in
                Circle()
                    .fill(Color(hex: "7BB8E8").opacity(appeared ? 0 : 0.75))
                    .frame(width: CGFloat.random(in: 3...6), height: CGFloat.random(in: 3...6))
                    .offset(appeared ? offsets[i] : .zero)
            }
        }
        .onAppear { withAnimation(.easeOut(duration: 0.55)) { appeared = true } }
    }

    // MARK: Private

    @State private var offsets: [CGSize] = (0..<10).map { i in
        let angle = Double(i) / 10.0 * .pi * 2
        return CGSize(width: cos(angle) * Double.random(in: 16...46),
                      height: -abs(sin(angle)) * Double.random(in: 22...55))
    }

    @State private var appeared = false

}

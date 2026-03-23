import SwiftUI

/// https://gist.github.com/frankfka/2517d69da68ef041e3257d5cfd27fe5d

extension Double {
    nonisolated func toRadians() -> Double { self * Double.pi / 180 }
    nonisolated func toCGFloat() -> CGFloat { CGFloat(self) }
}

struct RingShape: Shape {

    // MARK: Lifecycle

    init(percent: Double = 100, startAngle: Double = -90, drawnClockwise: Bool = false) {
        self.percent = percent
        self.startAngle = startAngle
        self.drawnClockwise = drawnClockwise
    }

    // MARK: Internal

    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }

    static func percentToAngle(percent: Double, startAngle: Double) -> Double {
        (percent / 100 * 360) + startAngle
    }

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let endAngle = Angle(degrees: RingShape.percentToAngle(percent: percent, startAngle: startAngle))
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: Angle(degrees: startAngle), endAngle: endAngle, clockwise: drawnClockwise)
        }
    }

    // MARK: Private

    private var percent: Double
    private var startAngle: Double
    private let drawnClockwise: Bool

}

struct RingCapShape: Shape {

    var percent: Double
    var startAngle: Double = -90

    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let angleInRadians = RingShape.percentToAngle(percent: percent, startAngle: startAngle).toRadians()
        let capCenter = CGPoint(
            x: center.x + radius * cos(angleInRadians).toCGFloat(),
            y: center.y + radius * sin(angleInRadians).toCGFloat()
        )
        return Path(ellipseIn: CGRect(origin: capCenter, size: .zero))
    }
}

struct PercentageRing: View {

    // MARK: Internal

    let ringWidth: CGFloat
    let percent: Double
    let backgroundColor: Color
    let foregroundColors: [Color]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RingShape()
                    .stroke(style: StrokeStyle(lineWidth: ringWidth))
                    .fill(reduceTransparency ? Color(.systemGray4) : backgroundColor)

                RingShape(percent: percent, startAngle: startAngle)
                    .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                    .fill(reduceTransparency ? AnyShapeStyle(lastGradientColor) : AnyShapeStyle(ringGradient))
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.6), value: percent)

                EndCapShape(percent: percent, startAngle: startAngle, radius: capRadius(frame: geometry.size))
                    .fill(lastGradientColor)
                    .frame(width: ringWidth, height: ringWidth)
                    .shadow(
                        color: reduceTransparency || percent < 100 ? .clear : shadowColor,
                        radius: shadowRadius,
                        x: endCapShadowOffset.0,
                        y: endCapShadowOffset.1
                    )
                    .opacity(showCap ? 1 : 0)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.6), value: percent)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: showCap)
            }
        }
        .padding(ringWidth / 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress ring")
        .accessibilityValue("\(Int(percent.clamped(to: 0...100)))%")
        .accessibilityAddTraits(.updatesFrequently)
    }

    // MARK: Private

    private static let shadowColor: Color = .black.opacity(0.3)
    private static let shadowRadius: CGFloat = 1
    private static let shadowOffsetMultiplier: CGFloat = shadowRadius + 2

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let shadowColor: Color = PercentageRing.shadowColor
    private let shadowRadius: CGFloat = PercentageRing.shadowRadius
    private let startAngle: Double = -90

    private var gradientStartAngle: Double {
        percent >= 100 ? relativePercentageAngle - 360 : startAngle
    }

    private var absolutePercentageAngle: Double {
        RingShape.percentToAngle(percent: percent, startAngle: 0)
    }

    private var relativePercentageAngle: Double {
        absolutePercentageAngle + startAngle
    }

    private var lastGradientColor: Color {
        foregroundColors.last ?? .black
    }

    private var ringGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: foregroundColors),
            center: .center,
            startAngle: Angle(degrees: gradientStartAngle),
            endAngle: Angle(degrees: relativePercentageAngle)
        )
    }

    private var showCap: Bool {
        percent > 0
    }

    private var endCapShadowOffset: (CGFloat, CGFloat) {
        let angleForOffset = absolutePercentageAngle + (startAngle + 90)
        let angleInRadians = angleForOffset.toRadians()
        return (
            cos(angleInRadians).toCGFloat() * PercentageRing.shadowOffsetMultiplier,
            sin(angleInRadians).toCGFloat() * PercentageRing.shadowOffsetMultiplier
        )
    }

    private func capRadius(frame: CGSize) -> CGFloat {
        min(frame.width, frame.height) / 2
    }
}

private struct EndCapShape: Shape {

    var percent: Double
    var startAngle: Double
    var radius: CGFloat

    var animatableData: AnimatablePair<Double, CGFloat> {
        get { AnimatablePair(percent, radius) }
        set { percent = newValue.first; radius = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        let angleInRadians = RingShape.percentToAngle(percent: percent, startAngle: startAngle).toRadians()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let capCenter = CGPoint(
            x: center.x + radius * cos(angleInRadians).toCGFloat(),
            y: center.y + radius * sin(angleInRadians).toCGFloat()
        )
        let capRadius = rect.width / 2
        return Path(ellipseIn: CGRect(
            x: capCenter.x - capRadius,
            y: capCenter.y - capRadius,
            width: capRadius * 2,
            height: capRadius * 2
        ))
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        if isNaN {
            return range.lowerBound
        }

        if isInfinite {
            return range.lowerBound
        }

        return min(max(self, range.lowerBound), range.upperBound)
    }
}

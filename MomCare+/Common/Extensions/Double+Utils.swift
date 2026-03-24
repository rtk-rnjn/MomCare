import CoreGraphics

extension Double {
    nonisolated func toRadians() -> Double {
        self * Double.pi / 180
    }

    nonisolated func toCGFloat() -> CGFloat {
        CGFloat(self)
    }

    nonisolated func clamped(to range: ClosedRange<Double>) -> Double {
        if isNaN {
            return range.lowerBound
        }

        if isInfinite {
            return range.lowerBound
        }

        return min(max(self, range.lowerBound), range.upperBound)
    }
}

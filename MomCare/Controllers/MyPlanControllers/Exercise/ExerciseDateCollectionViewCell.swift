import UIKit

class ExerciseDateCellCollectionViewCell: UICollectionViewCell {

    // MARK: Internal

    @IBOutlet var sundayRing: UIView!
    @IBOutlet var mondayRing: UIView!
    @IBOutlet var tuesdayRing: UIView!
    @IBOutlet var wednesdayRing: UIView!
    @IBOutlet var thursdayRing: UIView!
    @IBOutlet var fridayRing: UIView!
    @IBOutlet var saturdayRing: UIView!

    var ringViews: [UIView] = []

    func prepareViewRings() {
        let history: [History] = MomCareUser.shared.user?.history ?? []

        let today = Date()
        let calendar = Calendar.current

        let weekday = calendar.component(.weekday, from: today)
        let daysToLastSunday = weekday == 1 ? 7 : weekday
        guard let lastSunday = calendar.date(byAdding: .day, value: -daysToLastSunday, to: today) else {
            return
        }

        let exerciseHistory = history.filter {
            $0.date >= lastSunday
        }.sorted { $0.date < $1.date }

        ringViews = [
            sundayRing, mondayRing, tuesdayRing, wednesdayRing, thursdayRing, fridayRing, saturdayRing
        ]

        let startIndex = weekday - 1
        let endIndex = startIndex - exerciseHistory.count + 1

        guard endIndex >= 0 else { return } // just in case

        for index in stride(from: startIndex, through: endIndex, by: -1) {
            prepareExerciseRing(with: ringViews[index])
            let history = exerciseHistory[abs(startIndex - index)]
            let percent = history.completionPercentage / 100
            animateRings(to: percent)
        }

        // fill the remaining rings with 0% completion
        for index in stride(from: endIndex - 1, through: 0, by: -1) {
            prepareExerciseRing(with: ringViews[index])
            animateRings(to: 0)
        }

        for index in stride(from: startIndex + 1, to: ringViews.count, by: 1) {
            prepareExerciseRing(with: ringViews[index])
            animateRings(to: 0)
        }
    }

    func animateRings(to value: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = shapeLayer.strokeEnd
        animation.toValue = value
        animation.duration = 1.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shapeLayer.strokeEnd = value
        shapeLayer.add(animation, forKey: "ringAnimation")
    }

    // MARK: Private

    private var backgroundLayer: CAShapeLayer!
    private var shapeLayer: CAShapeLayer!

    private func prepareExerciseRing(with view: UIView) {
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let radius: CGFloat = 14
        let lineWidth: CGFloat = 7

        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: .pi * 3 / 2, clockwise: true)

        backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.strokeColor = UIColor(hex: "E7DBDB").cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1
        view.layer.addSublayer(backgroundLayer)

        shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.strokeColor = UIColor(hex: "B9898A").cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }

}

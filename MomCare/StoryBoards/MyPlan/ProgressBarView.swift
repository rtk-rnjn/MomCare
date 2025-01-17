//
//  ProgressBarView.swift
//  MomCare
//
//  Created by Aryan Singh on 17/01/25.
//

import UIKit

class ProgressBarView: UIView {

    private var progressLayer: UIView!

        var progress: CGFloat = 0 {
            didSet {
                setProgress(progress)
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupProgressLayer()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupProgressLayer()
        }

        private func setupProgressLayer() {
            progressLayer = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
            progressLayer.backgroundColor = UIColor.green
            addSubview(progressLayer)
        }

        private func setProgress(_ progress: CGFloat) {
            let width = bounds.width * progress
            progressLayer.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        }
}

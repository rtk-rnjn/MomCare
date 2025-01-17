//
//  ProgressRing.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import UIKit

    class ProgressView: UIView {
        private var progressRing = UIProgressView(progressViewStyle: .default)

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupProgressRing()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupProgressRing()
        }

        func setupProgressRing() {
            progressRing.frame = CGRect(x: 0, y: 0, width: 200, height: 20) // Customize size
            progressRing.progress = 0.5  // Example progress
            progressRing.trackTintColor = .lightGray
            progressRing.tintColor = .blue
            self.addSubview(progressRing)
        }

        func updateProgress(to value: Float) {
            progressRing.setProgress(value, animated: true)
        }
    }

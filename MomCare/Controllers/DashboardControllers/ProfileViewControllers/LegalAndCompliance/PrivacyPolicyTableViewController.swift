//
//  PrivacyPolicyTableViewController.swift
//  MomCare
//
//  Created by Nupur on 23/07/25.
//

import UIKit

class PrivacyPolicyTableViewController: UITableViewController {

    @IBOutlet var privacyPoliceDescription: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let bullet = "\u{2022}"
        let items = [
                "What data we collect",
                "Why we collect it",
                "How it’s used, stored, and shared",
                "Your rights over your data"
            ]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15 // space after bullet
        paragraphStyle.paragraphSpacing = 6 // space between bullet lines
        paragraphStyle.lineSpacing = 4 // line spacing
        paragraphStyle.alignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]

        let bulletText = NSMutableAttributedString()

        for (index, item) in items.enumerated() {
            let suffix = index == items.count - 1 ? "" : "\n"
            let line = "\(bullet) \(item)\(suffix)"
            bulletText.append(NSAttributedString(string: line, attributes: attributes))
        }

        privacyPoliceDescription.numberOfLines = 0
        privacyPoliceDescription.attributedText = bulletText
    }

}

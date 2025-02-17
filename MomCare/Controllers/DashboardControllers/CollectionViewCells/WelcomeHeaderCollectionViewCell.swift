//
//  WelcomeHeaderCollectionViewCell.swift
//  MomCare
//
//  Created by Batch-2 on 17/01/25.
//

import UIKit

class WelcomeHeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var profileIcon: UIImageView!
    
    var tapHandler: (() -> Void)?

    func updateElements(with title: String, tapHandler: (() -> Void)?) {
        titleLabel.text = title
        self.tapHandler = tapHandler
        
        setupGesture()
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        profileIcon.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        guard let tapHandler else { return }
        tapHandler()
    }
}

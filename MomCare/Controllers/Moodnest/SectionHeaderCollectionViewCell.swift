//
//  SectionHeaderCollectionViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 18/01/25.
//

import UIKit

class SectionHeaderCollectionViewCell: UICollectionViewCell {
    var HeaderLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateSectionHeader()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateSectionHeader()
    }
    
    func updateSectionHeader() {
        HeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(HeaderLabel)
        NSLayoutConstraint.activate([
            HeaderLabel.topAnchor.constraint(equalTo: topAnchor),
            HeaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            HeaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            HeaderLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

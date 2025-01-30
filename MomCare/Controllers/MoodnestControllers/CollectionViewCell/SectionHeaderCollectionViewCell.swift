//
//  SectionHeaderCollectionViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 18/01/25.
//

import UIKit

class SectionHeaderCollectionViewCell: UICollectionViewCell {
    var headerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateSectionHeader()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateSectionHeader()
    }

    func updateSectionHeader() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

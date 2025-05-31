//
//  SectionHeaderCollectionViewCell.swift
//  MomCare
//
//  Created by Batch - 2  on 18/01/25.
//

import UIKit

class SectionHeaderCollectionViewCell: UICollectionViewCell {

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        DispatchQueue.main.async {
            self.updateSectionHeader()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        DispatchQueue.main.async {
            self.updateSectionHeader()
        }
    }

    // MARK: Internal

    var headerLabel: UILabel = .init()

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

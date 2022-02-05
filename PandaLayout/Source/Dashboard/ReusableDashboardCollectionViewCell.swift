//
//  ReusableDashboardCollectionViewCell.swift
//  PandaLayout
//
//  Created by Ryan Newlun on 1/30/22.
//

import Foundation
import UIKit

class ReusableDashboardCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ReusableDashboardCollectionViewCell"
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        let size = systemLayoutSizeFitting(layoutAttributes.size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        layoutAttributes.frame.size = size
        return layoutAttributes
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.first?.removeFromSuperview()
    }
    
    static let colors: [UIColor] = [.systemBlue, .systemBrown, .systemPink, .systemOrange]
    
    func configureWith(module: Dashboard.Module) {
        switch module {
        default:
            let tile = ReusableTile()
            tile.backgroundColor = Self.colors[Int.random(in: 0..<4)]
            tile.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(tile)
            tile.activateEqualConstraints(to: self.contentView)
        }
    }
}

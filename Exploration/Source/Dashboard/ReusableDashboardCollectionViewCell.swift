//
//  ReusableDashboardCollectionViewCell.swift
//  Exploration
//
//  Created by Ryan Newlun on 1/30/22.
//

import Foundation
import UIKit

class ReusableDashboardCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ReusableDashboardCollectionViewCell"
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: verticalFittingPriority)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureWith(module: Dashboard.Module) {
        contentView.subviews.first?.removeFromSuperview()
        
        switch module {
        case .single:
            break
            
        case .reusableTile(_):
            let tile = ReusableTile()
            tile.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(tile)
            tile.activateEqualConstraints(to: self.contentView)
        case .module1(_):
            let tile = ReusableTile()
            tile.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(tile)
            tile.activateEqualConstraints(to: self.contentView)
        case .module2(_):
            let tile = ReusableTile()
            tile.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(tile)
            tile.activateEqualConstraints(to: self.contentView)
        case .module3(_):
            let tile = ReusableTile()
            tile.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(tile)
            tile.activateEqualConstraints(to: self.contentView)
        }
    }
}

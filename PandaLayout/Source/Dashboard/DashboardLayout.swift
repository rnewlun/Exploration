//
//  DashboardLayout.swift
//  PandaLayout
//
//  Created by Ryan Newlun on 1/30/22.
//

import Foundation
import UIKit

class DashboardInvalidationContext: UICollectionViewLayoutInvalidationContext {
    var selfSizedIndexPath: IndexPath?
}

class DashboardLayout: UICollectionViewLayout {
    
    // A closure that passes the section index and returns layout information
    typealias SectionLayoutProvider = (Int, UITraitCollection) -> Dashboard.SectionLayout?
    typealias SplitItemLayoutProvider = (IndexPath) -> Dashboard.SplitItemLayout?
    
    override class var invalidationContextClass: AnyClass {
        DashboardInvalidationContext.self
    }
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    private var contentBounds: CGRect = .zero
    
    private let sectionLayoutProvider: SectionLayoutProvider
    private let splitItemLayoutProvider: SplitItemLayoutProvider
    
    private var cache = [IndexPath: UICollectionViewLayoutAttributes]()
    
    init(sectionLayoutProvider: @escaping SectionLayoutProvider, splitItemLayoutProvider: @escaping SplitItemLayoutProvider) {
        self.sectionLayoutProvider = sectionLayoutProvider
        self.splitItemLayoutProvider = splitItemLayoutProvider
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static let interItemSpacing = 8.0
    private static let interSectionSpacing = 24.0
    private static let contentInset = 8.0
    
    private var didOptimizeLayoutForSelfSize = false
    private var newBoundsUpdate: CGRect?
    
    /// Resets the layout and recalculates all estimated sizes.
    /// Make sure to clear the cache and reset the contentBounds.
    override func prepare() {
        guard let collectionView = self.collectionView else { return }
        guard !didOptimizeLayoutForSelfSize else {
            didOptimizeLayoutForSelfSize = false
            return
        }
        
        // Calculate in prepare only the estimated sizes, invalidateWithContext will adjust for real sizes
        
        // For every item in a section, you must determine it's frame - which requires you to
        // determine it's size and origin.
        //
        // Size will be dictated by rules of that section layout.
        //
        // Origin is determined by surrounding items.
        // - For fractional width:
        //   - x origin is half the collection's width - half of the item width
        //     - (collectionWidth / 2) - (itemWidth / 2)
        //  - y origin priority is the maxY of the last frame of a fractional item in it's section,
        //    if not present, otherwise the maxY of the last section frame, otherwise 0.
        // - For split:
        //  - left:
        //    - x origin is always 0
        //    - y origin priority is the maxY of the last left frame item, otherwise the maxY of the last
        //      section frame, otherwise 0.
        //  - right:
        //    - x origin is always half the collection width.
        //    - y origin priority is the maxY of the last right frame item, otherwise the maxY of the last
        //      section frame, otherwise 0.
        
        cache.removeAll()
        contentBounds = .zero
        var frameOfLastSection: CGRect?
        
        for section in 0..<collectionView.numberOfSections {
            var frameOfSection: CGRect = .zero
            var lastFractionalFrame: CGRect?
            var lastLeftFrame: CGRect?
            var lastRightFrame: CGRect?
            
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                guard let layout = sectionLayoutProvider(section, collectionView.traitCollection) else { continue }
                
                let indexPath = IndexPath(item: item, section: section)
                let collectionWidth = collectionView.frame.size.width
                
                // Frame must get set by below switch statement
                let frame: CGRect
                
                switch layout {
                case .fractionalWidth(let multiplier):
                    let targetWidth = collectionWidth * multiplier
                    let estimatedHeight = 24.0
                    let targetXOrigin = (collectionWidth / 2) - (targetWidth / 2)
                    let targetYOrigin = (lastFractionalFrame?.maxY ?? frameOfLastSection?.maxY) ?? .zero
                    
                    let origin = CGPoint(x: targetXOrigin, y: targetYOrigin)
                    let size = CGSize(width: targetWidth, height: estimatedHeight)
                    frame = CGRect(origin: origin, size: size)
                    
                    lastFractionalFrame = frame
                    
                case .split:
                    guard let splitItemLayout = splitItemLayoutProvider(indexPath) else { continue }
                    
                    switch splitItemLayout {
                    case .left:
                        let targetWidth = collectionWidth / 2
                        let estimatedHeight = 60.0
                        let targetXOrigin = 0.0
                        let targetYOrigin = (lastLeftFrame?.maxY ?? frameOfLastSection?.maxY) ?? .zero
                        
                        let origin = CGPoint(x: targetXOrigin, y: targetYOrigin)
                        let size = CGSize(width: targetWidth, height: estimatedHeight)
                        frame = CGRect(origin: origin, size: size)
                        
                        lastLeftFrame = frame
                        
                    case .right:
                        let targetWidth = collectionWidth / 2
                        let estimatedHeight = 60.0
                        let targetXOrigin = targetWidth
                        let targetYOrigin = (lastRightFrame?.maxY ?? frameOfLastSection?.maxY) ?? .zero
                        
                        let origin = CGPoint(x: targetXOrigin, y: targetYOrigin)
                        let size = CGSize(width: targetWidth, height: estimatedHeight)
                        frame = CGRect(origin: origin, size: size)
                        
                        lastRightFrame = frame
                    }
                }
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache[indexPath] = attributes
                contentBounds = contentBounds.union(frame)
                frameOfSection = frameOfSection.union(frame)
            }
            frameOfLastSection = frameOfSection
        }
    }
    
    /// Provides the layout attributes for all the elements in a given viewport.
    /// - Parameter rect: The viewport the collectionview is requesting attributes for.
    /// - Returns: An array of attributes for visible items in the viewport.
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let visibleAttributes = cache
            .filter { $0.value.frame.intersects(rect) }
            .map { $0.value }
        return visibleAttributes
    }
    
    /// Provides the layout attributes for an element at a given index path.
    /// - Parameter indexPath: The index path the collectionview is requesting attributes for.
    /// - Returns: Attributes for a single item at the specified index path.
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    /// Collection view asks the layout if it should be invalidated for a self-sizing cell.
    /// - Parameters:
    ///   - preferredAttributes: The attributes a self-sizing cell is requesting.
    ///   - originalAttributes: The original attributes that was calculated for the cell (also known as the estimated attributes).
    /// - Returns: A boolean value indicating if the layout should invalidate.
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        return preferredAttributes.size != originalAttributes.size
    }
    
    /// Provides an object that contains information for updating the layout after a self-sizing cell's request to invalidate was honored.
    /// - Parameters:
    ///   - preferredAttributes: The attributes a self-sizing cell is requesting.
    ///   - originalAttributes: The original attributes that was calculated for the cell (also known as the estimated attributes).
    /// - Returns: An invalidation context that contains information to be leveraged in performing this specific invalidation.
    override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        let defaultContext = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        guard let context = defaultContext as? DashboardInvalidationContext,
              let collectionView = self.collectionView else {
                  return defaultContext
              }
        
        let invalidatedIndexPath = preferredAttributes.indexPath
        
        // Save invalidated height index path on context
        context.selfSizedIndexPath = invalidatedIndexPath
        
        // Save invalidated index paths below current one that should have origin adjusted
        // Rules for invalidating index paths' heights:
        // if fractional width item, all items below this one and all items in below sections need Y origin adjustment
        // if split
        //   if left
        //     all left items below need updated
        //   if right
        //     all right items below need updated
        //   need to keep track of the frame for each split section to know if we need to
        //   extend the section frame and cause below sections to adjust if we do, adjust all items in all below sections
        
        guard let layout = sectionLayoutProvider(invalidatedIndexPath.section, collectionView.traitCollection) else {
            return context
        }
        
        var indexes = [IndexPath]()
        indexes.append(invalidatedIndexPath)
        
        switch layout {
        case .fractionalWidth(_):
            // get the rest of the items in this section
            for item in invalidatedIndexPath.item+1..<collectionView.numberOfItems(inSection: invalidatedIndexPath.section) {
                indexes.append(IndexPath(item: item, section: invalidatedIndexPath.section))
            }
            // get all items in all further sections
            for section in invalidatedIndexPath.section+1..<collectionView.numberOfSections {
                for item in 0..<collectionView.numberOfItems(inSection: section) {
                    indexes.append(IndexPath(item: item, section: section))
                }
            }
            
        case .split:
            guard let splitItemLayout = splitItemLayoutProvider(invalidatedIndexPath) else {
                return context
            }
            
            switch splitItemLayout {
            case .left:
                // get items in this section that are left aligned
                for item in invalidatedIndexPath.item+1..<collectionView.numberOfItems(inSection: invalidatedIndexPath.section) {
                    let indexPath = IndexPath(item: item, section: invalidatedIndexPath.section)
                    let itemLayout = splitItemLayoutProvider(indexPath)
                    if itemLayout == .left {
                        indexes.append(indexPath)
                    }
                }
                // TODO: Determine if we need to invalidate sections below us
                
            case .right:
                // get items in this section that are right aligned
                for item in invalidatedIndexPath.item+1..<collectionView.numberOfItems(inSection: invalidatedIndexPath.section) {
                    let indexPath = IndexPath(item: item, section: invalidatedIndexPath.section)
                    let itemLayout = splitItemLayoutProvider(indexPath)
                    if itemLayout == .right {
                        indexes.append(indexPath)
                    }
                }
                // TODO: Determine if we need to invalidate sections below us
            }
        }
        
        context.invalidateItems(at: Array(indexes))
        
        // Save new contentSize height adjustment to context (difference between original and preferred, positive grows negative shrinks)
        context.contentSizeAdjustment = CGSize(width: 0, height: preferredAttributes.size.height - originalAttributes.size.height)
        return context
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        guard let dashboardContext = context as? DashboardInvalidationContext else {
            super.invalidateLayout(with: context)
            return
        }
        guard let selfSizedIndexPath = dashboardContext.selfSizedIndexPath else {
            super.invalidateLayout(with: context)
            return
        }
        guard !context.invalidateEverything else {
            didOptimizeLayoutForSelfSize = false
            super.invalidateLayout(with: context)
            return
        }
        
        // Adjust height of attributes for item that self-sized using saved path and context.contentSizeAdjustment.height
        // Update self sized item's height - specifically need to adjust the frame, otherwise the origin shifts.
        cache[selfSizedIndexPath]?.frame.size.height += dashboardContext.contentSizeAdjustment.height
        
        // Iterate over all other affected index paths to adjust their origin y value, using context.invalidatedItemIndexPaths and context.contentSizeAdjustment.height
        // Update all other affected items y origin
        context.invalidatedItemIndexPaths?.forEach({ indexPath in
            if indexPath != selfSizedIndexPath {
                cache[indexPath]?.frame.origin.y += context.contentSizeAdjustment.height
            }
        })
        
        // Adjust contentSize using context.contentSizeAdjustment
        // Update contentBounds height based on self sized item adjustment
        contentBounds.size.height += context.contentSizeAdjustment.height
        
        // Set a flag to bail out of prepare() after this.
        didOptimizeLayoutForSelfSize = true
        super.invalidateLayout(with: context)
    }
}

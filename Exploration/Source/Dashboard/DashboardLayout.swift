//
//  DashboardLayout.swift
//  Exploration
//
//  Created by Ryan Newlun on 1/30/22.
//

import Foundation
import UIKit

class DashboardLayout: UICollectionViewLayout {
    
    typealias SectionTypeProvider = (Int) -> Dashboard.Section?
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    private var contentBounds: CGRect = .zero
    
    private var cache = [IndexPath: UICollectionViewLayoutAttributes]()
    private var preferredSizes = [IndexPath: CGSize]()
    
    private let sectionTypeProvider: SectionTypeProvider
    
    init(sectionTypeProvider: @escaping SectionTypeProvider) {
        self.sectionTypeProvider = sectionTypeProvider
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static let interItemSpacing = 8.0
    private static let interSectionSpacing = 8.0
    
    override func prepare() {
        guard let collectionView = self.collectionView else { return }
        
        var lastFrameInFractionalWidthSection: CGRect?
        var lastFrameInRightSection: CGRect?
        var lastFrameInLeftSection: CGRect?
        
        var lastFrameInCurrentSection: CGRect?
        var lastSectionType: Dashboard.Section?
        
        for section in 0..<collectionView.numberOfSections {
            guard let sectionType = sectionTypeProvider(section) else { return }
            
            switch sectionType {
            case .fractionalWidth(let fraction):
                for item in 0..<collectionView.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    let targetWidth = collectionView.bounds.width * fraction
                    // Use preferred size if found, otherwise use estimated size
                    let size = preferredSizes[indexPath] ?? CGSize(width: targetWidth, height: 50.0)
                    
                    // determine origin for frame
                    let origin: CGPoint
                    
                    if let lastFrame = lastFrameInCurrentSection {
                        // TODO: plus interitem spacing?
                        origin = CGPoint(x: 0.0, y: lastFrame.maxY + Self.interItemSpacing)
                    } else {
                        switch lastSectionType {
                        case nil:
                            origin = CGPoint(x: 0.0, y: 0.0)
                            
                        case .fractionalWidth(let fraction):
                            origin = CGPoint(x: 0.0, y: 0.0)

                        case .leftColumn:
                            origin = CGPoint(x: 0.0, y: 0.0)

                        case .rightColumn:
                            origin = CGPoint(x: 0.0, y: 0.0)

                        case .main:
                            origin = CGPoint(x: 0.0, y: 0.0)
                        }
                    }

                    let frame = CGRect(origin: origin, size: size)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = frame
                    
                    cache[indexPath] = attributes
                    contentBounds = contentBounds.union(frame)
                    lastFrameInFractionalWidthSection = frame
                    lastFrameInCurrentSection = frame
                }
                lastSectionType = sectionType
                lastFrameInCurrentSection = nil
                
            case .leftColumn:
                for item in 0..<collectionView.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    let targetWidth = collectionView.bounds.width / 2
                    // Use preferred size if found, otherwise use estimated size
                    let size = preferredSizes[indexPath] ?? CGSize(width: targetWidth, height: 50.0)
                    
                    // determine origin for frame
                    let origin: CGPoint
                    
                    if let lastFrame = lastFrameInCurrentSection {
                        // TODO: plus interitem spacing?
                        origin = CGPoint(x: lastFrame.minX, y: lastFrame.maxY + Self.interItemSpacing)
                    } else {
                        switch lastSectionType {
                        case nil:
                            origin = CGPoint(x: 0.0, y: 0.0)
                            
                        case .fractionalWidth(let fraction):
                            if let lastFrame = lastFrameInFractionalWidthSection {
                                origin = CGPoint(x: lastFrame.minX, y: lastFrame.maxY + Self.interSectionSpacing)
                            } else {
                                origin = CGPoint(x: 0.0, y: 0.0)
                            }

                        case .leftColumn:
                            origin = CGPoint(x: 0.0, y: 0.0)

                        case .rightColumn:
                            origin = CGPoint(x: 0.0, y: 0.0)

                        case .main:
                            origin = CGPoint(x: 0.0, y: 0.0)
                        }
                    }
                    
                    let frame = CGRect(origin: origin, size: size)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = frame
                    
                    cache[indexPath] = attributes
                    contentBounds = contentBounds.union(frame)
                    lastFrameInLeftSection = frame
                    lastFrameInCurrentSection = frame
                }
                lastSectionType = sectionType
                lastFrameInCurrentSection = nil
                
            case .rightColumn:
                for item in 0..<collectionView.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    let targetWidth = collectionView.bounds.width / 2
                    // Use preferred size if found, otherwise use estimated size
                    let size = preferredSizes[indexPath] ?? CGSize(width: targetWidth, height: 50.0)
                    
                    // determine origin for frame
                    let origin: CGPoint
                    
                    if let lastFrame = lastFrameInCurrentSection {
                        // TODO: plus interitem spacing?
                        origin = CGPoint(x: lastFrame.minX, y: lastFrame.maxY + Self.interItemSpacing)
                    } else {
                        switch lastSectionType {
                        case nil:
                            origin = CGPoint(x: targetWidth, y: 0.0)
                            
                        case .fractionalWidth(let fraction):
                            if let lastFrame = lastFrameInFractionalWidthSection {
                                origin = CGPoint(x: targetWidth, y: lastFrame.maxY + Self.interSectionSpacing)
                            } else {
                                origin = CGPoint(x: 0.0, y: 0.0)
                            }

                        case .leftColumn:
                            if let lastFrame = lastFrameInLeftSection {
                                origin = CGPoint(x: targetWidth, y: lastFrame.minY)
                            } else {
                                origin = CGPoint(x: 0.0, y: 0.0)
                            }
                        case .rightColumn:
                            origin = CGPoint(x: 0.0, y: 0.0)

                        case .main:
                            origin = CGPoint(x: 0.0, y: 0.0)
                        }
                    }
                    
                    let frame = CGRect(origin: origin, size: size)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = frame
                    
                    cache[indexPath] = attributes
                    contentBounds = contentBounds.union(frame)
                    lastFrameInRightSection = frame
                    lastFrameInCurrentSection = frame
                }
                lastSectionType = sectionType
                lastFrameInCurrentSection = nil
                
            case .main:
                break
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
            // Loop through the cache and look for items in the rect
            for (_, attributes) in cache {
                if attributes.frame.intersects(rect) {
                    visibleLayoutAttributes.append(attributes)
                }
            }
            return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        return preferredAttributes.size != originalAttributes.size
    }
        
    override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        let context = UICollectionViewLayoutInvalidationContext()
        let invalidatedIndexPath = preferredAttributes.indexPath
        
        context.invalidateItems(at: [invalidatedIndexPath])
        
        self.preferredSizes[invalidatedIndexPath] = preferredAttributes.size
        return context
    }
    
    
}

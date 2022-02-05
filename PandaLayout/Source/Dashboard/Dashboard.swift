//
//  Dashboard.swift
//  Exploration
//
//  Created by Ryan Newlun on 1/30/22.
//

import Foundation
import UIKit

struct Dashboard {
    
    struct LayoutInfo {
        /// Defines the optimal, wholistic picture of section order based on size class
        static func getPreferredSectionOrder(forTraitCollection traitCollection: UITraitCollection) -> [SemanticSection] {
            switch traitCollection.horizontalSizeClass {
            case .regular:
                return [.header, .mainWalletSplit, .footer]
            default:
                return [.header, .mainWalletSplit, .footer]

//                return [.header, .mainWalletNonSplit, .footer]
            }
        }
        
        /// Maps a module to a semantic section
        static func getPreferredSection(forModule module: Dashboard.Module, usingTraitCollection traitCollection: UITraitCollection) -> SemanticSection {
            
            switch module {
            case .greeting(_):
                return .header
            case .wallet(_):
                return .mainWalletSplit
            case .snapshot(_):
                return .header
            case .disclosures(_):
                return .footer
            }
            
//            switch traitCollection.horizontalSizeClass {
//            case .regular:
//                switch module {
//                case .greeting(_):
//                    return .header
//                case .wallet(_):
//                    return .mainWalletSplit
//                case .snapshot(_):
//                    return .header
//                case .disclosures(_):
//                    return .footer
//                }
//            default:
//                return .header
//            }
        }
    }
    
    /// Semantic name for sections
    enum SemanticSection: Int, CaseIterable {
        case header
        case mainWalletNonSplit
        case mainWalletSplit
        case footer
    }
    
    /// Layout info for a section
    enum SectionLayout {
        
        enum SplitAlignment: Hashable {
            case left
            case right
        }
        
        case fractionalWidth(Double)
        case split
    }
    
    enum SplitItemLayout {
        case left
        case right
    }
    
    /// Semantic name for modules
    enum Module: Hashable {
        case greeting(ViewModels.GreetingViewModel)
        case wallet(ViewModels.WalletViewModel)
        case snapshot(ViewModels.SnapshotViewModel)
        case disclosures(ViewModels.DisclosuresViewModel)
    }
    
    /// Raw modules from DPS eligibility
    enum DPSModule {
        case greeting
        case wallet
        case snapshot
        case disclosures
    }
}

struct ViewModels {
    struct GreetingViewModel: Hashable {}
    struct WalletViewModel: Hashable {
        let accountID: Int
    }
    struct SnapshotViewModel: Hashable {}
    struct DisclosuresViewModel: Hashable {}
}

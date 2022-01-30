//
//  Dashboard.swift
//  Exploration
//
//  Created by Ryan Newlun on 1/30/22.
//

import Foundation

struct Dashboard {
    
    enum Section: Hashable {
        case main
        case fractionalWidth(Double)
        case leftColumn
        case rightColumn
    }
    
    enum Module: Hashable {
        case single
        case reusableTile(Int)
        case module1(Int)
        case module2(Int)
        case module3(Int)
    }
}

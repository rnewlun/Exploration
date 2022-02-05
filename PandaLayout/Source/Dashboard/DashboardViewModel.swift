//
//  DashboardViewModel.swift
//  Exploration
//
//  Created by Ryan Newlun on 1/30/22.
//

import Foundation
import Combine

class DashboardViewModel {
    
    var modulesPublisher: AnyPublisher<[Dashboard.Module], Never> {
        $modules.eraseToAnyPublisher()
    }
    
    @Published private var modules = [Dashboard.Module]()
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let greeting = Dashboard.Module.greeting(.init())
            let walletOne = Dashboard.Module.wallet(.init(accountID: 123))
            let walletTwo = Dashboard.Module.wallet(.init(accountID: 456))
            let snapshot = Dashboard.Module.snapshot(.init())
            let disclosures = Dashboard.Module.disclosures(.init())
            self.modules = [greeting, walletOne, walletTwo, snapshot, disclosures]
        }
    }
}

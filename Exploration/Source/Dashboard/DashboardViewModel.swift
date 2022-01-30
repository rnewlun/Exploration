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
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0, execute: {
            self.modules = [.reusableTile(0)]
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0, execute: {
            self.modules = [.reusableTile(0), .reusableTile(1)]
        })
        DispatchQueue.global().asyncAfter(deadline: .now() + 3.0, execute: {
            self.modules = [.reusableTile(0), .reusableTile(1), .reusableTile(2)]
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 4.0, execute: {
            self.modules = [.reusableTile(0), .reusableTile(1), .reusableTile(2), .module1(1), .module2(1), .module3(1)]
        })
    }
}

//
//  UIView+Extensions.swift
//  PandaLayout
//
//  Created by Ryan Newlun on 1/30/22.
//

import Foundation
import UIKit

extension UIView {
    func activateEqualConstraints(to view: UIView) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

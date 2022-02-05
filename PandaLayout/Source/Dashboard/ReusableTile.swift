//
//  ReusableTile.swift
//  PandaLayout
//
//  Created by Ryan Newlun on 1/30/22.
//

import Foundation
import UIKit

class ReusableTile: UIView {
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.addArrangedSubview(primaryLabel)
        view.addArrangedSubview(secondaryLabel)
        return view
    }()
    
    private lazy var primaryLabel: UILabel = {
        let view = UILabel()
        view.text = "Primary label"
        return view
    }()
    
    private lazy var secondaryLabel: UILabel = {
        let view = UILabel()
        view.text = "Secondary label"
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        self.addSubview(stackView)
    }
    
    private func configureConstraints() {
        stackView.activateEqualConstraints(to: self)
    }
}

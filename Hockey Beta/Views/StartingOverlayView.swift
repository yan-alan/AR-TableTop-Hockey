//
//  StartingOverlayView.swift
//  Hockey Beta
//
//  Created by Alan Yan on 2020-05-17.
//  Copyright © 2020 Alan Yan. All rights reserved.
//

import UIKit
import AlanYanHelpers

class StartingOverlayView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    var hockeyNeonImageView = ContentFitImageView(image: #imageLiteral(resourceName: "hockeyStart"))
    
    var hostButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 4
        button.addCorners(10).done()
        button.setTitle("Host", for: .normal)
        button.titleLabel?.font = UIFont(name: "DS-Digital", size: 46)
        return button
    }()
    
    var joinButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 4
        button.addCorners(10).done()
        button.setTitle("Join", for: .normal)
        button.titleLabel?.font = UIFont(name: "DS-Digital", size: 46)
        return button
    }()
    
    func setupView() {
        hockeyNeonImageView.setSuperview(self).addTop(constant: 30).addLeading(constant: 20).addTrailing(constant: -20).addBottom(anchor: centerYAnchor, constant: 10).done()
        
        hostButton.setSuperview(self).addTop(anchor: hockeyNeonImageView.bottomAnchor, constant: 20).addLeading(constant: 20).addTrailing(constant: -20).addHeight(withConstant: 60).done()
        
        joinButton.setSuperview(self).addTop(anchor: hostButton.bottomAnchor, constant: 5).addLeading(constant: 20).addTrailing(constant: -20).addHeight(withConstant: 60).done()
        
    }
}

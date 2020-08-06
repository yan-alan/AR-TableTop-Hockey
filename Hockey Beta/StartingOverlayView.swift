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
        addSubview(hockeyNeonImageView)
        addSubview(hostButton)
        addSubview(joinButton)
        hockeyNeonImageView.translatesAutoresizingMaskIntoConstraints = false
        hockeyNeonImageView.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        hockeyNeonImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        hockeyNeonImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        hockeyNeonImageView.bottomAnchor.constraint(equalTo: centerYAnchor, constant: 10).isActive = true

        hostButton.translatesAutoresizingMaskIntoConstraints = false
        hostButton.topAnchor.constraint(equalTo: hockeyNeonImageView.bottomAnchor, constant: 20).isActive = true
        hostButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        hostButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        hostButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 10).isActive = true
        joinButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        joinButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        joinButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}

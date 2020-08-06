//
//  ControlsView.swift
//  Hockey Beta
//
//  Created by Alan Yan on 2020-05-17.
//  Copyright © 2020 Alan Yan. All rights reserved.
//

import UIKit
import AlanYanHelpers

class ControlsView: UIView {
    
    var headLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Controls"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    var subLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 5
        label.text = "Tap and Drag Player.\nUp and Down moves player.\nLeft and Right rotates.\nDrag in crease moves Goalie."
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "xmark")?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .normal)
        button.imageView?.addConstraints(padding: 5).done()
        return button
    }()
    var imageView = ContentFitImageView(image: #imageLiteral(resourceName: "controls"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setupView() {
        
        addCorners(10).setColor(.overlayBG).done()
        headLabel.setSuperview(self).addLeading(constant: 10).addTrailing(constant: -10).addTop(constant: 10).addHeight(withConstant: 25).done()
        
        subLabel.setSuperview(self).addTop(anchor: headLabel.bottomAnchor, constant: 10).addLeading(constant: 10).addTrailing(constant: -10).addHeight(withConstant: 80).done()
        
        imageView.setSuperview(self).addTop(anchor: subLabel.bottomAnchor, constant: 10).addLeading(constant: 10).addTrailing(constant: -10).addBottom(constant: -10).done()
        
        closeButton.setSuperview(self).addCenterY(anchor: topAnchor, constant: 20).addCenterX(anchor: trailingAnchor, constant: -20).addWidth(withConstant: 30).addHeight(withConstant: 30).addCorners(15).done()
    }
}

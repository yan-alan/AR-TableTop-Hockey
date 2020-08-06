//
//  CountdownView.swift
//  Hockey Beta
//
//  Created by Alan Yan on 2020-05-16.
//  Copyright © 2020 Alan Yan. All rights reserved.
//

import UIKit

class CountdownView: UIView {
    
    var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Starting Game In"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    var numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "5"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupView() {
        addCorners(15).setColor(UIColor(hex: 0x202020)).done()
        
        countLabel.setSuperview(self).addTop(constant: 15).addLeading(constant: 10).addTrailing(constant: -10).done()
        
        numberLabel.setSuperview(self).addCenterX().addCenterY().done()
    }
}

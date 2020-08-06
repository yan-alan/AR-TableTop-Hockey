//
//  NetView.swift
//  Hockey Beta
//
//  Created by Alan Yan on 2020-05-16.
//  Copyright © 2020 Alan Yan. All rights reserved.
//

import UIKit
import AlanYanHelpers


class NetView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var borderedView: UIView = {
        let view = UIView()
        return view
    }()
    var fingerFollower: UIView = {
        let view = UIView(frame: CGRect(x: 60, y: 45, width: 30, height: 30))
        view.backgroundColor = .white
        view.addCorners(15).done()
        return view
    }()
    func setupView() {
        backgroundColor = .systemBlue
        
        borderedView.setSuperview(self).addCenterY(anchor: bottomAnchor, constant: 0).addWidth(anchor: widthAnchor, constant: 0).addHeight(anchor: widthAnchor, constant: 0).addCorners(75).done()
        borderedView.layer.borderWidth = 2
        borderedView.layer.borderColor = UIColor.red.cgColor
        
        fingerFollower.setSuperview(self).done()
    }
    
    override func layoutSubviews() {
        layer.masksToBounds = true
        clipsToBounds = true
        let circlePath = UIBezierPath.init(arcCenter: CGPoint(x: bounds.size.width / 2, y: bounds.size.height), radius: bounds.size.height, startAngle: .pi, endAngle: 2 * .pi, clockwise: true)
        let circleShape = CAShapeLayer()
        circleShape.path = circlePath.cgPath
        layer.mask = circleShape
    }
}

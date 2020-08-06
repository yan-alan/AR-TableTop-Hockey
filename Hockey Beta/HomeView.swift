//
//  HomeView.swift
//  dsfsdf
//
//  Created by Alan Yan on 2020-03-03.
//  Copyright © 2020 Alan Yan. All rights reserved.
//

import UIKit
import AlanYanHelpers
import RealityKit

class HomeView: ARView {    
    var startingMenuOverlay = StartingOverlayView()
    var countView = CountdownView()
    var controlsOverlay = ControlsView()
    var bottomView = UIView()
    var sliderOne = SliderView(minX: -0.41, maxX: -0.07)
    var sliderTwo = SliderView(minX: 0.07, maxX: 0.42)
    var sliderThree = SliderView(minX: -0.27, maxX: -0.057)
    var sliderFour = SliderView(minX: 0.07, maxX: 0.42)
    var sliderFive = SliderView(minX: -0.40, maxX: -0.057)
    var hStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    var controlsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .overlayBG
        button.addCorners(10).done()
        button.setTitle("Controls", for: .normal)
        button.addTarget(self, action: #selector(showControlsOverlay), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    let TOP_VIEW_HEIGHT: CGFloat = 40
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override init(frame frameRect: CGRect, cameraMode: ARView.CameraMode, automaticallyConfigureSession: Bool) {
        super.init(frame: frameRect, cameraMode: cameraMode, automaticallyConfigureSession: automaticallyConfigureSession)
        setupView()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    
    var topLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Waiting for opponent..."
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    var eventLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blue
        label.text = "GOAL!"
        label.textAlignment = .center
        label.font = UIFont(name: "DS-Digital", size: 65)
        label.isHidden = true
        return label
    }()
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .overlayBG
        view.addCorners(10).done()
        topLabel.setSuperview(view).addConstraints(padding: 10).done()
        return view
    }()
    var netView = NetView()
    
    private func setupView() {
        sliderOne.tag = 1
        sliderTwo.tag = 2
        sliderThree.tag = 3
        sliderFour.tag = 4
        sliderFive.tag = 5
        
        bottomView.setSuperview(self).addBottomSafe(constant: 0).addLeft().addRight().addTop(anchor: centerYAnchor).done()

        hStackView.setSuperview(bottomView).addTop(constant: 10).addBottom(constant: -10).addLeading(constant: 50).addTrailing(constant: -50).done()
        hStackView.userDefinedConstraintDict["trailing"]?.priority = UILayoutPriority(800)
        hStackView.userDefinedConstraintDict["leading"]?.priority = UILayoutPriority(800)
        let constraint = hStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 250)
        constraint.priority = UILayoutPriority(1000)
        constraint.isActive = true
        hStackView.addArrangedSubview(sliderOne)
        hStackView.addArrangedSubview(sliderTwo)
        hStackView.addArrangedSubview(sliderThree)
        hStackView.addArrangedSubview(sliderFour)
        hStackView.addArrangedSubview(sliderFive)
        
        netView.setSuperview(bottomView).addBottom(constant: -25).addCenterX().addWidth(withConstant: 150).addHeight(withConstant: 75).done()
        
        sliderTwo.translatesAutoresizingMaskIntoConstraints = false
        sliderTwo.heightAnchor.constraint(equalTo: hStackView.heightAnchor, multiplier: 0.7).isActive = true
        sliderFour.translatesAutoresizingMaskIntoConstraints = false
        sliderFour.heightAnchor.constraint(equalTo: hStackView.heightAnchor, multiplier: 0.7).isActive = true
        sliderThree.translatesAutoresizingMaskIntoConstraints = false
        sliderThree.heightAnchor.constraint(equalTo: hStackView.heightAnchor, multiplier: 0.6).isActive = true
        bottomView.isHidden = true
        startingMenuOverlay.setSuperview(self).addConstraints(padding: 0).done()
        
        topView.setSuperview(self).addTopSafe(constant: 5).addLeading(constant: 10).addTrailing(constant: -10).addHeight(withConstant: 0).done()
        
        countView.setSuperview(self).addCenterY().addCenterX().addHeight(withConstant: frame.height > 300 ? 300 : frame.height-50).addWidth(withConstant: frame.width > 300 ? 300 : frame.width-50).done()
        countView.isHidden = true
        
        controlsOverlay.setSuperview(self).addCenterY().addCenterX().addHeight(withConstant: 0).addWidth(withConstant: 0).done()
        controlsOverlay.closeButton.addTarget(self, action: #selector(hideControlsOverlay), for: .touchUpInside)
        
        controlsButton.setSuperview(self).addTop(anchor: topView.bottomAnchor, constant: 10).addTrailing(constant: -10).addWidth(withConstant: 80).addHeight(withConstant: 40).done()
        
        eventLabel.setSuperview(self).addCenterX().addCenterY().done()
    }
    
    func hideStartingUI() {
        UIView.animate(withDuration: 0.3, animations: {
            self.startingMenuOverlay.alpha = 0
        }) { (_) in
            self.startingMenuOverlay.isHidden = true
        }
    }
    
    func showTopView(withText text: String = "") {
        topLabel.text = text
        DispatchQueue.main.async {
            self.topView.userDefinedConstraintDict["height"]?.constant = self.TOP_VIEW_HEIGHT
            UIView.animate(withDuration: 0.4) {
                self.layoutIfNeeded()
            }
        }
    }
    func hideTopView() {
        DispatchQueue.main.async {
            self.topView.userDefinedConstraintDict["height"]?.constant = 0
            UIView.animate(withDuration: 0.4) {
                self.layoutIfNeeded()
            }
        }
    }
    
    func startCountdown() {
        countView.isHidden = false
        countView.alpha = 0
        var count = 5
        UIView.animate(withDuration: 0.3) {
            self.countView.alpha = 1
        }
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            count -= 1
            self.countView.numberLabel.text = String(count)
            if count == 0 {
                timer.invalidate()
            }
        }
    }
    func hideCountdown() {
        UIView.animate(withDuration: 0.3, animations: {
            self.countView.alpha = 0
        }) { (error) in
            self.countView.isHidden = true
        }
    }
    @objc func showControlsOverlay() {
        self.controlsOverlay.alpha = 0
        self.controlsOverlay.isHidden = false
        controlsOverlay.userDefinedConstraintDict["height"]!.constant = frame.height > 400 ? 400 : frame.height-50
        controlsOverlay.userDefinedConstraintDict["width"]!.constant = frame.width > 300 ? 300 : frame.width-50
        UIView.animate(withDuration: 0.5, animations: {
            self.controlsOverlay.alpha = 1
            self.layoutIfNeeded()
        })
    }
    @objc func hideControlsOverlay() {
        controlsOverlay.userDefinedConstraintDict["height"]?.constant = 0
        controlsOverlay.userDefinedConstraintDict["width"]?.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.controlsOverlay.alpha = 0
            self.layoutIfNeeded()
        }) { (error) in
            self.controlsOverlay.isHidden = true
        }
    }
    func showControls() {
        self.bottomView.alpha = 0
        self.bottomView.isHidden = false
        self.controlsButton.isHidden = false
        self.controlsButton.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomView.alpha = 1
            self.controlsButton.alpha = 1
        })
    }
    
    func hideControls() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomView.alpha = 0
            self.controlsButton.alpha = 0
        }) { (error) in
            self.controlsButton.isHidden = true
            self.bottomView.isHidden = true
        }
    }
    
    func showEventLabel(isRed: Bool?) {
        if let isRed = isRed {
            eventLabel.textColor = isRed ? .red : .blue
        } else {
            eventLabel.textColor = .white
        }
        eventLabel.alpha = 1
        eventLabel.isHidden = false
        eventLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.4, animations: {
            self.eventLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.eventLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.6, animations: {
                self.eventLabel.alpha = 0
            }) { _ in
                self.eventLabel.isHidden = true
            }
        }
    }
    func runGoalAnimation(isRed: Bool) {
        eventLabel.text = "GOAL!"
        showEventLabel(isRed: isRed)
    }
    func runWinnerAnimation(isRed: Bool) {
        eventLabel.text = "\(isRed ? GameManager.shared.redName: GameManager.shared.blueName) WON!"
        showEventLabel(isRed: isRed)
    }
    
    
    override func layoutSubviews() {
        if controlsOverlay.userDefinedConstraintDict["height"]!.constant != 0 {
            controlsOverlay.userDefinedConstraintDict["height"]!.constant = frame.height > 400 ? 400 : frame.height-50
            controlsOverlay.userDefinedConstraintDict["width"]!.constant = frame.width > 300 ? 300 : frame.width-50
        }
        countView.userDefinedConstraintDict["height"]!.constant = frame.height > 300 ? 300 : frame.height-50
        countView.userDefinedConstraintDict["width"]!.constant = frame.width > 300 ? 300 : frame.width-50
    }
}


//MARK: - Slider View -
class SliderView: UIView {
    var minX: CGFloat = 0.0
    var maxX: CGFloat = 0.0
    var range: CGFloat {
        get {
            return maxX - minX
        }
    }
    var bottomRatio: CGFloat = 0.0
    var isValidGesture: Bool = false
    var circularButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = false
        button.layer.masksToBounds = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "blue-helmet"), for: .normal)
        return button
    }()
    
    var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCorners(1).done()
        return view
    }()
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    convenience init(minX: CGFloat, maxX: CGFloat) {
        self.init(frame: .zero)
        self.minX = minX
        self.maxX = maxX
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    func setRange(min: CGFloat, max: CGFloat) {
        self.minX = min
        self.maxX = max
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        lineView.setSuperview(self).addCenterX().addTop().addBottom().addWidth(withConstant: 2).done()
        circularButton.setSuperview(self).addCenterX().addWidth(withConstant: 50).addHeight(withConstant: 50).addCorners(20).addCenterY(anchor: bottomAnchor, constant: -25).done()
    }
    
    override func layoutSubviews() {
        circularButton.userDefinedConstraintDict["centerY"]?.constant = -1*(((frame.height-50) * bottomRatio) + 25)
    }
}

//
//  PhysicalProperties.swift
//  Hockey Beta
//
//  Created by Alan Yan on 2020-05-12.
//  Copyright © 2020 Alan Yan. All rights reserved.
//

import UIKit
import RealityKit
class GameManager {
    static let shared = GameManager()
    
    let TEXT_MATERIAL = [SimpleMaterial(color: .green, isMetallic: false)]
    let PLAYER_WEIGHT: Float = 0.001
    let FRICTION: Float = 10.0
    let RESTITUTION: Float = 1.0
    let CENTER_OF_MASS = SIMD3<Float>(-1.4606446e-06, 0.10069214, -1.4972419e-09)
    let PERIOD_LENGTH = 1*60
    var arView: HomeView!
    var period = 0 {
        didSet {
            timeLeftInPeriod = PERIOD_LENGTH
        }
    }
    var redName = "RED"
    var blueName = "BLU"
    var redScore = 0 {
        didSet {
            let textModelComponent: ModelComponent = ModelComponent(mesh: .generateText(String(self.redScore),
            extrusionDepth: 0.01,
            font: UIFont(name: "DS-Digital", size: 0.10)!,
            containerFrame: CGRect.zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail), materials: TEXT_MATERIAL)
            for i in 1...4 {
                guard let item = arView.scene.findEntity(named: "Red Score \(i)") else { continue }
                item.children[0].children[0].components.set(textModelComponent)
                item.children[0].children[0].components.set(textModelComponent)
                item.children[0].children[0].components.set(textModelComponent)
                item.children[0].children[0].components.set(textModelComponent)
            }
        }
    }
    var blueScore = 0 {
        didSet {
            let textModelComponent: ModelComponent = ModelComponent(mesh: .generateText(String(self.blueScore),
            extrusionDepth: 0.01,
            font: UIFont(name: "DS-Digital", size: 0.10)!,
            containerFrame: CGRect.zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail), materials: TEXT_MATERIAL)
            for i in 1...4 {
                guard let item = arView.scene.findEntity(named: "Blue Score \(i)") else { continue }
                item.children[0].children[0].components.set(textModelComponent)
                item.children[0].children[0].components.set(textModelComponent)
                item.children[0].children[0].components.set(textModelComponent)
                item.children[0].children[0].components.set(textModelComponent)
            }
        }
    }
    var timeLeftInPeriod = 0 {
        didSet {
            DispatchQueue.main.async {
                self.setJumbotronTime()
            }
        }
    }
    
    func getStringForCurrentTime() -> String {
        let minutes = timeLeftInPeriod/60
        let seconds = timeLeftInPeriod % 60
        var string = (minutes < 10) ? "0\(minutes):" : "\(minutes):"
        
        string.append(contentsOf: (seconds < 10) ? "0\(seconds)" : "\(seconds)")
        
        return string
    }
    
    
    func setJumbotronPeriod(period: Int) {
        let textModelComponent: ModelComponent = ModelComponent(mesh: .generateText(String(period),
        extrusionDepth: 0.01,
        font: UIFont(name: "DS-Digital", size: 0.05)!,
        containerFrame: CGRect.zero,
        alignment: .center,
        lineBreakMode: .byTruncatingTail), materials: TEXT_MATERIAL)

        
        for i in 1...4 {
            guard let item = arView.scene.findEntity(named: "Period \(i)") else { continue }
            item.children[0].children[0].components.set(textModelComponent)
            item.children[0].children[0].components.set(textModelComponent)
            item.children[0].children[0].components.set(textModelComponent)
            item.children[0].children[0].components.set(textModelComponent)
        }
    }
    
    func setJumbotronTime() {
        let textModelComponent: ModelComponent = ModelComponent(mesh: .generateText(getStringForCurrentTime(),
        extrusionDepth: 0.01,
        font: UIFont(name: "DS-Digital", size: 0.11)!,
        containerFrame: CGRect.zero,
        alignment: .center,
        lineBreakMode: .byTruncatingTail), materials: TEXT_MATERIAL)
        
        for i in 1...4 {
            guard let item = arView.scene.findEntity(named: "Time \(i)") else { continue }
            item.children[0].children[0].components.set(textModelComponent)
            item.children[0].children[0].components.set(textModelComponent)
            item.children[0].children[0].components.set(textModelComponent)
            item.children[0].children[0].components.set(textModelComponent)
        }
    }
    
    
    func setTeamName(isRed: Bool = false) {
        var name = ""
        if isRed {
            name = redName
        } else {
            name = blueName
        }
        let textModelComponent: ModelComponent = ModelComponent(mesh: .generateText(name,
        extrusionDepth: 0.01,
        font: UIFont(name: "DS-Digital", size: 0.04)!,
        containerFrame: CGRect.zero,
        alignment: .center,
        lineBreakMode: .byTruncatingTail), materials: TEXT_MATERIAL)
        
        for i in 1...4 {
            guard let item = arView.scene.findEntity(named: "\(isRed ? "Red" : "Blue") Label \(i)") else { continue }
            item.children[0].children[0].components.set(textModelComponent)
            item.children[0].children[0].components.set(textModelComponent)
            item.children[0].children[0].components.set(textModelComponent)
            item.children[0].children[0].components.set(textModelComponent)
        }
    }
    
  
}

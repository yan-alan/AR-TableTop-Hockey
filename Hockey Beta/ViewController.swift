//
//  ViewController.swift
//  dsfsdf
//
//  Created by Alan Yan on 2020-02-29.
//  Copyright © 2020 Alan Yan. All rights reserved.
//

import UIKit
import RealityKit
import MultipeerConnectivity
import ARKit
import simd

class ViewController: UIViewController {
    
    var arView: HomeView!
    var validTrans = true
    var boxAnchor: Experience.Box!
    
    var LLPiece: SliderView!
    var LPiece: SliderView!
    var MPiece: SliderView!
    var RPiece: SliderView!
    var RRPiece: SliderView!

    
    var currentPiece: (Entity & HasPhysics)?
    var currentSlider: SliderView?
    
    var gesture1: UIPanGestureRecognizer!
    var gesture2: UIPanGestureRecognizer!
    var gesture3: UIPanGestureRecognizer!
    var gesture4: UIPanGestureRecognizer!
    var gesture5: UIPanGestureRecognizer!

    var multipeerHelp: MultipeerHelper!
    
    var pieces: [Entity & HasPhysics] = []
    var redPieces: [Entity & HasPhysics] = []
    var pieceRotation: [Float] = [0,0,0,0,0]
    var initialPieces: [SIMD3<Float>] = []
    var isHost: Bool? {
        didSet {
            setupAR()
        }
    }
    
    var gameRunning = false
    
    var isReady: Bool = false {
        didSet {
            if isReady && opponentReady {
                self.arView.hideTopView()
                multipeerHelp.sendToAllPeers("Start Game".data(using: .utf8)!, reliably: true)
            } else {
                self.arView.showTopView(withText: "Waiting for opponent...")
            }
        }
    }
    var opponentReady: Bool = false {
        didSet {
            if isReady && opponentReady {
                self.arView.hideTopView()
                multipeerHelp.sendToAllPeers("Start Game".data(using: .utf8)!, reliably: true)
            }
        }
    }
    var firstTimeCoaching = true
    var validGoal: Bool = true {
        didSet {
            if !validGoal {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.validGoal = true
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        multipeerHelp = MultipeerHelper(
          serviceName: "myservice",
          sessionType: .both
        )
        multipeerHelp.delegate = self
      
        arView = HomeView(frame: self.view.frame, cameraMode: .ar, automaticallyConfigureSession: true)
        LLPiece = arView.sliderOne
        LPiece = arView.sliderTwo
        MPiece = arView.sliderThree
        RPiece = arView.sliderFour
        RRPiece = arView.sliderFive
        
        
        self.view = arView
        GameManager.shared.arView = arView
        for piece in [LLPiece, LPiece, MPiece, RPiece, RRPiece] {
            piece!.circularButton.addTarget(self, action: #selector(sliderClickedDown), for: .touchDown)
        }
        
        gesture1 = UIPanGestureRecognizer(target: self, action: #selector(movePiece))
        gesture2 = UIPanGestureRecognizer(target: self, action: #selector(movePiece))
        gesture3 = UIPanGestureRecognizer(target: self, action: #selector(movePiece))
        gesture4 = UIPanGestureRecognizer(target: self, action: #selector(movePiece))
        gesture5 = UIPanGestureRecognizer(target: self, action: #selector(movePiece))
        let gestureGoalie = UIPanGestureRecognizer(target: self, action: #selector(moveGoalie))
        
        arView.netView.addGestureRecognizer(gestureGoalie)
        arView.sliderOne.addGestureRecognizer(gesture1)
        arView.sliderTwo.addGestureRecognizer(gesture2)
        arView.sliderThree.addGestureRecognizer(gesture3)
        arView.sliderFour.addGestureRecognizer(gesture4)
        arView.sliderFive.addGestureRecognizer(gesture5)
        
        arView.startingMenuOverlay.hostButton.addTarget(self, action: #selector(tappedHost), for: .touchUpInside)
        arView.startingMenuOverlay.joinButton.addTarget(self, action: #selector(tappedJoin), for: .touchUpInside)
        
        Timer.scheduledTimer(withTimeInterval: 1.00, repeats: true) { (timer) in
            guard let isHost = self.isHost, !isHost else {return}
            
            guard let _ = self.arView.scene.findEntity(named: "Red Player 1") as? Entity & HasPhysics, !self.firstTimeCoaching else { return }
            self.setupJoinedPeer()
            timer.invalidate()
        }

        Experience.loadBoxAsync(completion: { (result) in
            self.boxAnchor = try? result.get()
            self.boxAnchor.name = "Hockey Arena"
        })
    }

    //MARK: - Setup -
    func presentCoachingOverlay() {
        let coachingOverlay = ARCoachingOverlayView()

        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self
                
        coachingOverlay.setSuperview(arView!).addConstraints(padding: 0).done()
    }
    
    @objc func tappedHost() {
        let ac = UIAlertController(title: "Enter Team Name", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            guard let answer = ac.textFields?[0].text, answer.count == 3 else {
                return
            }
            self.isHost = true
            GameManager.shared.blueName = answer.uppercased()
            self.multipeerHelp.sendToAllPeers("Blue Name:\(GameManager.shared.redName)".data(using: .utf8)!, reliably: true)
            self.arView.hideStartingUI()
        }

        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    @objc func tappedJoin() {
        
        for slider in [arView.sliderOne, arView.sliderTwo, arView.sliderThree, arView.sliderFour, arView.sliderFive] {
            slider.circularButton.setImage(#imageLiteral(resourceName: "red-helmet"), for: .normal)
        }
        let ac = UIAlertController(title: "Enter Team Name", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            guard let answer = ac.textFields?[0].text, answer.count == 3 else {
                return
            }
            GameManager.shared.redName = answer.uppercased()
            self.multipeerHelp.sendToAllPeers("Red Name:\(GameManager.shared.redName)".data(using: .utf8)!, reliably: true)
            self.arView.hideStartingUI()
            self.isHost = false
        }

        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    private func setupAR() {
         guard let isHost = isHost else { return }
        
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = .horizontal
        arConfiguration.isCollaborationEnabled = true
        
        arView.session.run(arConfiguration)
        arView.session.delegate = self
        arView.scene.synchronizationService = self.multipeerHelp.syncService
        presentCoachingOverlay()
        if !isHost {
            arView.sliderOne.setRange(min: 0.42, max: 0.07)
            arView.sliderTwo.setRange(min: -0.07, max: -0.40)
            arView.sliderThree.setRange(min: 0.28, max: 0.06)
            arView.sliderFour.setRange(min: -0.07, max: -0.40)
            arView.sliderFive.setRange(min: 0.40, max: 0.07)
        }
    }
    
    //Host does this
    private func setupPieces() {
        guard let isHost = isHost, isHost else { return }

        boxAnchor.invisibleWalls?.visit(using: { (entity) in
          entity.visit { (subEntity) in
            subEntity.components[ModelComponent.self] = nil
          }
        })
//      boxAnchor.ch
//      boxAnchor.invisibleWalls?.components[ModelComponent.self] = nil
      
        boxAnchor.actions.goalScored.onAction = { entity in
            guard self.validGoal else { return }
            self.validGoal = false
            if let x = self.boxAnchor.puck?.position.x, x < 0 {
                GameManager.shared.redScore += 1
                self.arView.runGoalAnimation(isRed: true)
                self.multipeerHelp.sendToAllPeers("Red Goal".data(using: .utf8)!, reliably: true)
            } else {
                GameManager.shared.blueScore += 1
                self.arView.runGoalAnimation(isRed: false)
                self.multipeerHelp.sendToAllPeers("Blue Goal".data(using: .utf8)!, reliably: true)
            }
        }
        
        if let piece = boxAnchor.floor as? Entity & HasPhysics {
            piece.physicsBody?.material = PhysicsMaterialResource.generate(friction: GameManager.shared.FRICTION, restitution: GameManager.shared.RESTITUTION)
            piece.synchronization!.ownershipTransferMode = .autoAccept
            piece.physicsBody?.isContinuousCollisionDetectionEnabled = true
            piece.physicsBody?.massProperties.mass = GameManager.shared.PLAYER_WEIGHT * 10
        }
        
        //goalie setup
        guard let redGoalie = boxAnchor.redPlayerGoalie as? Entity & HasPhysics, let blueGoalie = boxAnchor.bluePlayerGoalie as? Entity & HasPhysics else {
            return
        }
        for player in [redGoalie, blueGoalie] {
            player.physicsBody?.material = PhysicsMaterialResource.generate(friction: GameManager.shared.FRICTION, restitution: GameManager.shared.RESTITUTION)
            player.synchronization!.ownershipTransferMode = .autoAccept
            player.physicsBody!.isTranslationLocked.y = true
            player.physicsBody!.isRotationLocked.x = true
            player.physicsBody!.isRotationLocked.z = true
            player.physicsBody?.mode = .kinematic
        }
        
        //player setup
        for i in 1...5 {
            print(i)
            guard let pieceBlue = boxAnchor.findEntity(named: "Blue Player \(i)") as? Entity & HasPhysics else {
                print("couldnt find piece \(i)")
                return
            }
            
            guard let enemyPiece = boxAnchor.findEntity(named: "Red Player \(i)") as? Entity & HasPhysics else {
                print("couldnt find enemy piece \(i)")
                return
            }
            
            for piece in [pieceBlue, enemyPiece] {
                piece.physicsBody?.material = PhysicsMaterialResource.generate(friction: GameManager.shared.FRICTION, restitution: GameManager.shared.RESTITUTION)
                piece.synchronization!.ownershipTransferMode = .autoAccept
//                    piece.physicsBody?.isContinuousCollisionDetectionEnabled = true
                piece.physicsBody?.massProperties.mass = GameManager.shared.PLAYER_WEIGHT
                piece.physicsBody?.massProperties.centerOfMass.position = GameManager.shared.CENTER_OF_MASS
                piece.physicsBody?.massProperties.centerOfMass.orientation = simd_quatf(real: 1.0, imag: SIMD3(0,0,0))
                piece.physicsBody!.isTranslationLocked.z = true
                piece.physicsBody!.isTranslationLocked.y = true
                piece.physicsBody!.isRotationLocked.x = true
                piece.physicsBody!.isRotationLocked.z = true
                piece.physicsBody?.mode = .kinematic
            }
            initialPieces.append(SIMD3(x: pieceBlue.transform.translation.x, y: pieceBlue.transform.translation.y, z: pieceBlue.transform.translation.z))
            redPieces.append(enemyPiece)
            pieces.append(pieceBlue)
            
        }
        pieces.append(blueGoalie)
        redPieces.append(redGoalie)
        arView.scene.addAnchor(boxAnchor)
        setupJumbotron()
        isReady = true
        multipeerHelp.sendToAllPeers("Ready".data(using: .utf8)!, reliably: true)
    }
    
    //for the joinee
    func setupJoinedPeer() {
        for i in 1...5 {
            guard let piece = self.arView.scene.findEntity(named: "Red Player \(i)") as? Entity & HasPhysics else { continue }
            self.pieces.append(piece)
            initialPieces.append(SIMD3(x: piece.transform.translation.x, y: piece.transform.translation.y, z: piece.transform.translation.z))
            setupJumbotron()
            piece.synchronization = nil
        }
        guard let goalie = self.arView.scene.findEntity(named: "Red Player Goalie") as? Entity & HasPhysics else { return }
        self.pieces.append(goalie)
        goalie.synchronization = nil
        self.isReady = true
        self.multipeerHelp.sendToAllPeers("Ready".data(using: .utf8)!, reliably: true)
    }
    
    //MARK: - Player Movement -
    @objc func moveGoalie(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: arView.netView)
        
        guard location.x > 0, location.y > 0, location.y < 45, location.x < 120, pow(75 - location.y, 2.0) + pow(location.x-75, 2) < 2 * pow(60,2) else {
            return
        }
        
        arView.netView.fingerFollower.frame = CGRect(x: location.x, y: location.y, width: 30, height: 30)
        
        let goalie = pieces[5]
        var transform = goalie.transform
        var translatedZ = ((location.x/120) * 0.18) - 0.09
        var translatedX = ((1-(location.y/45)) * 0.09) + (-0.46)
        if let isHost = isHost, !isHost {
            translatedZ *= -1
            translatedX *= -1
        }
        transform.translation.x = Float(translatedX)
        transform.translation.z = Float(translatedZ)
        goalie.move(to: transform, relativeTo: goalie.parent)
        
        if !isHost! {
            multipeerHelp.sendToAllPeers("GOALIE:\(translatedX):\(translatedZ)".data(using: .utf8)!, reliably: true)
        }
    }
    
    @objc func movePiece(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: sender.view)
        guard let isHost = isHost, location.y > -100, let slider = sender.view as? SliderView, slider.isValidGesture, location.y < slider.frame.height + 100  else {
            print("Invalid Gesture")
            return
        }
        
        guard isHost || (!isHost && isReady) else {
            print("NOT PREPPED")
            return
        }
        let player = pieces[slider.tag-1]
        let percentageFilled = ((location.y)/(slider.frame.height))
        var newX = Float(((1-percentageFilled) * slider.range) + slider.minX)

        if(self.validTrans) {
            var transform = player.transform
            let speedX = Float(sender.velocity(in: arView.bottomView).x)/2500
                
            if location.y < 0 {
                newX = Float(slider.range + slider.minX)
            }
            else if location.y > slider.frame.height {
                newX = Float(slider.minX)
            }
            transform.translation.x = newX
            transform.translation.y = initialPieces[slider.tag-1].y
            transform.translation.z = initialPieces[slider.tag-1].z
            
            pieceRotation[slider.tag-1] += speedX
            let new = simd_quatf(angle: pieceRotation[slider.tag-1], axis: SIMD3(x: 0, y: 1, z: 0))
            
            transform.rotation = new
            player.move(to: transform, relativeTo: player.parent)
            if !isHost {
                multipeerHelp.sendToAllPeers("MOVE:\(slider.tag):\(newX):\(pieceRotation[slider.tag-1])".data(using: .utf8)!, reliably: true)
            }
            
        }
        if location.y < 25 {
            slider.circularButton.userDefinedConstraintDict["centerY"]?.constant = -1*slider.frame.height + 25
            slider.bottomRatio = 1
        }
        else if location.y > slider.frame.height - 25 {
            slider.circularButton.userDefinedConstraintDict["centerY"]?.constant = -25
            slider.bottomRatio = 0
        }
        else {
            slider.circularButton.userDefinedConstraintDict["centerY"]?.constant = -1*(slider.frame.height - location.y)
            slider.bottomRatio = 1-((location.y-25)/(slider.frame.height-50))
        }
        slider.circularButton.transform = CGAffineTransform(rotationAngle: CGFloat(pieceRotation[slider.tag-1]))
        self.view.layoutIfNeeded()
        
        
        if (sender.state == .cancelled || sender.state == .ended) {
            print("Gesture ended")
            slider.isValidGesture = false
        }
    }
    @objc func sliderClickedDown(sender: UIButton) {
        guard let sliderSender = sender.superview as? SliderView else {
            return
        }
        print("Gesture allowed")
        sliderSender.isValidGesture = true
    }
    func moveOpponentPiece(index: Int, newX: Float, rotation: Float)  {
        let piece = redPieces[index-1]
        var transform = piece.transform
        transform.translation.x = newX
        let rotation = simd_quatf(angle: rotation, axis: SIMD3(x: 0, y: 1, z: 0))
        transform.rotation = rotation
        piece.move(to: transform, relativeTo: piece.parent)
    }
    func moveOpponentGoalie(newX: Float, newZ: Float) {
        let goalie = redPieces[5]
        var transform = goalie.transform
        transform.translation.x = newX
        transform.translation.z = newZ
        goalie.move(to: transform, relativeTo: goalie.parent)
    }
    func resetPuckPosition() {
        guard let puck = boxAnchor.puck as? Entity & HasPhysics else {
            return
        }
        var transform = puck.transform
        transform.translation = SIMD3(x: 0.0009, y: 0.1626, z: -0.0283)
        transform.rotation = simd_quatf(real: 0, imag: SIMD3(x: 0, y: 0, z: 0))
        puck.physicsBody?.mode = .kinematic
        puck.move(to: transform, relativeTo: puck.parent)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            puck.physicsBody?.mode = .dynamic
        }
    }
    
    
    //MARK: - Error Handling -
    func checkPuckLocation() {
        guard let puck = boxAnchor.puck as? Entity & HasPhysics else {
            return
        }
        puck.physicsBody?.mode = .dynamic
        if puck.transform.translation.y < 0.10 {
            resetPuckPosition()
        }
    }
    
}
//MARK: - GAMEFLOW -
extension ViewController {
    func setName() {
        
    }
    func startGame() {
        if let isHost = isHost, isHost {
            self.boxAnchor.notifications.gameStart.post()
        }
        self.arView.showControls()
        self.gameRunning = true
        self.boxAnchor.notifications.periodStarted.post()
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.isHost! {
                self.checkPuckLocation()
            }
        }
        startPeriod(period: 1, timer: timer)
    }
    func startPeriod(period: Int, timer: Timer) {
        guard let isHost = isHost else { return }
        GameManager.shared.period = period
        GameManager.shared.setJumbotronPeriod(period: period)
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            
            guard self.gameRunning else { return }
            GameManager.shared.timeLeftInPeriod -= 1
            
            if GameManager.shared.timeLeftInPeriod == 0 {
                timer.invalidate()
                self.gameRunning = false
                if isHost {
                    self.boxAnchor.notifications.periodEnded.post()
                }
                if period < 3 {
                    if isHost {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.boxAnchor.notifications.periodStarted.post()
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.gameRunning = true
                        self.startPeriod(period: period + 1, timer: timer)
                    }
                } else {
                    if isHost {
                        if GameManager.shared.redScore >= GameManager.shared.blueScore {
                            self.boxAnchor.notifications.redWin.post()
                        }
                        if GameManager.shared.blueScore >= GameManager.shared.redScore {
                            self.boxAnchor.notifications.blueWin.post()
                        }
                    }
                    if GameManager.shared.redScore > GameManager.shared.blueScore {
                        self.arView.runWinnerAnimation(isRed: true)
                    }
                    else if GameManager.shared.blueScore > GameManager.shared.redScore {
                        self.arView.runWinnerAnimation(isRed: false)
                    } else {
                        self.arView.eventLabel.text = "TIE!"
                        self.arView.showEventLabel(isRed: nil)
                    }
                    timer.invalidate()
                    self.arView.hideControls()
                }
            }
        }
    }
    func setupJumbotron() {
        GameManager.shared.redScore = 0
        GameManager.shared.blueScore = 0
        GameManager.shared.timeLeftInPeriod = 0
        //team names
        GameManager.shared.setTeamName(isRed: false)
        GameManager.shared.setTeamName(isRed: true)
        GameManager.shared.setJumbotronPeriod(period: 0)
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let isHost = isHost, !isHost else {
            return
        }
    }
}
extension ViewController: ARCoachingOverlayViewDelegate {
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        if firstTimeCoaching {
            setupPieces()
            firstTimeCoaching = false
        }
    }
}


extension ViewController: MultipeerHelperDelegate {
    func peerJoined(_ peer: MCPeerID) {
        print("PEER JOINED")
        if isReady {
            multipeerHelp.sendToAllPeers("Ready".data(using: .utf8)!, reliably: true)
        }
        if GameManager.shared.redName != "RED" {
            multipeerHelp.sendToAllPeers("Red Name:\(GameManager.shared.redName)".data(using: .utf8)!, reliably: true)
        }
        if GameManager.shared.blueName != "BLU" {
            multipeerHelp.sendToAllPeers("Blue Name:\(GameManager.shared.blueName)".data(using: .utf8)!, reliably: true)
        }
    }
    func peerLost(_ peer: MCPeerID) {
        print("PEER LOST")
    }
    func shouldSendJoinRequest(_ peer: MCPeerID) -> Bool {
        print("SHOULD SEND JOIN REQUEST")
        
        return true
    }
    func shouldAcceptJoinRequest(peerID: MCPeerID, context: Data?) -> Bool {
        print("SHOULD ACCEPT JOIN REQUEST")
        return true
    }
    func receivedData(_ data: Data, _ peer: MCPeerID) {
        print("RECEIVED DATA")
        
        let string = String(data: data, encoding: .utf8)
        
        DispatchQueue.main.async {
            switch string {
            case "Red Goal":
                //host only sends this
                GameManager.shared.redScore += 1
                self.arView.runGoalAnimation(isRed: true)
            case "Ready":
                self.opponentReady = true
            case "Blue Goal":
                //host only sends this
                GameManager.shared.blueScore += 1
                self.arView.runGoalAnimation(isRed: false)
            case "Start Game":
                if let isHost = self.isHost, isHost {
                    self.boxAnchor.notifications.periodEnded.post()
                }
                self.arView.startCountdown()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.startGame()
                    self.arView.hideCountdown()
                }
            default:
                guard let string = string else {
                    print("NIL MESSAGE")
                    break
                }
                if string.contains("Name") {
                    if string.contains("Blue") {
                        GameManager.shared.blueName = String(string.split(separator: ":").last!)
                        GameManager.shared.setTeamName(isRed: false)
                    } else {
                        GameManager.shared.redName = String(string.split(separator: ":").last!)
                        GameManager.shared.setTeamName(isRed: true)
                    }
                }
                //joinee only sends these
                if string.contains("MOVE") {
                    let elem = string.split(separator: ":")
                    self.moveOpponentPiece(index: Int(elem[1])!, newX: Float(elem[2])!, rotation: Float(elem[3])!)
                }
                if string.contains("GOALIE") {
                    let elem = string.split(separator: ":")
                    self.moveOpponentGoalie(newX: Float(elem[1])!, newZ: Float(elem[2])!)
                }
            }
        }
    }
    
}


struct PieceID: Codable {
    var id: UInt64
    var index: Int
}


extension Entity {
    func visit(using block: (Entity) -> Void) {
        block(self)

        for child in children {
            child.visit(using: block)
        }
    }
}


extension ARView: ARCoachingOverlayViewDelegate {
  func addCoaching() {
    // Create a ARCoachingOverlayView object
    let coachingOverlay = ARCoachingOverlayView()
    // Make sure it rescales if the device orientation changes
    coachingOverlay.autoresizingMask = [
      .flexibleWidth, .flexibleHeight
    ]
    self.addSubview(coachingOverlay)
    // Set the Augmented Reality goal
    coachingOverlay.goal = .horizontalPlane
    // Set the ARSession
    coachingOverlay.session = self.session
    // Set the delegate for any callbacks
    coachingOverlay.delegate = self
  }
  // Example callback for the delegate object
    public func coachingOverlayViewDidDeactivate(
    _ coachingOverlayView: ARCoachingOverlayView
  ) {
    
  }
}

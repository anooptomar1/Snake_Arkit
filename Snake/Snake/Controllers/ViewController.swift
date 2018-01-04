//
//  ViewController.swift
//  Snake
//
//  Created by Onur Celik on 18.12.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum ViewState {
    case searchPlanes
    case selectPlane
    case startGame
    case playing
    case gameOver
}

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var buttonView: UIView!
    
    var state: ViewState = .searchPlanes {
        didSet {
            updateHintView()
            if state == .playing {
                planes.values.forEach { plane in
                    plane.isHidden = true
                }
            } else {
                planes.values.forEach { plane in
                    plane.isHidden = true
                }
            }
        }
    }
    
    var game: Game = Game()
    
    var planes: [ARAnchor: HorizontalPlane] = [:]
    var selectedPlane: HorizontalPlane?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = false
        let scene = SCNScene(named: "arscene.scn")!
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: -1, y: 10, z: 1)
        scene.rootNode.addChildNode(lightNode)
        sceneView.scene = scene
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeft.direction = .left
        sceneView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeRight.direction = .right
        sceneView.addGestureRecognizer(swipeRight)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        game.delegate = self
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if hitResults.count > 0 {
            if let result = hitResults.first, let selectedPlane = result.node as? HorizontalPlane {
                self.selectedPlane = selectedPlane
                state = .startGame
                game.addToNode(rootNode: selectedPlane.parent!)
                game.updateGameSceneForAnchor(anchor: selectedPlane.anchor)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        state = .searchPlanes
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard state == .searchPlanes || state == .selectPlane else {
            return
        }
        
        if let anchor = anchor as? ARPlaneAnchor {
            if state == .searchPlanes {
                state = .selectPlane
            }
            let plane = HorizontalPlane(anchor: anchor)
            planes[anchor] = plane
            node.addChildNode(plane)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor,
            let plane = planes[anchor] {
            plane.update(for: anchor)
            if selectedPlane?.anchor == anchor {
                game.updateGameSceneForAnchor(anchor: anchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            if plane == self.selectedPlane {
                let nextPlane = planes.values.first!
                game.addToNode(rootNode: nextPlane)
                game.updateGameSceneForAnchor(anchor: nextPlane.anchor)
            }
            plane.removeFromParentNode()
        }
    }
    
    func updateHintView() {
        DispatchQueue.main.async {
            switch self.state {
            case .searchPlanes:
                self.hintView.isHidden = false
                self.hintLabel.isHidden = false
                self.buttonView.isHidden = false
                self.startGameButton.isHidden = true
                self.hintLabel.text = "Look at the floor"
            case .selectPlane:
                self.hintView.isHidden = false
                self.hintLabel.isHidden = false
                self.buttonView.isHidden = true
                self.startGameButton.isHidden = true
                self.hintLabel.text = "Select game area"
            case .startGame:
                self.hintView.isHidden = true
                self.hintLabel.isHidden = true
                self.startGameButton.isHidden = false
                self.buttonView.isHidden = false
                self.hintLabel.text = ""
            case .playing:
                self.buttonView.isHidden = true
                self.startGameButton.isHidden = true
                self.hintView.isHidden = true
            case .gameOver:
                self.hintView.isHidden = false
                self.hintLabel.isHidden = false
                self.startGameButton.isHidden = false
                self.buttonView.isHidden = false
                self.hintLabel.text = "Game over :("
            }
        }
    }
    
    @IBAction func startButtonTouched(_ sender: Any) {
        state = .playing
        game.reset()
        game.startGame()
    }
    
    @objc func swipeLeft(_ sender: Any) {
        game.turnLeft()
    }
    
    @objc func swipeRight(_ sender: Any) {
        game.turnRight()
    }
}

extension ViewController: GameDelegate {
    func gameOver(sender: Game) {
        state = .gameOver
    }
}

extension Game {
    func updateGameSceneForAnchor(anchor: ARPlaneAnchor) {
        let worldSize: Float = 30.0
        let minSize = min(anchor.extent.x, anchor.extent.z)
        let scale = minSize / worldSize
        worldSceneNode?.scale = SCNVector3(x: scale, y: scale, z: scale)
        worldSceneNode?.position = SCNVector3(anchor.center)
    }
}

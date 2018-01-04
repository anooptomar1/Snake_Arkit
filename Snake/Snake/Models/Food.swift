//
//  Food.swift
//  Snake
//
//  Created by Onur Celik on 2.01.2018.
//  Copyright © 2018 Onur Celik. All rights reserved.
//

import SceneKit

class Food: SCNNode {
    var foodNode: SCNNode?
    
    
    override init() {
        super.init()
        if let scene = SCNScene(named: "snakeHead.scn"), let foodNode = scene.rootNode.childNode(withName: "snakeHead", recursively: true) {
            addChildNode(foodNode)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func runAppearAnimation() {
        foodNode?.position.y = -1
        removeAllActions()
        removeAllParticleSystems()
        scale = SCNVector3(0.1, 0.1, 0.1)
        
        let scaleAction = SCNAction.scale(to: 1.0, duration: 1.0)
        let removeParticle = SCNAction.run { _ in
            self.removeAllParticleSystems()
        }
        
        let sequence = SCNAction.sequence([scaleAction, removeParticle])
        runAction(sequence)
    }
}

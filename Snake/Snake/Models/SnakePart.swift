//
//  SnakePart.swift
//  Snake
//
//  Created by Onur Celik on 18.12.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import SceneKit

class SnakePart: SCNNode {
    let type: PartType
    
    
    init(pos: int2, type: PartType = .body) {
        self.type = type
        super.init()
        
        switch type {
        case .body:
            if let scene = SCNScene(named: "snakeBody.scn") {
                if let snakeBody = scene.rootNode.childNode(withName: "snakeBody", recursively: true) {
                    addChildNode(snakeBody)
                }
            }
        case .tail:
            if let scene = SCNScene(named: "snakeTail.scn") {
                if let snakeTail = scene.rootNode.childNode(withName: "snakeTail", recursively: true) {
                    addChildNode(snakeTail)
                }
            }
        case .head:
            if let scene = SCNScene(named: "snakeHead.scn") {
                if let snakeHead = scene.rootNode.childNode(withName: "snakeHead", recursively: true) {
                    addChildNode(snakeHead)
                }
            }
        }
        position = SCNVector3(Float(pos.x), Float(0.5), Float(pos.y))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum PartType: Int {
    case head
    case body
    case tail
}

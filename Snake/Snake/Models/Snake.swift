//
//  Snake.swift
//  Snake
//
//  Created by Onur Celik on 18.12.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import SceneKit

enum SnakeDirection: Int {
    case up
    case right
    case down
    case left
    
    var direction: int2 {
        switch self {
        case .up:
            return int2(x: 0, y: 1)
        case .right:
            return int2(x: 1, y: 0)
        case .down:
            return int2(x: 0, y: -1)
        case .left:
            return int2(x: -1, y: 0)
        }
    }
}

class Snake: SCNNode {
    var snakeDirection: SnakeDirection = .down
    
    var headPos: int2 {
        return body.first!
    }
    
    var body: [int2] = [int2(0, 0), int2(0, 1), int2(0, 2)]
    var lastBodyPart: int2?
    var nodes: [SnakePart] = []
    

    override init() {
        super.init()
        reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func reset() {
        snakeDirection = .down
        body = [int2(0, 0), int2(0, 1), int2(0, 2), int2(0, 3)]
        
        nodes.forEach {
            $0.removeFromParentNode()
        }
        
        nodes = []
        
        for i in body {
            if i == body.first {
                nodes += [SnakePart(pos: i, type: .head)]
            } else if i == body.last {
                nodes += [SnakePart(pos: i, type: .tail)]
            } else {
                nodes += [SnakePart(pos: i)]
            }
        }
        
        nodes.forEach { (node) in
            addChildNode(node)
        }
        
        updateNodes()
    }
    
    func turnLeft() {
        let t = (snakeDirection.rawValue + 1) % 4
        snakeDirection = SnakeDirection(rawValue: t)!
    }
    
    func turnRight() {
        let t = (snakeDirection.rawValue - 1 + 4) % 4
        snakeDirection = SnakeDirection(rawValue: t)!
    }
    
    func move() {
        let p = body.first!
        var newBody = [int2(x: p.x + snakeDirection.direction.x, y: p.y + snakeDirection.direction.y)]
        lastBodyPart = body.removeLast()
        newBody.append(contentsOf: body)
        body = newBody
        updateNodes()
    }
    
    func canMove(sceneSize: Int) -> Bool {
        let maxPos = Int(sceneSize / 2)
        return abs(headPos.x) <= maxPos && abs(headPos.y) <= maxPos
    }
    
    var ateItself: Bool {
        for (i, pos) in body.enumerated() {
            if pos == body.first! && i > 0 {
                return true
            }
        }
        return false
    }
    
    func grow() {
        guard let lastBodyPart = lastBodyPart else {
            return
        }
        body += [lastBodyPart]
        let newNode = SnakePart(pos: lastBodyPart)
        addChildNode(newNode)
        nodes += [newNode]
        self.lastBodyPart = nil
        updateNodes()
    }
    
    func updateNodes() {
        nodes = nodes.sorted {
            return $0.type.rawValue < $1.type.rawValue
        }
        for (i, node) in nodes.enumerated() {
            let pos = body[i]
            node.position = SCNVector3(Float(pos.x), Float(0.5), Float(pos.y))
        }
        updateHeadNode()
        updateTailNode()
    }
    
    fileprivate func updateHeadNode() {
        if let headNode = nodes.first {
            switch snakeDirection {
            case .right:
                headNode.eulerAngles.y = Float.pi / 2
            case .left:
                headNode.eulerAngles.y = -Float.pi / 2
            case .up:
                headNode.eulerAngles.y = 0
            case .down:
                headNode.eulerAngles.y = -Float.pi
            }
        }
    }
    
    fileprivate func updateTailNode() {
        if let tailNode = nodes.last, let tailPos = body.last {
            let beforeTailPos = body[body.count - 2]
            let dV = int2(beforeTailPos.x - tailPos.x, beforeTailPos.y - tailPos.y)
            if dV.x == 1 {
                tailNode.eulerAngles.y = Float.pi / 2
            } else if dV.x == -1 {
                tailNode.eulerAngles.y = -Float.pi / 2
            }
            
            if dV.y == 1 {
                tailNode.eulerAngles.y = 0
            } else if dV.y == -1 {
                tailNode.eulerAngles.y = Float.pi
            }
        }
    }
}

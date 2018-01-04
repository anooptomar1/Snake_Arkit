//
//  Game.swift
//  Snake
//
//  Created by Onur Celik on 18.12.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import SceneKit

protocol GameDelegate: class {
    func gameOver(sender: Game)
}

class Game {
    private let sceneSize = 15
    private var timer: Timer!

    public var worldSceneNode: SCNNode?
    private var pointsNode: SCNNode?
    private var pointsText: SCNText?
    
    var snake: Snake = Snake()
    
    private var points: Int = 0
    private var foodNode: Food
    private var foodPosition: int2 = int2(0, 0)
    private var gameOver: Bool = false
    
    weak var delegate: GameDelegate?
    
    
    init() {
        if let worldScene = SCNScene(named: "worldScene.scn") {
            worldSceneNode = worldScene.rootNode.childNode(withName: "worldScene", recursively: true)
            worldSceneNode?.removeFromParentNode()
            worldSceneNode?.addChildNode(snake)
            pointsNode = worldSceneNode?.childNode(withName: "pointsText", recursively: true)
            pointsNode?.pivot = SCNMatrix4MakeTranslation(5, 0, 0)
            pointsText = pointsNode?.geometry as? SCNText
        }
        foodNode = Food()
    }

    func reset() {
        gameOver = false
        points = 0
        snake.reset()
        worldSceneNode?.addChildNode(foodNode)
        placeFood()
    }
    
    func startGame() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateSnake), userInfo: nil, repeats: true)
    }
    
    @objc func updateSnake(timer: Timer) {
        if snake.canMove(sceneSize: sceneSize) {
            snake.move()
            if snake.ateItself || !snake.canMove(sceneSize: sceneSize) {
                gameOver = true
                delegate?.gameOver(sender: self)
                timer.invalidate()
            }
            if snake.headPos == foodPosition {
                snake.grow()
                placeFood()
            }
        } else {
            delegate?.gameOver(sender: self)
        }
        updatePoints(points: "\(snake.body.count - 4)")
    }
    
    func turnRight() {
        snake.turnRight()
    }
    
    func turnLeft() {
        snake.turnLeft()
    }
    
    func addToNode(rootNode: SCNNode) {
        guard let worldScene = worldSceneNode else {
            return
        }
        worldScene.removeFromParentNode()
        rootNode.addChildNode(worldScene)
        worldScene.scale = SCNVector3(0.1, 0.1, 0.1)
    }
    
    private func updatePoints(points: String) {
        guard let pointsNode = pointsNode else {
            return
        }
        pointsText?.string = points
        let width = pointsNode.boundingBox.max.x - pointsNode.boundingBox.min.x
        pointsNode.pivot = SCNMatrix4MakeTranslation(width / 2, 0, 0)
        pointsNode.position.x = -1.222
        pointsNode.position.y = 0.844
        pointsNode.position.z = -11.013
    }
    
    private func placeFood() {
        repeat {
            let x = Int32(arc4random() % UInt32((sceneSize - 1))) - 7
            let y = Int32(arc4random() % UInt32((sceneSize - 1))) - 7
            foodPosition = int2(x, y)
        } while snake.body.contains(foodPosition)
        
        foodNode.position = SCNVector3(Float(foodPosition.x), 0, Float(foodPosition.y))
        foodNode.runAppearAnimation()
    }
}

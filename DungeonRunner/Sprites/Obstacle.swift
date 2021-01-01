//
//  Obstacle.swift
//  DungeonRunner
//
//  Created by Barak on 12/30/20.
//

import Cocoa
import SpriteKit

class Obstacle: SKSpriteNode {
    
    private let obstacleTexture1 = SKTexture(imageNamed: "obstacle1")
    private let obstacleTexture2 = SKTexture(imageNamed: "obstacle2")
    
    var obstacleSpeed: Double!
    var waitTime: Double!
    
    init(texture: SKTexture, color: NSColor, size: CGSize, obstacleSpeed: Double) {
        
        super.init(texture: texture, color: color, size: size)
        
        self.obstacleSpeed = obstacleSpeed
        configurePhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func moveObstacle(viewSize: CGSize, getNextObject: @escaping()->()){
        
//        let startX = (viewSize.width / 2) + (CGFloat.random(in: 0...30))
        let startX = (viewSize.width / 2) + 20
        let startPosition = CGPoint(x: startX, y: -7.5)
        let endPosition = CGPoint(x: -viewSize.width / 2, y: -7.5)
        
        position = startPosition
//        speed = CGFloat(viewSize.width/(startX + 349))

        switch Int.random(in: 0...1){
        case 0:
            texture = obstacleTexture1
        case 1:
            texture = obstacleTexture2
        default:
            break
            
        }
        
        run(SKAction.wait(forDuration: waitTime)) {
            
            [unowned self] in
            
            self.run(SKAction.sequence([SKAction.move(to: endPosition, duration: TimeInterval(obstacleSpeed)), SKAction.removeFromParent()]))
            getNextObject()
            
        }
    }
    
}

extension Obstacle: SKPhysicsContactDelegate{
    func configurePhysics(){
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width - 5, height: size.height - 4))
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategories.obstacle
        physicsBody?.contactTestBitMask = PhysicsCategories.joe
        physicsBody?.collisionBitMask = PhysicsCategories.none
    }
}

//
//  Orc.swift
//  DungeonRunner
//
//  Created by Barak on 12/30/20.
//

import Cocoa
import SpriteKit

//Very similair to obstacle class
class Orc: SKSpriteNode {
    
    //Orc animation frames
    private var orcFrames: [SKTexture] = []
    
    var orcSpeed: Double!
    var waitTime: Double!
    
    init(texture: SKTexture, color: NSColor, size: CGSize, orcSpeed: Double) {
        
        super.init(texture: texture, color: color, size: size)
        
        self.orcFrames = getAnimationTextures(baseString: "orc", numImages: 6)        
        self.orcSpeed = orcSpeed
        
        configurePhysics()
        startSwinging()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Orc animation
    func startSwinging(){
        let animate = SKAction.animate(with: orcFrames, timePerFrame: 0.2)
        let forever = SKAction.repeatForever(SKAction.sequence([animate, SKAction.wait(forDuration: 1)]))
        run(forever, withKey: AnimationKeys.walkingAnimationKey)
    }
    
    func moveOrc(viewSize: CGSize, getNextObject: @escaping()->()){
        
        let startX = (viewSize.width / 2) + 20
        let startPosition = CGPoint(x: startX, y: 6)
        let endPosition = CGPoint(x: -viewSize.width/2, y: 6)
        
        position = startPosition
        
        run(SKAction.wait(forDuration: waitTime)) { [unowned self] in
            self.run(SKAction.sequence([SKAction.move(to: endPosition, duration: TimeInterval(orcSpeed)), SKAction.removeFromParent()]))
            getNextObject()
        }
    }
    
}

extension Orc: SKPhysicsContactDelegate{
    func configurePhysics(){
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height - 2))
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategories.orc
        physicsBody?.contactTestBitMask = PhysicsCategories.joe
        physicsBody?.collisionBitMask = PhysicsCategories.none
    }
}

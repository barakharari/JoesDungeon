//
//  Joe.swift
//  DungeonRunner
//
//  Created by Barak on 12/30/20.
//

import Cocoa
import SpriteKit

class Joe: SKSpriteNode {
    
    private var joeWalkingFrames: [SKTexture] = []
    private var joeJumpingFrames: [SKTexture] = []
    private var joeCrouchingFrames: [SKTexture] = []
    
    init(texture: SKTexture, color: NSColor, size: CGSize) {
        
        super.init(texture: texture, color: color, size: size)
        
        joeWalkingFrames = getAnimationTextures(baseString: "walk", numImages: 4)
        joeJumpingFrames = getAnimationTextures(baseString: "jump", numImages: 4)
        joeCrouchingFrames = getAnimationTextures(baseString: "crouch", numImages: 6)
        
        configurePhysics(area: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func startWalking(){
        let animate = SKAction.animate(with: joeWalkingFrames, timePerFrame: 0.2)
        let forever = SKAction.repeatForever(animate)
        run(forever, withKey: AnimationKeys.walkingAnimationKey)
    }
    
    
    func jump(completion: @escaping(()->())){
        
        let jumpUpAction = SKAction.moveBy(x: 0, y: 12, duration: 0.1)
        let stayAction = SKAction.moveBy(x: 0, y: 0, duration: 0.4)
        let jumpDownAction = SKAction.moveBy(x: 0, y: -12, duration: 0.1)
        let jumpSequence = SKAction.sequence([jumpUpAction, stayAction, jumpDownAction])

        let animate = SKAction.animate(with: joeJumpingFrames, timePerFrame: 0.2)
        
        configurePhysics(area: CGSize(width: size.width, height: size.height - 2))
        
        removeAction(forKey: AnimationKeys.walkingAnimationKey)
        
        run(animate)
        run(jumpSequence) {
            //Reenable interaction
            completion()
        }
    }
    
    func crouch(completion: @escaping(()->())){
        
        let animate = SKAction.animate(with: joeCrouchingFrames, timePerFrame: 0.13)
        
        configurePhysics(area: CGSize(width: size.width, height: 2))
        
        removeAction(forKey: AnimationKeys.crouchingAnimationKey)
        
        run(animate) {
            completion()
            
            self.configurePhysics(area: self.size)
        }
        
    }
    
}

extension Joe: SKPhysicsContactDelegate{
    func configurePhysics(area: CGSize){
        physicsBody = SKPhysicsBody(rectangleOf: area)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategories.joe
        physicsBody?.contactTestBitMask = PhysicsCategories.obstacle
        physicsBody?.collisionBitMask = PhysicsCategories.none
    }
}

//
//  Joe.swift
//  DungeonRunner
//
//  Created by Barak on 12/30/20.
//

import Cocoa
import SpriteKit

class Joe: SKSpriteNode {
    
    //All of the animation frames
    private var joeWalkingFrames: [SKTexture] = []
    private var joeJumpingFrames: [SKTexture] = []
    private var joeCrouchingFrames: [SKTexture] = []
    
    
    //Set frames and configure physics
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
    
    //Run walking animation
    func startWalking(){
        let animate = SKAction.animate(with: joeWalkingFrames, timePerFrame: 0.2)
        let forever = SKAction.repeatForever(animate)
        run(forever, withKey: AnimationKeys.walkingAnimationKey)
    }
    
    //Jump animation sequence, on completion walking animation will be reenabled and buttons will be active
    func jump(completion: @escaping(()->())){
        
        //Position sequence
        let jumpUpAction = SKAction.moveBy(x: 0, y: 12, duration: 0.12)
        let stayAction = SKAction.moveBy(x: 0, y: 0, duration: 0.23)
        let jumpDownAction = SKAction.moveBy(x: 0, y: -12, duration: 0.12)
        let jumpSequence = SKAction.sequence([jumpUpAction, stayAction, jumpDownAction])

        let animate = SKAction.animate(with: joeJumpingFrames, timePerFrame: 0.3)
        
        //Set height to be less
        configurePhysics(area: CGSize(width: size.width, height: size.height - 2))
        
        run(animate)
        run(jumpSequence) {completion()}
    }
    
    func crouch(completion: @escaping(()->())){
        
        let animate = SKAction.animate(with: joeCrouchingFrames, timePerFrame: 0.07)
        
        //Make sure contact box height is reduced
        configurePhysics(area: CGSize(width: size.width, height: 2))
        
        run(animate) { [unowned self] in
            //Make sure physics is back to normal with crouch
            self.configurePhysics(area: self.size)
            completion()
        }
    }
    
}

//Set physics masks
extension Joe: SKPhysicsContactDelegate{
    func configurePhysics(area: CGSize){
        physicsBody = SKPhysicsBody(rectangleOf: area)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategories.joe
        physicsBody?.contactTestBitMask = PhysicsCategories.obstacle
        physicsBody?.collisionBitMask = PhysicsCategories.none
    }
}

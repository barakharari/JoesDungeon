//
//  GameScene.swift
//  DungeonRunner
//
//  Created by Barak on 12/29/20.
//

import SpriteKit
import GameplayKit
import AVFoundation

struct AnimationKeys{
    static let walkingAnimationKey = "joeWalkingAnimationKey"
    static let crouchingAnimationKey = "joeCrouchingAnimationKey"
    static let obstacleKey = "obstacleKey"
    static let torchKey = "torchKey"
    static let orcKey = "orcKey"
}

struct PhysicsCategories{
    static let none : UInt32 = 0
    static let joe : UInt32 = 1
    static let obstacle : UInt32 = 2
    static let orc: UInt32 = 4
}

class GameScene: SKScene {
    
    deinit {
        print("removed from parent")
    }
    
    weak var parentVC: GameViewController!
    var internalScore = 0 {
        didSet{
            if let vc = parentVC.parentVC{
                vc.scoreTextField.stringValue = "Score: \(internalScore)"
            }
        }
    }
    var effectPlayer = AVAudioPlayer()
    var endGame:Bool = false
    var startedGame:Bool = false
    
    override var acceptsFirstResponder: Bool {get {return true}}
    
    var joe:Joe!
    let floorNode = SKSpriteNode(imageNamed: "Floor")
    let backgroundNode = SKSpriteNode(imageNamed: "Wall")
        
    var backGroundSpeed = 6
    
    private var startX:CGFloat!
    private var endX:CGFloat!
    private var viewSize: CGSize!

    private var torchFrames: [SKTexture] = []
    
    override func didMove(to view: SKView) {
        
        isUserInteractionEnabled = true
        
        //Set sizing variables
        startX = (view.bounds.width / 2)
        endX = -(view.bounds.width / 2)
        
        viewSize = view.frame.size
        
        //Get animation frames
        torchFrames = getAnimationTextures(baseString: "torch", numImages: 8)
        
        //Add scene children: joe/background/midline/floor
        setSceneChildren()
        
        //Set physics settings and contact delegate
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

    }

    //Configure sizing/positions, and addChildren to the scene
    func setSceneChildren(){
        
        joe = Joe(texture: SKTexture(imageNamed: "walk1"), color: NSColor.white, size: CGSize(width: 14, height: 16))
        joe.position = CGPoint(x: ((-viewSize.width) / 4), y: ((-viewSize.height) / 2) + 10)
        joe.zPosition = 1
                                        
        backgroundNode.size = CGSize(width: viewSize.width * 2, height: viewSize.height)
        floorNode.size = CGSize(width: viewSize.width * 2, height: viewSize.height / 3)
        floorNode.zPosition = backgroundNode.zPosition + 1
        
        let midLine = SKSpriteNode(color: NSColor.black, size: CGSize(width: viewSize.width, height: 2))
        midLine.position = CGPoint(x: startX, y: joe.position.y - 2)
        floorNode.position = CGPoint(x: 0, y: midLine.position.y - (viewSize.height / 6))
        backgroundNode.position = CGPoint(x: startX, y: 0)
        
        addChild(floorNode)
        addChild(backgroundNode)
        addChild(midLine)
        addChild(joe)
    }
    
    
    func startGame(){
        
        effectPlayer.stop()
        
        //Play music
        if (!parentVC.parentVC.mainSoundPlayer.isPlaying){
            parentVC.parentVC.playSound(path: Bundle.main.path(forResource: "music", ofType: "m4a")!)
        }
        
        
        //New game
        endGame = false
        
        //Start score count
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.startinternalScoreCount()
        }
                
        //Start walking animation
        joe.startWalking()
        
        //Start moving things
        sceneMoveAnimation()

    }
    
    func sceneMoveAnimation(){
        
        //Background animation
        let timeToMove = TimeInterval(backGroundSpeed)
        let backgroundMove = SKAction.moveTo(x: endX, duration: timeToMove)
        let resetBackground = SKAction.moveTo(x: startX, duration: 0)
        //Torches animation
        spawnAndMoveTorches()
        
        //Move setting
        backgroundNode.run(SKAction.repeatForever(SKAction.sequence([backgroundMove,resetBackground])))
        floorNode.run(SKAction.repeatForever(SKAction.sequence([backgroundMove,resetBackground])))
        floorNode.run(SKAction.repeatForever(SKAction.sequence([SKAction.run(self.spawnAndMoveObstaclesAndOrcs), SKAction.wait(forDuration: 2)])), withKey: AnimationKeys.obstacleKey)
        
    }
    
    func spawnAndMoveObstaclesAndOrcs(){
        
        switch Int.random(in: 0...1){
        case 0:
            let obstacle:Obstacle = Obstacle(texture: SKTexture(imageNamed: "obstacle1"), color: .white, size: CGSize(width: 10, height: 10), obstacleSpeed: 10)
            obstacle.zPosition = floorNode.zPosition + 1
            addChild(obstacle)
            obstacle.moveObstacle(viewSize:viewSize)
            break
        case 1:
            let orc:Orc = Orc(texture: SKTexture(imageNamed: "orc1"), color: .white, size: CGSize(width: 13, height: 13), orcSpeed: 10)
            orc.zPosition = floorNode.zPosition + 1
            addChild(orc)
            orc.moveOrc(viewSize:viewSize)
            break
        default:
            break
        }
        

    }
    
    func spawnAndMoveTorches(){
        for i in 1...2{
            
            let xPosition:Double = Double(backgroundNode.size.width) * Double(i / 2)

            let torch:SKSpriteNode = SKSpriteNode(imageNamed: "torch1")
            torch.position = CGPoint(x: CGFloat(xPosition), y: backgroundNode.size.height / 4)
            torch.zPosition = backgroundNode.zPosition + 1
            backgroundNode.addChild(torch)
            
            let animate = SKAction.animate(with: torchFrames, timePerFrame: 0.2)
            let forever = SKAction.repeatForever(animate)
            torch.run(forever, withKey: AnimationKeys.torchKey)
        }
        
    }

    //Continuous score increment
    func startinternalScoreCount(){
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [unowned self] (t) in
            if (self.endGame == true) {self.endTimer(timer:t)}
            self.internalScore += 1
        })
    }
    
    func endTimer(timer: Timer){
        timer.invalidate()
    }

}


    //Button events
extension GameScene {
    
    func internalJump(sender: NSButton?){
        
        //Start game by jumping once
        if (!startedGame){
            startedGame = true
            self.startGame()
        }
        
        playSound(path: Bundle.main.path(forResource: "jump", ofType: "mp3")!)
        
        joe.jump { [unowned self] in
            if let sender = sender{
                sender.isEnabled = true
            }
            self.joe.startWalking()
        }
        
    }
    
    func internalCrouch(sender: NSButton?){
        
        playSound(path: Bundle.main.path(forResource: "crouch", ofType: "mp3")!)
        
        joe.crouch { [unowned self] in
            if let sender = sender{
                sender.isEnabled = true
            }
            self.joe.startWalking()
        }
        
    }
}

    //Physics
extension GameScene: SKPhysicsContactDelegate{
    
    func didBegin(_ contact: SKPhysicsContact) {

      var firstBody: SKPhysicsBody
      var secondBody: SKPhysicsBody
      if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
      } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
      }
     
      if ((firstBody.categoryBitMask & PhysicsCategories.joe != 0) &&
          (secondBody.categoryBitMask & PhysicsCategories.obstacle != 0)) {
        if let _ = firstBody.node as? SKSpriteNode,
          let _ = secondBody.node as? SKSpriteNode {
            gameOver()
        }
      }  else if ((firstBody.categoryBitMask & PhysicsCategories.joe != 0) && (secondBody.categoryBitMask & PhysicsCategories.orc != 0)) {
          if let _ = firstBody.node as? SKSpriteNode,
            let _ = secondBody.node as? SKSpriteNode {
              gameOver()
          }
        }
    }
    
    func gameOver() {
        
        //Make sure the sounds play
        parentVC.parentVC.mainSoundPlayer.stop()
        effectPlayer.stop()
        parentVC.parentVC.upButton.isEnabled = false
        parentVC.parentVC.downButton.isEnabled = false
                
        endGame = true
        parentVC.parentVC.replayButton.isHidden = false
        

        let newHighScore = setHighScore()
        
        removeAllActions()
        backgroundNode.removeAllActions()
        floorNode.removeAllActions()
        removeAllChildren()
        
        let scoreLabel = SKLabelNode()
        if (newHighScore){
            
            scoreLabel.text = "Score: \(internalScore + 1)"
            parentVC.parentVC.playSound(path: Bundle.main.path(forResource: "lose", ofType: "mp3")!)
            
        } else{
            
            playSound(path: Bundle.main.path(forResource: "woohoo", ofType: "m4a")!)
            
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.25)
            let scaleDown = SKAction.scaleX(to: 1, duration: 0.25)
            
            scoreLabel.text = "New High Score!!!"
            
            scoreLabel.run(SKAction.repeat(SKAction.sequence([scaleUp, scaleDown]), count: 15))
            
        }
        
        scoreLabel.fontName = "EastSeaDokdo-Regular"
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = goldColor
        scoreLabel.position = CGPoint(x: 0, y: -view!.frame.height/4)
        
        addChild(scoreLabel)
        
    }
    
    func setHighScore() -> Bool{
        let highscore = UserDefaults.standard.value(forKey: "highscore") as! Int
        if (internalScore + 1 > highscore){
            UserDefaults.standard.setValue(internalScore + 1, forKey: "highscore")
            parentVC.parentVC.highScoreTextField.stringValue = "Highscore: \(internalScore + 1)"
            return true
        }
        return false
        
    }
    
    func playSound(path: String){
        do{
            effectPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            effectPlayer.play()
        } catch{
            print(error)
        }
    }
    
    func resetGame(){
        removeAllChildren()
        setSceneChildren()
        internalScore = 0
        startGame()
    }

}

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
    

    private var torchFrames: [SKTexture] = []
    weak var parentVC: GameViewController!

    var worldNode:SKNode!
    var scoreLabel: SKLabelNode!
    var joe:Joe!
    var floorNode:SKSpriteNode!
    var backgroundNode:SKSpriteNode!

    var effectPlayer = AVAudioPlayer()
    var endGame:Bool = false
    var startedGame:Bool = false
    var movementSpeed:Double = 8
    var waitTimeRange:ClosedRange<Double>!
    
    var internalScore = 0 {
        didSet{
            if let vc = parentVC.parentVC{
                vc.scoreTextField.stringValue = "Score: \(internalScore)"
            }
        }
    }
        
    override func didMove(to view: SKView) {
        
        //Get animation frames
        torchFrames = getAnimationTextures(baseString: "torch", numImages: 8)
        

        //Set physics settings and contact delegate
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        //Put children on
        setSceneChildren()

    }

    //Configure sizing/positions, and addChildren to the scene
    func setSceneChildren(){
        
        worldNode = SKNode()
        
        //Set sizing variables
        let startX = view!.frame.width / 2
        let viewSize = view!.frame.size
        
        joe = Joe(texture: SKTexture(imageNamed: "walk1"), color: NSColor.white, size: CGSize(width: 14, height: 16))
        joe.position = CGPoint(x: ((-viewSize.width) / 4), y: ((-viewSize.height) / 2) + 10)
        joe.zPosition = 1
        
        let midLine = SKSpriteNode(color: NSColor.black, size: CGSize(width: viewSize.width, height: 2))
        midLine.position = CGPoint(x: startX, y: joe.position.y - 2)
        
        backgroundNode = SKSpriteNode(imageNamed: "Wall")
        backgroundNode.size = CGSize(width: viewSize.width * 2, height: viewSize.height)
        backgroundNode.position = CGPoint(x: startX, y: 0)
        
        floorNode = SKSpriteNode(imageNamed: "Floor")
        floorNode.size = CGSize(width: viewSize.width * 2, height: viewSize.height / 3)
        floorNode.position = CGPoint(x: startX, y: midLine.position.y - (viewSize.height / 6))
        floorNode.zPosition = backgroundNode.zPosition + 1
        
        worldNode.position = CGPoint(x: 0, y: 0)
        
        worldNode.addChild(backgroundNode)
        worldNode.addChild(floorNode)
        worldNode.addChild(midLine)

        addChild(worldNode)
        addChild(joe)
        
        //Torches animation
        spawnAndMoveTorch()
    }
    
    
    func startGame(){
        
        //New game
        endGame = false
        self.movementSpeed = 8
        self.waitTimeRange = 1.5...2.0
        
        //Make sure no effects are playing
        effectPlayer.stop()
        
        //Play music
        if (!parentVC.parentVC.mainSoundPlayer.isPlaying){
            parentVC.parentVC.playSound(path: Bundle.main.path(forResource: "music", ofType: "m4a")!, numberOfLoops: 20)
        }
        
        //Start score count
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.startinternalScoreCount()
        }
                
        //Start walking animation
        joe.startWalking()
        
        //Background start moving
        let backgroundMove = SKAction.moveTo(x: -(backgroundNode.frame.width/2), duration: 5)
        let resetBackground = SKAction.moveTo(x: 0, duration: 0)
        worldNode.run(SKAction.repeatForever(SKAction.sequence([backgroundMove,resetBackground])))
        
        //Start moving things
        spawnAndMoveObstaclesAndOrcs()

    }

    func spawnAndMoveObstaclesAndOrcs(){
        
        guard (!endGame) else {return}

        if (self.movementSpeed > 3) {self.movementSpeed -= 0.03}
        
        if (self.waitTimeRange.lowerBound > 0.5){
            
            let lowerBound = waitTimeRange.lowerBound - 0.01
            let upperBound = waitTimeRange.upperBound - 0.01
            
            waitTimeRange = lowerBound...upperBound
        }
        
        let waitTime = Double.random(in: waitTimeRange)
        
        switch Int.random(in: 0...1){
        case 0:
            let obstacle:Obstacle = Obstacle(texture: SKTexture(imageNamed: "obstacle1"), color: .white, size: CGSize(width: 10, height: 10), obstacleSpeed: self.movementSpeed / 2)
            obstacle.zPosition = floorNode.zPosition + 1
            obstacle.waitTime = waitTime
            addChild(obstacle)
            obstacle.moveObstacle(viewSize:view!.frame.size, getNextObject: spawnAndMoveObstaclesAndOrcs)
            break
        case 1:
            let orc:Orc = Orc(texture: SKTexture(imageNamed: "orc1"), color: .white, size: CGSize(width: 13, height: 13), orcSpeed: self.movementSpeed / 2)
            orc.zPosition = floorNode.zPosition + 1
            orc.waitTime = waitTime
            addChild(orc)
            orc.moveOrc(viewSize:view!.frame.size, getNextObject: spawnAndMoveObstaclesAndOrcs)
            break
        default:
            break
        }
        

    }
    
    func spawnAndMoveTorch(){
        
        let torch:SKSpriteNode = SKSpriteNode(imageNamed: "torch1")
        torch.position = CGPoint(x: (backgroundNode.size.width / 4), y: backgroundNode.size.height / 4)
        torch.zPosition = backgroundNode.zPosition + 1
        worldNode.addChild(torch)
        
        let animate = SKAction.animate(with: torchFrames, timePerFrame: 0.2)
        let forever = SKAction.repeatForever(animate)
        torch.run(forever, withKey: AnimationKeys.torchKey)

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
    
    func internalJump(completion: @escaping(()->())){
        
        //Start game by jumping once
        if (!startedGame){
            startedGame = true
            self.startGame()
        }
        
        playSound(path: Bundle.main.path(forResource: "jump", ofType: "mp3")!)
        
        joe.jump { [unowned self] in
            completion()
            self.joe.startWalking()
        }
        
    }
    
    func internalCrouch(completion: @escaping(()->())){
        
        //Or start game by crouching once
        if (!startedGame){
            startedGame = true
            self.startGame()
        }
        
        playSound(path: Bundle.main.path(forResource: "crouch", ofType: "mp3")!)
        
        joe.crouch { [unowned self] in
            completion()
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
        
        //Make sure the sounds play and buttons disabled
        parentVC.parentVC.mainSoundPlayer.stop()
        effectPlayer.stop()
        parentVC.parentVC.upButton.isEnabled = false
        parentVC.parentVC.downButton.isEnabled = false
        parentVC.parentVC.pressDisabled = true
                
        endGame = true
        parentVC.parentVC.replayButton.isHidden = false
        

        let newHighScore = setHighScore()
        
        //Clear board
        worldNode.removeAllChildren()
        removeAllChildren()
        removeAllActions()
        
        //Handle score
        handleScoreScene(newHighScore: newHighScore)
        
    }
    
    func handleScoreScene(newHighScore: Bool){
        
        scoreLabel = SKLabelNode()
        
        if (newHighScore){
            
            playSound(path: Bundle.main.path(forResource: "woohoo", ofType: "m4a")!)
            
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
            let scaleDown = SKAction.scaleX(to: 1, duration: 0.3)
            
            scoreLabel.text = "New High Score!!!"
            
            scoreLabel.run(SKAction.repeat(SKAction.sequence([scaleUp, scaleDown]), count: 20))
        
        } else{
            
            scoreLabel.text = "Score: \(internalScore + 1)"
            parentVC.parentVC.playSound(path: Bundle.main.path(forResource: "lose", ofType: "mp3")!, numberOfLoops: 0)

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
        scoreLabel.removeFromParent()
        internalScore = 0
        setSceneChildren()
        startGame()
    }

}

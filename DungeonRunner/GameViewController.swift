//
//  GameViewController.swift
//  DungeonRunner
//
//  Created by Barak on 12/29/20.
//

import Cocoa
import Foundation
import SpriteKit

class GameViewController: NSViewController {
    
    //Have access to desktop window VC
    weak var parentVC: ViewController!
    
    //Actual view where game scene is presented
    private lazy var gameView: SKView = {
        let view = SKView(frame: self.view.bounds)
        view.autoresizingMask = [.width, .height]
        return view
    }()
    
    //Jump button pressed handling
    func jump(completion: @escaping(()->())){
        if let scene = gameView.scene as? GameScene{
            scene.internalJump(completion: completion)
        }
    }
    
    //Crouch button pressed handling
    func crouch(completion: @escaping ()->()){
        if let scene = gameView.scene as? GameScene{
            scene.internalCrouch(completion: completion)
        }
    }
    
    //Replay button pressed handling
    func resetGame(){
        if let scene = gameView.scene as? GameScene{
            scene.resetGame()
        }
    }
    
    //Check game status
    func gameOverCheck() -> Bool{
        if let scene = gameView.scene as? GameScene{
            return scene.gameOver
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = NSView()
        view.addSubview(gameView)
    }
 
    override func viewDidAppear() {
        super.viewDidAppear()
        
        //Create game scene
        if gameView.scene == nil {
            let scene = SKScene(fileNamed: "GameScene") as? GameScene
            scene!.scaleMode = .aspectFill
            scene!.parentVC = self
            scene!.isUserInteractionEnabled = true
            gameView.presentScene(scene)
        }
    }
    
}

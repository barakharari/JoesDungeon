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
    
    weak var parentVC: ViewController!
    
    private lazy var gameView: SKView = {
        let view = SKView(frame: self.view.bounds)
        view.autoresizingMask = [.width, .height]
        return view
    }()
    
    func jump(completion: @escaping(()->())){
        if let scene = gameView.scene as? GameScene{
            scene.internalJump(completion: completion)
        }
    }
    
    func crouch(completion: @escaping ()->()){
        if let scene = gameView.scene as? GameScene{
            scene.internalCrouch(completion: completion)
        }
    }
    
    func resetGame(){
        if let scene = gameView.scene as? GameScene{
            scene.resetGame()
        }
    }
    
    func gameOverCheck() -> Bool{
        if let scene = gameView.scene as? GameScene{
            return scene.endGame
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here

    }
    
    override func loadView() {
        view = NSView()
        view.addSubview(gameView)
    }
 
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if gameView.scene == nil {
            let scene = SKScene(fileNamed: "GameScene") as? GameScene
            scene!.scaleMode = .aspectFill
            scene!.parentVC = self
            scene!.isUserInteractionEnabled = true
            gameView.presentScene(scene)
        }
    }
    
}

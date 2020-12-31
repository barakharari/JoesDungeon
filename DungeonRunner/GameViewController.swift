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
    
    func jump(sender: NSButton){
        if let scene = gameView.scene as? GameScene{
            scene.internalJump(sender: sender)
        }
    }
    
    func crouch(sender: NSButton){
        if let scene = gameView.scene as? GameScene{
            scene.internalCrouch(sender: sender)
        }
    }
    
    func resetGame(){
        if let scene = gameView.scene as? GameScene{
            scene.resetGame()
        }
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
            gameView.presentScene(scene)
        }
    }
    
}

//
//  ViewController.swift
//  DungeonRunner
//
//  Created by Barak on 12/29/20.
//

import Cocoa
import SpriteKit
import GameplayKit
import AVFoundation

class ViewController: NSViewController, NSTouchBarDelegate {

    @IBOutlet var skView: SKView!
    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var scoreTextField: NSTextField!
    @IBOutlet weak var highScoreTextField: NSTextField!
    @IBOutlet weak var replayButton: NSButton!
    
    var upButton:NSButton!
    var downButton:NSButton!
    
    var mainSoundPlayer = AVAudioPlayer()
    
    @IBAction func pressReplayButton(_ sender: NSButton) {
        if let gameVC = gameViewController{
            gameVC.resetGame()
        }
        downButton.isEnabled = true
        upButton.isEnabled = true
        replayButton.isHidden = true
    }
    
    var gameViewController:GameViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        designSubViews()
        
        replayButton.isHidden = true
        
        playSound(path: Bundle.main.path(forResource: "music", ofType: "m4a")!)
    }
    
    func playSound(path: String){
        do{
            mainSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            mainSoundPlayer.play()
        } catch{
            print(error)
        }
    }
    
    func designSubViews(){
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = backgroundBlue
        
        // Insert code here to initialize your application
        let highScore = UserDefaults.standard.value(forKey: "highscore") as? Int
        if (highScore == nil){
            UserDefaults.standard.setValue(0, forKey: "highscore")
            highScoreTextField.stringValue = "Highscore: 0"
        } else{
            highScoreTextField.stringValue = "Highscore: \(UserDefaults.standard.value(forKey: "highscore") as! Int)"
        }
        
        
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        let bar = NSTouchBar()
        bar.delegate = self
        bar.defaultItemIdentifiers = [.upButton, .downButton, .touchBarVC, .fixedSpaceSmall]
        return bar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier{
        case NSTouchBarItem.Identifier.touchBarVC:
            let item = NSCustomTouchBarItem(identifier: .touchBarVC)
            if (gameViewController == nil){
                gameViewController = GameViewController()
                gameViewController!.parentVC = self
            }
            item.viewController = gameViewController
            return item
        case NSTouchBarItem.Identifier.upButton:
            let item = NSCustomTouchBarItem(identifier: .upButton)
            upButton = NSButton(image: NSImage(systemSymbolName: "arrowtriangle.up.fill", accessibilityDescription: nil)!, target: self, action: #selector(jump))
            item.view = upButton
            return item
        case NSTouchBarItem.Identifier.downButton:
            let item = NSCustomTouchBarItem(identifier: .downButton)
            downButton = NSButton(image: NSImage(systemSymbolName: "arrowtriangle.down.fill", accessibilityDescription: nil)!, target: self, action: #selector(crouch))
            downButton.isEnabled = false
            item.view = downButton
            return item
        default: return nil
        }
    }
    
    @objc func jump(sender: NSButton){
        downButton.isEnabled = true
        if let vc = gameViewController{
            sender.isEnabled = false
            vc.jump(sender: sender)
        }
    }
    
    @objc func crouch(sender: NSButton){
        if let vc = gameViewController{
            sender.isEnabled = false
            vc.crouch(sender: sender)
        }
    }
}

extension NSTouchBarItem.Identifier {
    static let touchBarVC =  NSTouchBarItem.Identifier("com.spriteKit.touchBar")
    static let upButton = NSTouchBarItem.Identifier("com.spriteKit.upButton")
    static let downButton = NSTouchBarItem.Identifier("com.spriteKit.downButton")
}



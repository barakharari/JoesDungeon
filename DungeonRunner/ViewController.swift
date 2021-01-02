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

class ViewController: NSViewController {

    //All the views we are using in window
    @IBOutlet var skView: NSView!
    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var scoreTextField: NSTextField!
    @IBOutlet weak var highScoreTextField: NSTextField!
    @IBOutlet weak var replayButton: NSButton!
    @IBOutlet weak var instructionsTextField: NSTextField!
    
    //Buttons and press disabled status
    var upButton:NSButton!
    var downButton:NSButton!
    var pressDisabled:Bool = false
    
    //Music player
    var mainSoundPlayer = AVAudioPlayer()
    
    //Child game view controller
    var gameViewController:GameViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Design window subviews
        designSubViews()
        
        //Play main music
        playSound(path: Bundle.main.path(forResource: "music", ofType: "m4a")!, numberOfLoops: 20)
    }
    
    func designSubViews(){
        
        //Initially hide replay button
        replayButton.isHidden = true
        
        //Set background view color
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = backgroundBlue
        
        //Set highscore variable in userdefaults
        let highScore = UserDefaults.standard.value(forKey: "highscore") as?
            Int
        if (highScore == nil){
            UserDefaults.standard.setValue(0, forKey: "highscore")
            highScoreTextField.stringValue = "Highscore: 0"
        } else{
            highScoreTextField.stringValue = "Highscore: \(UserDefaults.standard.value(forKey: "highscore") as! Int)"
        }
        
        //Initiate fading of instructions
        instructionsAnimation()
    
    }
    
    //While instructions text field isn't hidden, continuously fade in and out
    func instructionsAnimation(){
        DispatchQueue.global(qos: .background).async {
            var hidden = false
            while (!hidden){
                DispatchQueue.main.async {
                    hidden = self.instructionsTextField.isHidden
                    NSAnimationContext.runAnimationGroup { context in
                        context.duration = 2
                        self.instructionsTextField.animator().alphaValue = 0
                    } completionHandler: {
                        self.instructionsTextField.animator().alphaValue = 1
                    }
                }
                sleep(1)
            }
        }
    }
    
    //Replay is pressed, we have to enable all of our buttons and reset game state
    @IBAction func pressReplayButton(_ sender: NSButton) {
        
        if let gameVC = gameViewController{
            mainSoundPlayer.stop()
            gameVC.resetGame()
        }
        
        downButton.isEnabled = true
        upButton.isEnabled = true
        replayButton.isHidden = true
        pressDisabled = false
    
    }
    
    override func viewDidAppear() {
        view.window?.makeFirstResponder(self)
    }
    
    //Handle keyboard clicks, disable pressing while we are jumping
    override func keyDown(with event: NSEvent) {
                
        if (event.keyCode == 126){
            instructionsTextField.isHidden = true
            if (!pressDisabled){
                self.pressDisabled = true
                gameViewController?.jump(completion: { [unowned self] in pressDisabled = false})
            }
        } else if (event.keyCode == 125){
            instructionsTextField.isHidden = true
            if (!pressDisabled){
                self.pressDisabled = true
                gameViewController?.crouch(completion: { [unowned self] in pressDisabled = false})
            }
        }
    

    }

    //General use function for playing sounds on main audio player
    func playSound(path: String, numberOfLoops: Int){
        do{
            mainSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            mainSoundPlayer.play()
            mainSoundPlayer.numberOfLoops = numberOfLoops
        } catch{
            print(error)
        }
    }
    
}

extension ViewController: NSTouchBarDelegate{
    
    //Create touchbar, set order of windows, set touchbar delegate as self
    override func makeTouchBar() -> NSTouchBar? {
        let bar = NSTouchBar()
        bar.delegate = self
        bar.customizationIdentifier = "com.spriteKit.barIdentifier"
        bar.defaultItemIdentifiers = [.upButton, .downButton, .touchBarVC, .fixedSpaceSmall]
        return bar
    }
    
    //Different touch bar views
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier{
        //Create gameview controller where game scene will live
        case NSTouchBarItem.Identifier.touchBarVC:
            let item = NSCustomTouchBarItem(identifier: .touchBarVC)
            if (gameViewController == nil){
                gameViewController = GameViewController()
                gameViewController!.parentVC = self
            }
            item.viewController = gameViewController
            return item
        //Up button
        case NSTouchBarItem.Identifier.upButton:
            let item = NSCustomTouchBarItem(identifier: .upButton)
            upButton = NSButton(image: NSImage(systemSymbolName: "arrowtriangle.up.fill", accessibilityDescription: nil)!, target: self, action: #selector(jump))
            item.view = upButton
            return item
        //Down button
        case NSTouchBarItem.Identifier.downButton:
            let item = NSCustomTouchBarItem(identifier: .downButton)
            downButton = NSButton(image: NSImage(systemSymbolName: "arrowtriangle.down.fill", accessibilityDescription: nil)!, target: self, action: #selector(crouch))
            item.view = downButton
            return item
        default: return nil
        }
    }
    
    //Jump button clicked on touchbar
    @objc func jump(sender: NSButton){
        instructionsTextField.isHidden = true
        if let vc = gameViewController{
            sender.isEnabled = false
            vc.jump(completion: {sender.isEnabled = true})
        }
    }
    
    //Crouch button clicked on touchbar
    @objc func crouch(sender: NSButton){
        instructionsTextField.isHidden = true
        if let vc = gameViewController{
            sender.isEnabled = false
            vc.crouch(completion: {sender.isEnabled = true})
        }
    }
    
}

//Touchbar custom item identifiers
extension NSTouchBarItem.Identifier {
    static let touchBarVC =  NSTouchBarItem.Identifier("com.spriteKit.touchBar")
    static let upButton = NSTouchBarItem.Identifier("com.spriteKit.upButton")
    static let downButton = NSTouchBarItem.Identifier("com.spriteKit.downButton")
}

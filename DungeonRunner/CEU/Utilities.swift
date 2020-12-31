//
//  Utilities.swift
//  DungeonRunner
//
//  Created by Barak on 12/30/20.
//

import Foundation
import SpriteKit

func getAnimationTextures(baseString:String, numImages: Int) -> [SKTexture]{
    
    var frames: [SKTexture] = []

    for i in 1...numImages {
      let textureName = "\(baseString)\(i)"
      let texture = SKTexture(imageNamed: textureName)
      frames.append(texture)
    }
    return frames
}

//
//  HandNode.swift
//  SCNFrogger
//
//  Created by Kim Pedersen on 11/12/14.
//  Copyright (c) 2014 RWDevCon. All rights reserved.
//

import SpriteKit

class HandNode : SKNode {
  
  override init() {
    
    super.init()
    
    // Load textures
    let handTexture = SKTexture(imageNamed:"assets.scnassets/Textures/hand.png")
    handTexture.filteringMode = SKTextureFilteringMode.Nearest
    let handTextureClick = SKTexture(imageNamed:"assets.scnassets/Textures/hand_click.png")
    handTextureClick.filteringMode = SKTextureFilteringMode.Nearest
    
    // Create animation
    let handAnimation = SKAction.animateWithTextures([handTexture, handTextureClick], timePerFrame:0.5)
    
    // Create a sprite node abd animate it
    let handSprite = SKSpriteNode(texture: handTexture)
    handSprite.name = "Tutorial"
    handSprite.xScale = 2.0
    handSprite.yScale = 2.0
    handSprite.runAction(SKAction.repeatActionForever(handAnimation))
    
    addChild(handSprite)
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

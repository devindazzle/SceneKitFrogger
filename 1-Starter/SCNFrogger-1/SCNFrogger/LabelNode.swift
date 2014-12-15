//
//  LabelNode.swift
//  SCNFrogger
//
//  Created by Kim Pedersen on 11/12/14.
//  Copyright (c) 2014 RWDevCon. All rights reserved.
//

import SpriteKit

class LabelNode : SKLabelNode {
  
  init(position: CGPoint, size: CGFloat, color: SKColor, text: String, name: String) {
    super.init()
    
    self.name = name
    self.text = text
    self.position = position
    
    fontName = "Early-Gameboy"
    fontSize = size
    fontColor = color
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

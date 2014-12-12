//
//  LabelNode.swift
//  SCNFrogger
//
//  Created by Kim Pedersen on 11/12/14.
//  Copyright (c) 2014 RWDevCon. All rights reserved.
//

import SpriteKit

class LabelNode : SKNode {
  
  init(position: CGPoint, size: CGFloat, color: SKColor, text: String, name: String) {
    super.init()
    let label = SKLabelNode(fontNamed: "Early-GameBoy")
    label.name = name
    label.text = text
    label.fontSize = size
    label.fontColor = color
    addChild(label)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

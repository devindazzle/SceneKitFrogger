//
//  Constants.swift
//  SCNFrogger
//
//  Created by Kim Pedersen on 11/12/14.
//  Copyright (c) 2014 RWDevCon. All rights reserved.
//

enum GameState {
case WaitingForFirstTap
case Playing
case GameOver
case RestartLevel
}


enum MoveDirection {
case Forward
case Backward
case Left
case Right
}


struct PhysicsCategory {
  static let None: Int              = 0
  static let Player: Int            = 0b1      // 1
  static let Car: Int               = 0b10     // 2
  static let Obstacle: Int          = 0b100    // 4
}
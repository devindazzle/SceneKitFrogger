//
//  GameLevelGenerator.swift
//  RWDevConSceneKitFinal
//
//  Created by Kim Pedersen on 25/11/14.
//  Copyright (c) 2014 RWDevCon. All rights reserved.
//

import SceneKit


enum GameLevelDataType: Int {
  case Invalid = -1 // Invalid tile
  case Grass = 0    // The player can move on these tiles
  case Road         // The player can move on these tiles but cars will be driving on this too .. watch out!
  case Obstacle     // The player cannot move through this tile
}


class GameLevel: Printable {
  
  var data: Array2D
  let segmentSize: Float = 0.2
  var maxObstaclesPerRow: Int = 3
  
  var description: String {
    var outputString: String = ""
    for row in 0..<data.rowCount() {
      outputString += "[\(row)]: "
      for col in 0..<data.columnCount() {
        outputString += String(data[col, row])
      }
      outputString += "\n"
    }
    return outputString
  }
  
  
  init(width: Int, height: Int) {
    // Level data is stored in a 2D array
    data = Array2D(cols: width, rows: height, value: GameLevelDataType.Obstacle.rawValue)
    
    // Create the level procedurally
    for row in 5...data.rowCount() - 6 {
      var type = GameLevelDataType.Invalid
      
      // Determine if this should be a grass (0) or road (1)
      if row < 8 || row > data.rowCount() - 10 {
        // The first and last four rows will be grass
        type = GameLevelDataType.Grass
      } else {
        type = Int(arc4random_uniform(2)) > 0 ? GameLevelDataType.Grass : GameLevelDataType.Road
      }
      
      fillLevelDataRowWithType(type: type, row: row)
    }
    
    // Always make sure the player spawn point is not an obstacle
    // TODO: Make sure this is not hardcoded
    data[7, 6] = GameLevelDataType.Grass.rawValue
  }
  
  
  func fillLevelDataRowWithType(#type: GameLevelDataType, row: Int) {
    for column in 0..<data.columnCount() {
      var obstacleCountInRow = 0
      if column < 5 || column > data.columnCount() - 6 {
        // Always obstacles at borders
        data[column, row] = GameLevelDataType.Obstacle.rawValue
      } else {
        if type == GameLevelDataType.Grass && obstacleCountInRow < maxObstaclesPerRow {
          // Determine if an obstacle should be added
          if arc4random_uniform(100) > 80 {
            // Add obstacle
            data[column, row] = GameLevelDataType.Obstacle.rawValue
            obstacleCountInRow++
          } else {
            // Add grass
            data[column, row] = type.rawValue
          }
        } else {
          data[column, row] = type.rawValue
        }
      }
    }
  }
  
  
  func coordinatesForGridPosition(#column: Int, row: Int) -> SCNVector3 {
    // Raise an error is the column or row is out of bounds
    if column < 0 || column > data.columnCount() - 1 || row < 0 || row > data.rowCount() - 1 {
      fatalError("The row or column is out of bounds")
    }
    
    let x: Int = Int(column - data.cols / 2)
    let y: Int = -row
    return SCNVector3(x: Float(x) * 0.2, y: 0.0, z: Float(y) * 0.2)
  }
  
  
  func gameLevelDataTypeForGridPosition(#column: Int, row: Int) -> GameLevelDataType {
    // Raise an error is the column or row is out of bounds
    if column < 0 || column > data.columnCount() - 1 || row < 0 || row > data.rowCount() - 1 {
      return GameLevelDataType.Invalid
    }
    
    let type = GameLevelDataType(rawValue: data[column, row] as Int)
    return type!
  }
  
  func gameLevelWidth() -> Float {
    return Float(data.columnCount()) * segmentSize
  }
  
  func gameLevelHeight() -> Float {
    return Float(data.rowCount()) * segmentSize
  }
  
}

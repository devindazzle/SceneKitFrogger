//
//  GameLevelGenerator.swift
//  RWDevConSceneKitFinal
//
//  Created by Kim Pedersen on 25/11/14.
//  Copyright (c) 2014 RWDevCon. All rights reserved.
//

import SceneKit


protocol GameLevelSpawnDelegate : NSObjectProtocol {
  func spawnCarAtPosition(position: SCNVector3)
}


enum GameLevelDataType: Int {
  case Invalid = -1 // Invalid tile
  case Grass = 0    // The player can move on these tiles
  case Road         // The player can move on these tiles but cars will be driving on this too .. watch out!
  case Obstacle     // The player cannot move through this tile
}


class GameLevel: Printable {
  
  // A delegate that is called when a new car needs to be spawned on a road.
  var spawnDelegate: GameLevelSpawnDelegate?
  
  var data: Array2D
  let segmentSize: Float = 0.2
  var maxObstaclesPerRow: Int = 3
  
  // Outputs the data structure to the console - great for debugging
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
      
      fillLevelDataRowWithType(type, row: row)
    }
    
    // Always make sure the player spawn point is not an obstacle
    // TODO: Make sure this is not hardcoded
    data[7, 6] = GameLevelDataType.Grass.rawValue
  }
  
  
  func fillLevelDataRowWithType(type: GameLevelDataType, row: Int) {
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
  
  
  func gridColumnAndRowAfterMoveInDirection(direction: MoveDirection, currentGridColumn: Int, currentGridRow: Int) -> (didMove: Bool, newGridColumn: Int, newGridRow: Int) {
    
    // Calculate the new grid position after the move
    var newGridColumn = currentGridColumn
    var newGridRow = currentGridRow
    
    switch direction {
    case .Forward:
      newGridRow += 1
      break;
    case .Backward:
      newGridRow -= 1
      break
    case .Left:
      newGridColumn -= 1
      break
    case .Right:
      newGridColumn += 1
    }
    
    // Determine the type of data at new position
    let type = gameLevelDataTypeForGridPosition(column: newGridColumn, row: newGridRow)
    
    switch type {
    case .Invalid, .Obstacle:
      // Cannot move here, so return the column and row passed.
      return (false, currentGridColumn, currentGridRow)
    default:
      // Move is valid, so return the new column and row
      return (true, newGridColumn, newGridRow)
    }
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
  
  
  func setupLevelAtPosition(position: SCNVector3, parentNode: SCNNode) {
    
    let levelNode = SCNNode()
    
    // Create light grass material
    let lightGrassMaterial = SCNMaterial()
    lightGrassMaterial.diffuse.contents = UIColor(red: 190.0/255.0, green: 244.0/255.0, blue: 104.0/255.0, alpha: 1.0)
    lightGrassMaterial.locksAmbientWithDiffuse = false
    
    // Create dark grass material
    let darkGrassMaterial = SCNMaterial()
    darkGrassMaterial.diffuse.contents = UIColor(red: 183.0/255.0, green: 236.0/255.0, blue: 96.0/255.0, alpha: 1.0)
    darkGrassMaterial.locksAmbientWithDiffuse = false
    
    // Create tree top material
    let treeTopMaterial = SCNMaterial()
    treeTopMaterial.diffuse.contents = UIColor(red: 118.0/255.0, green: 141.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    treeTopMaterial.locksAmbientWithDiffuse = false
    
    // Create tree trunk material
    let treeTrunkMaterial = SCNMaterial()
    treeTrunkMaterial.diffuse.contents = UIColor(red: 185.0/255.0, green: 122.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    treeTrunkMaterial.locksAmbientWithDiffuse = false
    
    // Create road material
    let roadMaterial = SCNMaterial()
    roadMaterial.diffuse.contents = UIColor.darkGrayColor()
    roadMaterial.diffuse.wrapT = SCNWrapMode.Repeat
    roadMaterial.locksAmbientWithDiffuse = false
    
    // First, create geometry for grass and roads
    for row in 0..<data.rowCount() {
      
      // HACK: Check column 5 as column 0 to 4 will always be obstacles
      let type = gameLevelDataTypeForGridPosition(column: 5, row: row)
      switch type {
      case GameLevelDataType.Road:
        
        // Create a road row
        let roadGeometry = SCNPlane(width: CGFloat(gameLevelWidth()), height: CGFloat(segmentSize))
        roadGeometry.widthSegmentCount = 1
        roadGeometry.heightSegmentCount = 1
        roadGeometry.firstMaterial = roadMaterial
        
        let roadNode = SCNNode(geometry: roadGeometry)
        roadNode.position = coordinatesForGridPosition(column: Int(data.columnCount() / 2), row: row)
        roadNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: -3.1415 / 2.0)
        levelNode.addChildNode(roadNode)
        
        // Create a spawn node at one side of the road depending on whether the row is even or odd
        
        // Determine if the car should start from the left of the right
        let startCol = row % 2 == 0 ? 0 : data.columnCount() - 1
        let moveDirection : Float = row % 2 == 0 ? 1.0 : -1.0
        
        // Determine the position of the node
        var position = coordinatesForGridPosition(column: startCol, row: row)
        position = SCNVector3(x: position.x, y: 0.15, z: position.z)
        
        // Create node
        let spawnNode = SCNNode()
        spawnNode.position = position
        
        // Create an action to make the node spawn cars
        let spawnAction = SCNAction.runBlock({ node in
          self.spawnDelegate!.spawnCarAtPosition(node.position)
        })
        
        // Will spawn a new car every 5 + (random time interval up to 5 seconds)
        let delayAction = SCNAction.waitForDuration(5.0, withRange: 5.0)
        
        spawnNode.runAction(SCNAction.repeatActionForever(SCNAction.sequence([delayAction, spawnAction])))
        
        parentNode.addChildNode(spawnNode)
        
        break
        
      default:
        
        // Create a grass row
        let grassGeometry = SCNPlane(width: CGFloat(gameLevelWidth()), height: CGFloat(segmentSize))
        grassGeometry.widthSegmentCount = 1
        grassGeometry.heightSegmentCount = 1
        grassGeometry.firstMaterial = row % 2 == 0 ? lightGrassMaterial : darkGrassMaterial
        
        let grassNode = SCNNode(geometry: grassGeometry)
        grassNode.position = coordinatesForGridPosition(column: Int(data.columnCount() / 2), row: row)
        grassNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: -3.1415 / 2.0)
        levelNode.addChildNode(grassNode)
        
        // Create obstacles
        for col in 0..<data.columnCount() {
          let subType = gameLevelDataTypeForGridPosition(column: col, row: row)
          if subType == GameLevelDataType.Obstacle {
            // Height of tree top is random
            let treeHeight = CGFloat((arc4random_uniform(5) + 2)) / 10.0
            let treeTopPosition = Float(treeHeight / 2.0 + 0.1)
            
            // Create a tree
            let treeTopGeomtery = SCNBox(width: 0.1, height: treeHeight, length: 0.1, chamferRadius: 0.0)
            treeTopGeomtery.firstMaterial = treeTopMaterial
            let treeTopNode = SCNNode(geometry: treeTopGeomtery)
            let gridPosition = coordinatesForGridPosition(column: col, row: row)
            treeTopNode.position = SCNVector3(x: gridPosition.x, y: treeTopPosition, z: gridPosition.z)
            levelNode.addChildNode(treeTopNode)
            
            let treeTrunkGeometry = SCNBox(width: 0.05, height: 0.1, length: 0.05, chamferRadius: 0.0)
            treeTrunkGeometry.firstMaterial = treeTrunkMaterial
            let treeTrunkNode = SCNNode(geometry: treeTrunkGeometry)
            treeTrunkNode.position = SCNVector3(x: gridPosition.x, y: 0.05, z: gridPosition.z)
            levelNode.addChildNode(treeTrunkNode)
          }
        }
        
        break
      }
    }
    
    // Combine all the geometry into one - this will reduce the number of draw calls and improve performance
    let flatLevelNode = levelNode.flattenedClone()
    flatLevelNode.name = "Level"
    
    // Add the flattened node
    parentNode.position = position
    parentNode.addChildNode(flatLevelNode)
  }
  
}

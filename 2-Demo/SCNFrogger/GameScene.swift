//
//  GameScene.swift
//  SCNFrogger
//
//  Created by Kim Pedersen on 02/12/14.
//  Copyright (c) 2014 RWDevCon. All rights reserved.
//

import SceneKit
import SpriteKit


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


class GameScene : SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
  
  // MARK: Properties
  var view: SCNView!
  var gameState = GameState.WaitingForFirstTap
  var camera: SCNNode!
  var cameraOrthographicScale = 0.5
  var cameraOffsetFromPlayer = SCNVector3(x: 0.25, y: 1.25, z: 0.55)
  var level: SCNNode!
  var levelData: GameLevel!
  
  // TODO: Add player properties here
  
  
  init(view: SCNView) {
    self.view = view
    super.init()
    
    initializeLevel()
  }
  
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  func initializeLevel() {
    
    // Set up gesture recognizers
    setupGestureRecognizersForView(view)
    
    // Create level procedurally
    levelData = GameLevel(width: 19, height: 50)
    
    // Create ambient light
    let ambientLight = createAmbientLight()
    self.rootNode.addChildNode(ambientLight)
    
    // Create omni light
    let omniLight = createOmniLightAtPosition(position: SCNVector3(x: -10.0, y: 20, z: 10.0))
    self.rootNode.addChildNode(omniLight)
    
    // TODO: Add code to initialize player here
    
    
    // TODO: Add code to create camera here
    
    
    // Create nodes for level
    level = createLevelAtPosition(position: SCNVector3Zero)
    self.rootNode.addChildNode(level)
    
    // Start the game
    switchToWaitingForFirstTap()
    
  }
  
  
  // MARK: Setup methods
  
  func setupGestureRecognizersForView(view: SCNView) {
    // Create tap gesture recognizer
    let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
    tapGesture.numberOfTapsRequired = 1
    view.addGestureRecognizer(tapGesture)
    
    // Create swipe gesture recognizers
    let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
    swipeUpGesture.direction = UISwipeGestureRecognizerDirection.Up
    view.addGestureRecognizer(swipeUpGesture)
    
    let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
    swipeDownGesture.direction = UISwipeGestureRecognizerDirection.Down
    view.addGestureRecognizer(swipeDownGesture)
    
    let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left
    view.addGestureRecognizer(swipeLeftGesture)
    
    let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
    swipeRightGesture.direction = UISwipeGestureRecognizerDirection.Right
    view.addGestureRecognizer(swipeRightGesture)
  }
  
  
  // MARK: Game Objects
  
  func createCameraAtPosition(#position: SCNVector3) -> SCNNode {
    let camera = SCNCamera()
    camera.usesOrthographicProjection = true
    camera.orthographicScale = cameraOrthographicScale
    camera.zNear = 0.05
    camera.zFar = 150.0
    let cameraNode = SCNNode()
    cameraNode.name = "Camera"
    cameraNode.camera = camera
    cameraNode.position = position
    return cameraNode
  }
  
  
  func createAmbientLight() -> SCNNode {
    let light = SCNLight()
    light.type = SCNLightTypeAmbient
    light.color = UIColor.whiteColor()
    let lightNode = SCNNode()
    lightNode.name = "AmbientLight"
    lightNode.light = light
    return lightNode
  }
  
  
  func createOmniLightAtPosition(#position: SCNVector3) -> SCNNode {
    let light = SCNLight()
    light.type = SCNLightTypeOmni
    light.color = UIColor.whiteColor()
    let lightNode = SCNNode()
    lightNode.name = "OmniLight"
    lightNode.light = light
    lightNode.position = position
    return lightNode
  }
  
  
  func createLevelAtPosition(#position: SCNVector3) -> SCNNode {
    
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
    for row in 0..<levelData.data.rowCount() {
      
      // HACK: Check column 5 as column 0 to 4 will always be obstacles
      let type = levelData.gameLevelDataTypeForGridPosition(column: 5, row: row)
      switch type {
      case GameLevelDataType.Road:
        
        // Create a road row
        let roadGeometry = SCNPlane(width: CGFloat(levelData.gameLevelWidth()), height: CGFloat(levelData.segmentSize))
        roadGeometry.widthSegmentCount = 1
        roadGeometry.heightSegmentCount = 1
        roadGeometry.firstMaterial = roadMaterial
        
        let roadNode = SCNNode(geometry: roadGeometry)
        roadNode.position = levelData.coordinatesForGridPosition(column: Int(levelData.data.columnCount() / 2), row: row)
        roadNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: -3.1415 / 2.0)
        levelNode.addChildNode(roadNode)
        
        break
        
      default:
        
        // Create a grass row
        let grassGeometry = SCNPlane(width: CGFloat(levelData.gameLevelWidth()), height: CGFloat(levelData.segmentSize))
        grassGeometry.widthSegmentCount = 1
        grassGeometry.heightSegmentCount = 1
        grassGeometry.firstMaterial = row % 2 == 0 ? lightGrassMaterial : darkGrassMaterial
        
        let grassNode = SCNNode(geometry: grassGeometry)
        grassNode.position = levelData.coordinatesForGridPosition(column: Int(levelData.data.columnCount() / 2), row: row)
        grassNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: -3.1415 / 2.0)
        levelNode.addChildNode(grassNode)
        
        // Create obstacles
        for col in 0..<levelData.data.columnCount() {
          let subType = levelData.gameLevelDataTypeForGridPosition(column: col, row: row)
          if subType == GameLevelDataType.Obstacle {
            // Height of tree top is random
            let treeHeight = CGFloat((arc4random_uniform(5) + 2)) / 10.0
            let treeTopPosition = Float(treeHeight / 2.0 + 0.1)
            
            // Create a tree
            let treeTopGeomtery = SCNBox(width: 0.1, height: treeHeight, length: 0.1, chamferRadius: 0.0)
            treeTopGeomtery.firstMaterial = treeTopMaterial
            let treeTopNode = SCNNode(geometry: treeTopGeomtery)
            let gridPosition = levelData.coordinatesForGridPosition(column: col, row: row)
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
    
    return flatLevelNode
  }
  
  
  // TODO: Add code to create player here
  
  
  
  // MARK: Game Play
  
  func didPlayerReachEndOfLevel() -> Bool {
    //return playerGridRow == levelData.data.rowCount() - 7
    return false
  }
  
  
  // MARK: Game State
  
  func switchToWaitingForFirstTap() {
    gameState = GameState.WaitingForFirstTap
    if let overlay = view.overlaySKScene {
      // Remove black node
      overlay.enumerateChildNodesWithName("RestartLevel", usingBlock: { node, stop in
        node.runAction(SKAction.sequence(
          [SKAction.fadeOutWithDuration(0.5),
            SKAction.removeFromParent()]))
      })
      
      // Tap to play animation icon
      let handTexture = SKTexture(imageNamed:"assets.scnassets/Textures/hand.png")
      handTexture.filteringMode = SKTextureFilteringMode.Nearest
      let handTextureClick = SKTexture(imageNamed:"assets.scnassets/Textures/hand_click.png")
      handTextureClick.filteringMode = SKTextureFilteringMode.Nearest
      let handAnimation = SKAction.animateWithTextures([handTexture, handTextureClick], timePerFrame:0.5)
      
      let handSprite = SKSpriteNode(texture: handTexture)
      handSprite.name = "Tutorial"
      handSprite.xScale = 2.0
      handSprite.yScale = 2.0
      handSprite.position = CGPoint(x: view.bounds.size.width/2.0, y: handSprite.size.height * 2.0)
      handSprite.runAction(SKAction.repeatActionForever(handAnimation))
      overlay.addChild(handSprite)
    }
  }
  
  
  func switchToPlaying() {
    gameState = GameState.Playing
    if let overlay = view.overlaySKScene {
      // Remove tutorial
      overlay.enumerateChildNodesWithName("Tutorial", usingBlock: { node, stop in
        node.runAction(SKAction.sequence(
          [SKAction.fadeOutWithDuration(0.25),
            SKAction.removeFromParent()]))
      })
    }
  }
  
  
  func switchToGameOver() {
    gameState = GameState.GameOver
    if let overlay = view.overlaySKScene {
      let gameOverLabel = SKLabelNode(fontNamed: "Early-GameBoy")
      gameOverLabel.name = "GameOver"
      gameOverLabel.text = "Game Over"
      gameOverLabel.fontSize = 24
      gameOverLabel.fontColor = SKColor.whiteColor()
      gameOverLabel.position = CGPoint(x: view.bounds.size.width/2.0, y: view.bounds.size.height/2.0)
      overlay.addChild(gameOverLabel)
      
      let clickToRestartLabel = SKLabelNode(fontNamed: "Early-GameBoy")
      clickToRestartLabel.name = "GameOver"
      clickToRestartLabel.text = "Tap to restart"
      clickToRestartLabel.fontSize = 14
      clickToRestartLabel.fontColor = SKColor.whiteColor()
      clickToRestartLabel.position = CGPoint(x: gameOverLabel.position.x, y: gameOverLabel.position.y - 24.0)
      overlay.addChild(clickToRestartLabel)
    }
    self.physicsWorld.contactDelegate = nil
  }
  
  func switchToRestartLevel() {
    gameState = GameState.RestartLevel
    if let overlay = view.overlaySKScene {
      overlay.enumerateChildNodesWithName("GameOver", usingBlock: { node, stop in
        node.runAction(SKAction.sequence(
          [SKAction.fadeOutWithDuration(0.25),
            SKAction.removeFromParent()]))
      })
      
      // Fade to black
      let blackNode = SKSpriteNode(color: UIColor.blackColor(), size: overlay.frame.size)
      blackNode.name = "RestartLevel"
      blackNode.alpha = 0.0
      blackNode.position = CGPoint(x: view.bounds.size.width/2.0, y: view.bounds.size.height/2.0)
      overlay.addChild(blackNode)
      blackNode.runAction(SKAction.sequence([SKAction.fadeInWithDuration(0.5), SKAction.runBlock({
        // self.rootNode.removeAllActions()
        let newScene = GameScene(view: self.view)
        newScene.physicsWorld.contactDelegate = newScene
        self.view.scene = newScene
        self.view.delegate = newScene
      })]))
    }
  }
  
  
  // MARK: Delegates
  
  func renderer(aRenderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
    if didPlayerReachEndOfLevel() && gameState == GameState.Playing {
      // player completed the level
      switchToGameOver()
    }
  }
  
  
  func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
    // Player got hit by a car - Game over man
    if gameState == GameState.Playing {
      switchToGameOver()
    }
  }
  
  
  // MARK: Touch Handling
  
  func handleTap(gesture: UIGestureRecognizer) {
    if let tapGesture = gesture as? UITapGestureRecognizer {
      // TODO: Add code to do movement here
    }
  }
  
  
  func handleSwipe(gesture: UIGestureRecognizer) {
    
    if let swipeGesture = gesture as? UISwipeGestureRecognizer {
      switch swipeGesture.direction {
      case UISwipeGestureRecognizerDirection.Up:
        // TODO: Add code to do movement here
        break
        
      case UISwipeGestureRecognizerDirection.Down:
        // TODO: Add code to do movement here
        break
        
      case UISwipeGestureRecognizerDirection.Left:
        // TODO: Add code to do movement here
        break
        
      case UISwipeGestureRecognizerDirection.Right:
        // TODO: Add code to do movement here
        break
        
      default:
        break
      }
    }
  }
  
  // TODO: Add code for player movement here
  
}
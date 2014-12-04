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
  var player: SCNNode!
  var playerModelNode: SCNNode!
  var playerGridCol = 7
  var playerGridRow = 6
  
  let soundJump = SKAction.playSoundFileNamed("assets.scnassets/Sounds/jump.wav", waitForCompletion: false)
  
  let playerScene = SCNScene(named: "assets.scnassets/Models/frog.dae")
  var sharedMaterial: SCNMaterial!
  
  
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
    
    // Create shared material
    sharedMaterial = createSharedMaterial()
    
    // TODO: Add code to initialize player here
    let playerGridPosition = levelData.coordinatesForGridPosition(column: playerGridCol, row: playerGridRow)
    player = createPlayerAtPosition(position: SCNVector3(x: playerGridPosition.x, y: 0.1, z: playerGridPosition.z))
    self.rootNode.addChildNode(player)
    
    // TODO: Add code to create camera here
    camera = createCameraAtPosition(position: cameraOffsetFromPlayer)
    camera.constraints = [SCNLookAtConstraint(target: player)]
    player.addChildNode(camera)
    
    // Create nodes for level
    level = levelData.createLevelAtPosition(position: SCNVector3Zero)
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
  
  
  // TODO: Add code to create player here
  func createPlayerAtPosition(#position: SCNVector3) -> SCNNode {
    let rootNode = SCNNode()
    rootNode.name = "Player"
    rootNode.position = position
    
    // Create player model node
    playerModelNode = playerScene!.rootNode.childNodeWithName("Frog", recursively: false)!
    playerModelNode.name = "PlayerModel"
    
    // let playerGeometry = playerScene!.rootNode.childNodeWithName("Frog", recursively: true)!.geometry
    // Create a material for the frog
    let playerMaterial = SCNMaterial()
    playerMaterial.diffuse.contents = UIImage(named: "assets.scnassets/Textures/model_texture.tga")
    playerMaterial.locksAmbientWithDiffuse = false
    playerMaterial.specular.contents = UIColor.whiteColor()
    playerMaterial.shininess = 1.0
    
    // Assign the material to the playerModelNode
    playerModelNode.geometry!.firstMaterial = playerMaterial
    
    // Create a physicsbody for collision detection
    playerModelNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: nil)
    playerModelNode.physicsBody!.categoryBitMask = PhysicsCategory.Player
    playerModelNode.physicsBody!.collisionBitMask = PhysicsCategory.Car
    
    rootNode.addChildNode(playerModelNode)
    return rootNode
  }
  
  
  func createSharedMaterial() -> SCNMaterial {
    let material = SCNMaterial()
    material.diffuse.contents = UIImage(named: "assets.scnassets/Textures/model_texture.tga")
    material.locksAmbientWithDiffuse = false
    material.specular.contents = UIColor.darkGrayColor()
    material.shininess = 0.5
    return material
  }
  
  
  // MARK: Game Play
  
  func didPlayerReachEndOfLevel() -> Bool {
    // TODO: Uncomment code to test for player reaching the end of level
    return playerGridRow == levelData.data.rowCount() - 7
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
      movePlayerInDirection(MoveDirection.Forward)
    }
  }
  
  
  func handleSwipe(gesture: UIGestureRecognizer) {
    
    if let swipeGesture = gesture as? UISwipeGestureRecognizer {
      switch swipeGesture.direction {
      case UISwipeGestureRecognizerDirection.Up:
        // TODO: Add code to do movement here
        movePlayerInDirection(MoveDirection.Forward)
        break
        
      case UISwipeGestureRecognizerDirection.Down:
        // TODO: Add code to do movement here
        movePlayerInDirection(MoveDirection.Backward)
        break
        
      case UISwipeGestureRecognizerDirection.Left:
        // TODO: Add code to do movement here
        movePlayerInDirection(MoveDirection.Left)
        break
        
      case UISwipeGestureRecognizerDirection.Right:
        // TODO: Add code to do movement here
        movePlayerInDirection(MoveDirection.Right)
        break
        
      default:
        break
      }
    }
  }
  
  // TODO: Add code for player movement here
  func movePlayerInDirection(direction: MoveDirection) {
    
    switch gameState {
    case GameState.WaitingForFirstTap:
      
      // Start playing
      switchToPlaying()
      movePlayerInDirection(direction)
      break
      
    case GameState.Playing:
      
      // Determine if the new position is a valid position
      var newPlayerGridCol = playerGridCol
      var newPlayerGridRow = playerGridRow
      
      switch direction {
      case .Forward:
        newPlayerGridRow += 1
        break;
      case .Backward:
        newPlayerGridRow -= 1
        break
      case .Left:
        newPlayerGridCol -= 1
        break
      case .Right:
        newPlayerGridCol += 1
      }
      
      // Determine the type of tile at new position
      let type = levelData.gameLevelDataTypeForGridPosition(column: newPlayerGridCol, row: newPlayerGridRow)
      
      if type == GameLevelDataType.Invalid || type == GameLevelDataType.Obstacle {
        // Invalid - do not move
        // println("Invalid move")
        
      } else {
        // Valid - move
        // println("Valid move to \(newPlayerGridCol), \(newPlayerGridRow)")
        
        playerGridCol = newPlayerGridCol
        playerGridRow = newPlayerGridRow
        
        // Move the player to new position
        var newPlayerPosition = levelData.coordinatesForGridPosition(column: playerGridCol, row: playerGridRow)
        newPlayerPosition = SCNVector3(x: newPlayerPosition.x, y: 0.1, z: newPlayerPosition.z)
        
        // Move the player using an action
        let moveAction = SCNAction.moveTo(newPlayerPosition, duration: 0.2)
        let jumpUpAction = SCNAction.moveBy(SCNVector3(x: 0.0, y: 0.2, z: 0.0), duration: 0.1)
        jumpUpAction.timingMode = SCNActionTimingMode.EaseInEaseOut
        let jumpDownAction = SCNAction.moveBy(SCNVector3(x: 0.0, y: -0.2, z: 0.0), duration: 0.1)
        jumpDownAction.timingMode = SCNActionTimingMode.EaseInEaseOut
        let jumpAction = SCNAction.sequence([jumpUpAction, jumpDownAction])
        
        // Play the action
        player.runAction(moveAction)
        playerModelNode.runAction(jumpAction)
        
        // Play jump sound
        if let overlay = view.overlaySKScene {
          overlay.runAction(soundJump)
        }
      }
      
      break
      
    case GameState.GameOver:
      
      // Switch to tutorial
      switchToRestartLevel()
      break
      
    case GameState.RestartLevel:
      
      // Switch to new level
      // switchToWaitingForFirstTap()
      break
      
    default:
      break
    }
    
  }
  
}
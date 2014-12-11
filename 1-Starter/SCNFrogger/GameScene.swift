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
  var sceneView: SCNView!
  var gameState = GameState.WaitingForFirstTap
  var camera: SCNNode!
  var cameraOrthographicScale = 0.5
  var cameraOffsetFromPlayer = SCNVector3(x: 0.25, y: 1.25, z: 0.55)
  var level: SCNNode!
  var levelData: GameLevel!
  let levelWidth: Int = 19
  let levelHeight: Int = 50
  
  
  init(view: SCNView) {
    sceneView = view
    super.init()
    
    initializeLevel()
  }
  
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  func initializeLevel() {
    setupGestureRecognizersForView(sceneView)
    setupLights()
    setupPlayer()
    setupCamera()
    setupLevel()
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
  
  
  func setupLights() {
    
    // Create ambient light
    let ambientLight = SCNLight()
    ambientLight.type = SCNLightTypeAmbient
    ambientLight.color = UIColor.whiteColor()
    let ambientLightNode = SCNNode()
    ambientLightNode.name = "AmbientLight"
    ambientLightNode.light = ambientLight
    rootNode.addChildNode(ambientLightNode)
    
    // Create an omni-directional light
    let omniLight = SCNLight()
    omniLight.type = SCNLightTypeOmni
    omniLight.color = UIColor.whiteColor()
    let omniLightNode = SCNNode()
    omniLightNode.name = "OmniLight"
    omniLightNode.light = omniLight
    omniLightNode.position = SCNVector3(x: -10.0, y: 20, z: 10.0)
    rootNode.addChildNode(omniLightNode)
    
  }
  
  
  func setupPlayer() {
    
  }
  
  
  func setupCamera() {
    
  }
  
  
  func setupLevel() {
    
  }
  
  
  // MARK: Game Objects
  
  func createCameraAtPosition(position: SCNVector3) -> SCNNode {
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
  
  
  // MARK: Game Play
  
  
  // TODO: Is this method needed??? It is referenced in just one place
  func didPlayerReachEndOfLevel() -> Bool {
    // TODO: Uncomment code to test for player reaching the end of level
    return false // playerGridRow == levelData.data.rowCount() - 7
  }
  
  
  // MARK: Game State
  
  func switchToWaitingForFirstTap() {
    gameState = GameState.WaitingForFirstTap
    if let overlay = sceneView.overlaySKScene {
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
      handSprite.position = CGPoint(x: sceneView.bounds.size.width/2.0, y: handSprite.size.height * 2.0)
      handSprite.runAction(SKAction.repeatActionForever(handAnimation))
      overlay.addChild(handSprite)
    }
  }
  
  
  func switchToPlaying() {
    gameState = GameState.Playing
    if let overlay = sceneView.overlaySKScene {
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
    if let overlay = sceneView.overlaySKScene {
      let gameOverLabel = SKLabelNode(fontNamed: "Early-GameBoy")
      gameOverLabel.name = "GameOver"
      gameOverLabel.text = "Game Over"
      gameOverLabel.fontSize = 24
      gameOverLabel.fontColor = SKColor.whiteColor()
      gameOverLabel.position = CGPoint(x: sceneView.bounds.size.width/2.0, y: sceneView.bounds.size.height/2.0)
      overlay.addChild(gameOverLabel)
      
      let clickToRestartLabel = SKLabelNode(fontNamed: "Early-GameBoy")
      clickToRestartLabel.name = "GameOver"
      clickToRestartLabel.text = "Tap to restart"
      clickToRestartLabel.fontSize = 14
      clickToRestartLabel.fontColor = SKColor.whiteColor()
      clickToRestartLabel.position = CGPoint(x: gameOverLabel.position.x, y: gameOverLabel.position.y - 24.0)
      overlay.addChild(clickToRestartLabel)
    }
    physicsWorld.contactDelegate = nil
  }
  
  func switchToRestartLevel() {
    gameState = GameState.RestartLevel
    if let overlay = sceneView.overlaySKScene {
      overlay.enumerateChildNodesWithName("GameOver", usingBlock: { node, stop in
        node.runAction(SKAction.sequence(
          [SKAction.fadeOutWithDuration(0.25),
            SKAction.removeFromParent()]))
      })
      
      // Fade to black
      let blackNode = SKSpriteNode(color: UIColor.blackColor(), size: overlay.frame.size)
      blackNode.name = "RestartLevel"
      blackNode.alpha = 0.0
      blackNode.position = CGPoint(x: sceneView.bounds.size.width/2.0, y: sceneView.bounds.size.height/2.0)
      overlay.addChild(blackNode)
      blackNode.runAction(SKAction.sequence([SKAction.fadeInWithDuration(0.5), SKAction.runBlock({
        let newScene = GameScene(view: self.sceneView)
        newScene.physicsWorld.contactDelegate = newScene
        self.sceneView.scene = newScene
        self.sceneView.delegate = newScene
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
    // Player got hit by a car - Game over man, game over!
    if gameState == GameState.Playing {
      switchToGameOver()
    }
  }
  
  
  // MARK: Touch Handling
  
  func handleTap(gesture: UIGestureRecognizer) {
    if let tapGesture = gesture as? UITapGestureRecognizer {
      
    }
  }
  
  
  func handleSwipe(gesture: UIGestureRecognizer) {
    
    if let swipeGesture = gesture as? UISwipeGestureRecognizer {
      switch swipeGesture.direction {
      case UISwipeGestureRecognizerDirection.Up:
        break
        
      case UISwipeGestureRecognizerDirection.Down:
        break
        
      case UISwipeGestureRecognizerDirection.Left:
        break
        
      case UISwipeGestureRecognizerDirection.Right:
        break
        
      default:
        break
      }
    }
  }
  
  
  /* func movePlayerInDirection(direction: MoveDirection) {
    
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
        
      } else {
        // Valid - move
        
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
    
  } */
  
}
//
//  GameScene.swift
//  SCNFrogger
//
//  Created by Kim Pedersen on 02/12/14.
//  Copyright (c) 2014 RWDevCon. All rights reserved.
//

import SceneKit
import SpriteKit


class GameScene : SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate, GameLevelSpawnDelegate {
  
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
  
  var player: SCNNode!
  let playerScene = SCNScene(named: "assets.scnassets/Models/frog.dae")
  var playerGridCol = 7
  var playerGridRow = 6
  
  
  // MARK: Init
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
    setupLevel()
    setupPlayer()
    setupCamera()
    switchToWaitingForFirstTap()
  }
  
  
  func setupPlayer() {
    player = playerScene!.rootNode.childNodeWithName("Frog", recursively: false)
    player.name = "Player"
    player.position = levelData.coordinatesForGridPosition(column: playerGridCol, row: playerGridRow)
    player.position.y = 0.2
    
    let playerMaterial = SCNMaterial()
    playerMaterial.diffuse.contents = UIImage(named: "assets.scnassets/Textures/model_texture.tga")
    playerMaterial.locksAmbientWithDiffuse = false
    player.geometry!.firstMaterial = playerMaterial
    
    rootNode.addChildNode(player)
  }
  
  
  func setupCamera() {
    camera = SCNNode()
    camera.name = "Camera"
    camera.position = cameraOffsetFromPlayer
    camera.camera = SCNCamera()
    camera.camera!.usesOrthographicProjection = true
    camera.camera!.orthographicScale = cameraOrthographicScale
    camera.camera!.zNear = 0.05
    camera.camera!.zFar = 150.0
    rootNode.addChildNode(camera)
    
    camera.constraints = [SCNLookAtConstraint(target: player)]
  }
  
  
  func setupLevel() {
    levelData = GameLevel(width: levelWidth, height: levelHeight)
    levelData.setupLevelAtPosition(SCNVector3Zero, parentNode: rootNode)
    levelData.spawnDelegate = self
  }
  
  
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
  
  
  // MARK: Game State
  func switchToWaitingForFirstTap() {
    
    gameState = GameState.WaitingForFirstTap
    
    // Fade in
    if let overlay = sceneView.overlaySKScene {
      overlay.enumerateChildNodesWithName("RestartLevel", usingBlock: { node, stop in
        node.runAction(SKAction.sequence(
          [SKAction.fadeOutWithDuration(0.5),
            SKAction.removeFromParent()]))
      })
      
      // Tap to play animation icon
      let handNode = HandNode()
      handNode.position = CGPoint(x: sceneView.bounds.size.width * 0.5, y: sceneView.bounds.size.height * 0.2)
      overlay.addChild(handNode)
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
      
      let gameOverLabel = LabelNode(
        position: CGPoint(x: sceneView.bounds.size.width/2.0, y: sceneView.bounds.size.height/2.0),
        size: 24, color: .whiteColor(),
        text: "Game Over",
        name: "GameOver")
      
      overlay.addChild(gameOverLabel)
      
      let clickToRestartLabel = LabelNode(
        position: CGPoint(x: gameOverLabel.position.x, y: gameOverLabel.position.y - 24.0),
        size: 14,
        color: .whiteColor(),
        text: "Tap to restart",
        name: "GameOver")
      
      overlay.addChild(clickToRestartLabel)
    }
    physicsWorld.contactDelegate = nil
  }
  
  
  func switchToRestartLevel() {
    gameState = GameState.RestartLevel
    if let overlay = sceneView.overlaySKScene {
      
      // Fade out game over screen
      overlay.enumerateChildNodesWithName("GameOver", usingBlock: { node, stop in
        node.runAction(SKAction.sequence(
          [SKAction.fadeOutWithDuration(0.25),
            SKAction.removeFromParent()]))
      })
      
      // Fade to black - and create a new level to play
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
    
  }
  
  
  func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
    
  }
  
  
  func spawnCarAtPosition(position: SCNVector3) {
    
  }
  
  
  // MARK: Touch Handling
  func handleTap(gesture: UIGestureRecognizer) {
    if let tapGesture = gesture as? UITapGestureRecognizer {
      movePlayerInDirection(.Forward)
    }
  }
  
  
  func handleSwipe(gesture: UIGestureRecognizer) {
    if let swipeGesture = gesture as? UISwipeGestureRecognizer {
      switch swipeGesture.direction {
      case UISwipeGestureRecognizerDirection.Up:
        movePlayerInDirection(.Forward)
        break
        
      case UISwipeGestureRecognizerDirection.Down:
        movePlayerInDirection(.Backward)
        break
        
      case UISwipeGestureRecognizerDirection.Left:
        movePlayerInDirection(.Left)
        break
        
      case UISwipeGestureRecognizerDirection.Right:
        movePlayerInDirection(.Right)
        break
        
      default:
        break
      }
    }
  }
  
  
  // MARK: Player movement
  func movePlayerInDirection(direction: MoveDirection) {
    
    switch gameState {
    case .WaitingForFirstTap:
      
      // Start playing
      switchToPlaying()
      movePlayerInDirection(direction)
      break
      
    case .Playing:
      
      // Check for player movement
      
      break
      
    case .GameOver:
      
      // Switch to tutorial
      switchToRestartLevel()
      break
      
    case .RestartLevel:
      
      // Switch to new level
      switchToWaitingForFirstTap()
      break
      
    default:
      break
    }
    
  }
  
}
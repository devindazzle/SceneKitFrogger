//
//  GameViewController.swift
//  RWDevConSceneKitFinal
//
//  Created by Kim Pedersen on 24/11/14.
//  Copyright (c) 2014 RWDevCon. All rights reserved.
//

import SceneKit
import SpriteKit

class GameViewController: UIViewController {
  
  var scnView: SCNView {
    get {
      return self.view as SCNView
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    
    super.viewDidAppear(animated)
    
    // Set up the SCNView
    scnView.backgroundColor = UIColor(red: 100.0/255.0, green: 149.0/255.0, blue: 237.0/255.0, alpha: 1.0)
    scnView.showsStatistics = true
    scnView.allowsCameraControl = false
    scnView.antialiasingMode = SCNAntialiasingMode.Multisampling2X
    scnView.playing = true
    
    // Set up the scene
    let scene = GameScene(view: scnView)
    scene.rootNode.hidden = true
    scene.physicsWorld.contactDelegate = scene
    
    // Start playing the scene
    scnView.scene = scene
    scnView.overlaySKScene = SKScene(size: view.bounds.size)
    scnView.delegate = scene
    scnView.scene!.rootNode.hidden = false
    scnView.play(self)
  }
  
  
  override func shouldAutorotate() -> Bool {
    return true
  }
  
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  override func supportedInterfaceOrientations() -> Int {
    return Int(UIInterfaceOrientationMask.Portrait.rawValue)
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
}

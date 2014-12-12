# 208: Scene Kit, Part 2: Demo Instructions

In this demo, you will add some basic gameplay elements to SCNFrogger.
The steps here will be explained in the demo, but here are the raw steps in case you miss a step or get stuck.

## 1) Prepare project

Locate the resources for this tutorial and copy the folder **1-Starter** to the desktop or other location.

Open the project in Xcode, and do a quick build and run. You should see a blue screen with an animated hand on screen.


## 2) Add player

At the top of **GameScene.swift**, add to bottom of the list of properties:

	var player: SCNNode!
	
In `setupPlayer`, add the following:

	player = SCNNode()
    player.name = "Player"
    player.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
    player.position = SCNVector3(x: 0.0, y: 0.05, z: -1.5)
    rootNode.addChildNode(player)
    
Build and run, then use the following gestures to interact with your scene:

* **Pan** (One finger): Rotates the camera
* **Pan** (Two fingers): Pans the camera
* **Pinch**: Zooms in/out

## 3) Add a camera

In `setupCamera`, add the following:

	camera = SCNNode()
    camera.name = "Camera"
    camera.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
    camera.camera = SCNCamera()
    rootNode.addChildNode(camera)
	
Build and run - The player is now visible

## 4) Add a material to the player

In `setupPlayer`, add the following just before the line `rootNode.addChildNode(player)`

    let playerMaterial = SCNMaterial()
    playerMaterial.diffuse.contents = UIColor.lightGrayColor()
    playerMaterial.locksAmbientWithDiffuse = false
    player.geometry!.firstMaterial = playerMaterial

Build and run. The player is now a light gray color and shaded.

## 5) A better camera

Change `setupCamera` to the following:

	camera = SCNNode()
	camera.name = "Camera"
	camera.position = cameraOffsetFromPlayer
	camera.camera = SCNCamera()
	camera.camera!.usesOrthographicProjection = true
	camera.camera!.orthographicScale = cameraOrthographicScale
	camera.camera!.zNear = 0.05
	camera.camera!.zFar = 150.0
	rootNode.addChildNode(camera)

Build and run. The box is gone.

## 6) Making the camera look at the player

Still in `setupCamera`, add the following at the end of the method:

	camera.constraints = [SCNLookAtConstraint(target: player)]
	
The camera will now look at the player and the scene now has an isometric view.

## 7) Disabling default camera controls

Open **GameViewContoller.swift** in the **Helpers** group and remove the default camera controls by deleting the following line:

	scnView.allowsCameraControl = true
	
## 8) Adding movement with gestures

SS
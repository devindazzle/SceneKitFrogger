# 208: Scene Kit, Part 2: Demo Instructions

In this demo, you will prepare the scene for SCNFrogger so that it is ready for adding gameplay.

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
	
	Build and run. Camera now gives an isometric view

## 7) Loading geometry from a file

The 3D models you will be using in this tutorial are placed in the folder **Models** in the **assets.scnassets** folder.

The models were made using MagicaVoxel and Blender. These applications are both free and open souce. You will find links to these applications at the bottom of this file in case you want to make your own models later.

At the top of **GameScene.swift**, add to bottom of the list of properties:

	let playerScene = SCNScene(named: "assets.scnassets/Models/frog.dae")

Go to `setupPlayer()` and modify the `line player = SCNNode()` to the following:

	player = playerScene!.rootNode.childNodeWithName("Frog", recursively: false)
	
Delete the following line:

	player.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)****

## 8) Assigning a texture to the geometry

Still in `setupPlayer()`, change the line

	playerMaterial.diffuse.contents = UIColor.lightGrayColor()

to:

	playerMaterial.diffuse.contents = UIImage(named: "assets.scnassets/Textures/model_texture.tga")

## 9) Adding the level

In setupLevel(), add the following code:

	levelData = GameLevel(width: levelWidth, height: levelHeight)
	levelData.setupLevelAtPosition(SCNVector3Zero, parentNode: rootNode)
	levelData.spawnDelegate = self

## 10) Positioning the player in the level

Go back to **GameScene.swift**, and add to bottom of the list of properties:

	var playerGridCol = 7
	var playerGridRow = 6
	
Go to setupPlayer and change the line:

	player.position = SCNVector3(x: 0.0, y: 0.05, z: -1.5)
	
to:

	player.position = levelData.coordinatesForGridPosition(column: playerGridCol, row: playerGridRow)
	
## 11) That's it!

Congrats, at this time you should have the scene set up for adding movement to the game and learned a lot about Scene Kit along the way. You are now ready for the Lab.

## 12) Links to applications

The applications used for creating the 3D models in this tutorial can be found here:

* MagicaVoxel: [https://voxel.codeplex.com/]()
* Blender: [http://www.blender.org/]()
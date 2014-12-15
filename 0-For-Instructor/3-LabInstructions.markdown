# 208: Scene Kit, Part 3: Lab Instructions

At this point, you have the basic structure of the game set up for SCNFrogger.



All the changes to the game you will make in the Lab will be in **GameScene.swift**.

## Adjusting the camera

You'll start by adjusting the camera to follow the player. In `setupCamera()`, change the line `rootNode.addChildNode(camera)` to:

	player.addChildNode(camera)
	
This makes the camera a child node of the player which will make the camera move when the player (parent) node moves.

The effect will not be noticable until you are able to move the player. That will be your next task.


## Making a move

Add this to the `.Playing` case inside the switch statement in `movePlayerInDirection(direction:)`:

	// 1 - Check for player movement
	let gridColumnAndRowAfterMove = levelData.gridColumnAndRowAfterMoveInDirection(direction, currentGridColumn: playerGridCol, currentGridRow: playerGridRow)
      
	if gridColumnAndRowAfterMove.didMove == false {
		return
	}
	
	// 2 - Set the new player grid position
	playerGridCol = gridColumnAndRowAfterMove.newGridColumn
	playerGridRow = gridColumnAndRowAfterMove.newGridRow
	
	// 3 - Calculate the scene coordinates for the player after the move
	var newPlayerPosition = levelData.coordinatesForGridPosition(column: playerGridCol, row: playerGridRow)
	newPlayerPosition.y = 0.2
	
	// 4 - Move player
	let moveAction = SCNAction.moveTo(newPlayerPosition, duration: 0.2)
	let jumpUpAction = SCNAction.moveBy(SCNVector3(x: 0.0, y: 0.2, z: 0.0), duration: 0.1)
	jumpUpAction.timingMode = SCNActionTimingMode.EaseInEaseOut
	let jumpDownAction = SCNAction.moveBy(SCNVector3(x: 0.0, y: -0.2, z: 0.0), duration: 0.1)
	jumpDownAction.timingMode = SCNActionTimingMode.EaseInEaseOut
	let jumpAction = SCNAction.sequence([jumpUpAction, jumpDownAction])
	
	player.runAction(SCNAction.group([moveAction, jumpAction]))

There is a lot of code here, so let's go through it step-by-step:

1. This uses a convinience method in the **GameLevel** class in the Helpers group to check if the player can move in the given direction from the current grid position. The method returns a tuple that contains information about the success of the move as well as the grid coordinate the user should move to. If the move was unsuccessful (`didMove == false`) then no further will be done and it just returns.

2. As the move was a success the new grid column and row returned in the tuple from step 1 is stored for the player.

3. Based on the new grid position, the scene coordinates are calculated using another convinience method in the **GameLevel** class. This will only return the x and z coordinates so the y-coordinate has to be set manually.

4. Last, you define and run a set of actions. `moveAction` will move the player to the new scene coordinates you calculated in step 3. Frogs don't crawl, so you also define two actions (`jumpUpAction`, `jumpDownAction`) that will bounce the player giving the illusion of the frog jumping.

Note that you set the timing mode on the jump actions to Ease Out (start fast, get slower over time) and Ease In (start slow, get faster over time) for a more natural curve.

Do another build and run and move the frog around. Something is clearly wrong with the camera. When the frog moves it looks like the level bounces and not the frog. What gives?


## Jumpy-camera

Remember when you made the camera a child of the player in the first part of the Lab? That is the reason for the visual odd-behavior.

The simple explanation is, when the player jumps, the camera also jumps. Therefore, from the view of the camera, the player did not move, but everything else did.

To fix this, you need to make some adjustments to how you set up the player. 

At the top of **GameScene.swift**, add the following property:

	var playerChildNode: SCNNode!

Then go to `setupPlayer()`, and modify it to look like the following:

	func setupPlayer() {
		// 1 - Player is now just a simple node with no geometry
		player = SCNNode()
		player.name = "Player"
		player.position = levelData.coordinatesForGridPosition(column: playerGridCol, row: playerGridRow)
		player.position.y = 0.2
		
		let playerMaterial = SCNMaterial()
		playerMaterial.diffuse.contents = UIImage(named: "assets.scnassets/Textures/model_texture.tga")
		playerMaterial.locksAmbientWithDiffuse = false
		
		// 2 - Create a second node containing the geometry and assign the material to the geometry of the second node.
		playerChildNode = playerScene!.rootNode.childNodeWithName("Frog", recursively: false)!
		playerChildNode.geometry!.firstMaterial = playerMaterial
		playerChildNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.075)
		
		// 3 - Add the second node as a child node of the player node
		player.addChildNode(playerChildNode)
		
		rootNode.addChildNode(player)
	}

You have made 3 modifications to the `setupPlayer()` method:

1. You changed the `player` node from a node loaded from a file to a simple `SCNNode`. This node will act as a parent node and the one you will move around.
2. Instead of loading the frog node into the player node, you load it into a second node and assign the material to this node's geometry. You also move it slightly backwards to make it align properly in the level.
3. The second node is added as a child node of the player node.

These modifications will allow you to abstract the animation of the geometry (jumping frog) from the positioning of the node in the scene. Hence, you can make the frog jump without the camera following the jump.

Before this works, you have to go back to `movePlayerInDirection(direction:)` and make some modifications to the actions you created earlier.

Change `player.runAction(SCNAction.group([moveAction, jumpAction]))` to:

	player.runAction(moveAction)

Just after that line, add the following code:

	playerChildNode.runAction(jumpAction)

Now, the movement of the player is done on the `player` node, while the jump action is done on the `playerChildNode`.

Build and run. Now only the frog is jumping. Also, try jumping all the way to the end of the level.


## End of level

If you tried jumping all the way to the end of the level you will have noticed that the game does not end. You'll need to add some code to check for that.

Scene Kit provide a delegate `SCNSceneRendererDelegate` that contains a number of methods that are called at specific times during the frame processing of a scene.

![](./3-LabImages/SCNSceneRendererDelegate.png)

**renderer:updateAtTime:** will be called exactly once every frame and is the same as the update method in Sprite Kit. This is where you will implement game logic into your rendering loop.

In **GameScene.swift**, add the following code to renderer(_:didRenderScene:atTime:):

	if gameState == GameState.Playing && playerGridRow == levelData.data.rowCount() - 6 {
		// player completed the level
		switchToGameOver()
	}

This is a simple check to test if the player reached the sixth-last row in the level. Since the five last rows consists purely of trees, the sixth-last row is the last row of the level. When the player reaches the last row the game ends.


## Let's get physical

Add physics bodies

Set up physicsContactDelegate


## End of lab

Congratulations. You have now added the code to make the player move using SCNActions, made the camera follow the player and to check for the player reaching the end of the level. In the Challenge session next, you will use all of this knowledge to add cars onto the roads for the player to avoid.
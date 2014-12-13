# 208: Scene Kit, Part 3: Lab Instructions

At this point, you have the basic structure of the game set up for SCNFrogger.



All the changes to the game you will make in the Lab will be in **GameScene.swift**.

## Adjusting the camera

You'll start by adjusting the camera to follow the player. In `setupCamera()`, change the line `rootNode.addChildNode(camera)` to:

	player.addChildNode(camera)
	
This makes the camera a child node of the player which will make the camera move when the player (parent) node moves.

The effect will not be noticable until you are able to move the player. That will be your next task.


## Making a move

Add this to the `.Playing` case inside the switch statement in movePlayerInDirection(direction:):

	// 1 - Check for player movement
	let gridColumnAndRowAfterMove = levelData.gridColumnAndRowAfterMoveInDirection(direction, currentGridColumn: playerGridCol, currentGridRow: playerGridRow)
      
	if gridColumnAndRowAfterMove.didMove == false {
		return
	}
	
	// 2 - Set the new player grid position
	playerGridCol = gridColumnAndRowAfterMove.newGridColumn
	playerGridRow = gridColumnAndRowAfterMove.newGridRow
	
	// 3 - Calculate the coordinates for the player after the move
	var newPlayerPosition = levelData.coordinatesForGridPosition(column: playerGridCol, row: playerGridRow)
	newPlayerPosition.y = 0.2
	
	// 4 - Move player
	let moveAction = SCNAction.moveTo(newPlayerPosition, duration: 0.2)
	let jumpUpAction = SCNAction.moveBy(SCNVector3(x: 0.0, y: 0.4, z: 0.0), duration: 0.1)
	jumpUpAction.timingMode = SCNActionTimingMode.EaseInEaseOut
	let jumpDownAction = SCNAction.moveBy(SCNVector3(x: 0.0, y: -0.4, z: 0.0), duration: 0.1)
	jumpDownAction.timingMode = SCNActionTimingMode.EaseInEaseOut
	let jumpAction = SCNAction.sequence([jumpUpAction, jumpDownAction])
	
	player.runAction(SCNAction.group([moveAction, jumpAction]))

There is a lot of code here, so let's go through it step-by-step:

1.

## Fixing the movement

SS


## Smooth moves

SS


## Jumpy-camera

Modify the player node so that the camera does not jump


## End of level

Add code to check for the player reached end of level


## Let's get physical

Add physics bodies

Set up physicsContactDelegate


## End of lab

Congratulations. You have now added the code to make the player move using SCNActions, made the camera follow the player and to check for the player reaching the end of the level. In the Challenge session next, you will use all of this knowledge to add cars onto the roads for the player to avoid.
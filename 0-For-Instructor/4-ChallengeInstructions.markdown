# 208: Scene Kit, Part 4: Challenge

Your frogger-clone is starting to shape up. But there is one thing missing before this game is any fun: A challenge.
Your challenge will be to add cars to the roads based on what you have learned so far:
1. Add nodes to the scene for the cars2. Load geometry to make the cars actually look like cars3. Put a material on the car geometry to make the car look nice.4. Make the car move along the road using actions.Once you have finished this challenge, you will have made a bare-bone frogger-clone with all the basic mechanics.

## Challenge A: Nodes and geometry

The first challenge is to create a car by loading the geometry from a file for the car.

The challenge project already includes a COLLADA file for the cars called **car.dae** in the **Models** folder of **assets.scnassets**.

Start by adding this property to the top of **GameScene.swift**:

	let carScene = SCNScene(named: "assets.scnassets/Models/car.dae")
	
This simply loads the **car.dae** scene into the `carScene` property just like you did for the player in the Demo.

**GameScene.swift** already contains a method you should use for creating cars called `spawnCarAtPosition(position:)`. This is a delegate method that is called from a **GameLevel** object when a new car needs to be added to a road. A position is passed as a parameter that you will use to position the car. 

You do not need to understand how the **GameLevel** class works for this tutorial - but feel free to study it later.

Your first challenge is to write the code to add a car whenever the `spawnCarAtPosition(position:)` method is called. Two things you need to do:

1. When you create a car, you need to make it a clone of the node you get from carScene. This is done by using .clone() like so:

	`let myNode = otherNode.rootNode.childNodeWithName("Child Node Name", recursively: false)!.clone() as SCNNode`

2. When setting the position of the car node in **Challenge A**, you should use the position SCNVector3(x: 0.0, y: position.y, z: position.z). That will put the car in the middle of the road to start with so that it is visible to you when you build and run.

If you did things correctly, you should see cars appear on the roads after approximately 5 seconds.

## Challenge B: Materials

Did you get cars onto the roads? Very good! But they look a bit dull, right?

Your next challenge is to change that by adding a material to the car.You’ll add code to `spawnCarAtPosition(position:)` in this challenge by adding a material that uses the texture **model_texture.tga** in the **Models** folder in **assets.scnassets**.**Hint:** Remember how it was done in **setupPlayer()**?


## Challenge C: Actions

If you completed **Challenge B** you now have some very nice, but static, cars in your scene. Your next challenge will be to make them move by placing the cars in at the position passed to the `spawnCarAtPosition(position:)` and then choose an appropriate action to make them move at a good speed.

Use the following code to know how far to move the car:

	let moveDistance = levelData.gameLevelWidth()

This returns a Float that tells you the total width of the level.

You will also need to make the cars move in the right direction as some of the cars need to move from left-to-right while others will move from right-to-left.

To tell which direction you need to move the car, use the following code:

	let moveDirection: Float = position.x > 0.0 ? -1.0 : 1.0

This sets the moveDirection to either positive or negative 1.0 depending on whether the car starts at an x-position that is to the left or right of the center. You need to multiply this to the moveDistance.

**Extra challenge if you have time:** Rotate carNode to ensure the car is facing in the driving direction. At the moment, some cars are driving backwards.


## Challenge D: Physics and collisions

Your last challenge of the day is to create a kinematic **physicsBody** for the car so that collisions are detected if the frog and the car collides.

When creating the **physicsBody**, set the `categoryBitMask` to `PhysicsCategory.Car`. You do not need to set the collisionBitmask.

**Important:** You need to create the physicsBody after you have created the carNode but before you add the car to the scene. Otherwise, you will get unexpected results (might be a bug in Scene Kit).


## The end of the road

If you managed to get through all the challenges, you now have all the basic skills to start making your own 3D games with Scene Kit.

There are many ways you could have solved these challenges and there are no right or wrong ways. Of cause, some solutions are more performant than others but in general the most important thing is not to optimize until there is a performance issue – that is the golden rule of making games :]
If you want to see how the instructor solved these challenges you’ll find am Xcode project in the Challenge folder of the tutorial materials.
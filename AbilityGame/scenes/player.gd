extends CharacterBody2D

@export var speed = 800

func _process(delta):
	var velocity = Vector2.ZERO # speed when pressing nothing
	
	
	# changing direction when pressing a button
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	
	
	$PlayerCamera.offset.x += velocity.x * speed/3 * delta 
	if $PlayerCamera.offset.x > 250:
		$PlayerCamera.offset.x = 250
	if $PlayerCamera.offset.x < -250:
		$PlayerCamera.offset.x = -250
	
	$PlayerCamera.offset.y += velocity.y * speed/3 * delta 
	if $PlayerCamera.offset.y > 150:
		$PlayerCamera.offset.y = 150
	if $PlayerCamera.offset.y < -150:
		$PlayerCamera.offset.y = -150
	
	# normalize to prevent inconsistent movement
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta # update position
	
	
	
	
	

extends CharacterBody2D

@export var speed = 800
@export var dash_speed = 3000
var is_dashing = false
var dash_velocity

func _process(delta):
	var velocity = Vector2.ZERO # speed when pressing nothing
	
	# changing direction when pressing a button and other inputs
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_just_pressed("space") and not is_dashing and velocity.length() > 0 and $DashTimer/DashTimeout.is_stopped():
		is_dashing = true
		dash_velocity = velocity
		$DashTimer.start()
		
	
	# additional camera settings (x-achse)
	$PlayerCamera.offset.x += velocity.x * speed/3 * delta 
	if $PlayerCamera.offset.x > 250:
		$PlayerCamera.offset.x = 250
	if $PlayerCamera.offset.x < -250:
		$PlayerCamera.offset.x = -250
	
	# additional camera settings (y-achse)
	$PlayerCamera.offset.y += velocity.y * speed/3 * delta 
	if $PlayerCamera.offset.y > 150:
		$PlayerCamera.offset.y = 150
	if $PlayerCamera.offset.y < -150:
		$PlayerCamera.offset.y = -150
	
	# normalize vector to prevent inconsistent movement and apply speed
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	# dash when dashing
	if is_dashing:
		velocity = dash_velocity.normalized() * dash_speed # apply dash
		if $DashTimer.is_stopped(): 
			is_dashing = false # stop dash
			$DashTimer/DashTimeout.start() # start dash timeout
	
	position += velocity * delta # update position



	
	
	
	

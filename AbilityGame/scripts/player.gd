extends CharacterBody2D


@onready var sword = $Sword
@export var speed = 800
@export var dash_speed = 3000
var is_dashing = false
var dash_velocity: Vector2

func _physics_process(delta):
	velocity = Vector2.ZERO # speed when pressing nothing
	
	# Inputs
	velocity = Input.get_vector("left","right","up","down")
	if Input.is_action_just_pressed("space") and not is_dashing and velocity.length() > 0 and $DashTimer/DashTimeout.is_stopped():
		is_dashing = true
		dash_velocity = velocity
		$DashTimer.start()
		$DashParticles.emitting = true
	if Input.is_action_pressed("primary_mouse") and not sword.animation_player.is_playing():
		sword.attack_started()
	if Input.is_action_just_released("primary_mouse"):
		sword.attack_stopped()
	
	# set velocity final
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	else:
		$WalkAnimations.stop()
	
	# change walking animation for each direction
	if velocity.x != 0 and velocity.y != 0:
		if velocity.x == velocity.y:
			$WalkAnimations.animation = "normal_dr_ul"
			if velocity.x < 0:
				$WalkAnimations.play_backwards()
			else:
				$WalkAnimations.play()
		else:
			$WalkAnimations.animation = "normal_dl_ur"
			if velocity.x > 0:
				$WalkAnimations.play_backwards()
			else:
				$WalkAnimations.play()
	elif velocity.x != 0:
		$WalkAnimations.animation = "normal_right_left"
		if velocity.x < 0:
			$WalkAnimations.play_backwards()
		else:
			$WalkAnimations.play()
	elif velocity.y != 0:
		$WalkAnimations.animation = "normal_up_down"
		if velocity.y < 0:
				$WalkAnimations.play_backwards()
		else:
			$WalkAnimations.play()
	
	# dash when dashing
	if is_dashing:
		velocity = dash_velocity.normalized() * dash_speed # apply dash
		if $DashTimer.is_stopped(): 
			is_dashing = false # stop dash
			$DashTimer/DashTimeout.start() # start dash timeout
			$DashParticles.emitting = false
	
	
	move_and_slide()




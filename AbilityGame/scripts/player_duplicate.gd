extends Node2D


@onready var sword = $Sword
@export var speed: int = 800
var damage :=  20.0

@onready var dash_timer = $DashTimer
@onready var dash_timeout = $DashTimer/DashTimeout


var is_dashing := false
var looking_at := 0  # 0 = right, 1 = rightdown, 2 = down, 3 = leftdown, 4 = left, 5 = leftup , 6 = up, 7 = rightup

var anker_pos : Vector2
var move_frames := 13
var number : int
var op := 1


func _ready():
	sword.damage = damage



func start_dash():
		is_dashing = true
		dash_timer.start()
		$DashParticles.emitting = true
		


func _physics_process(delta):
	var velocity = Vector2.ZERO # speed when pressing nothing
	
	# Inputs
	velocity = Input.get_vector("left","right","up","down")
	if Input.is_action_just_pressed("space") and not is_dashing and velocity.length() > 0 and dash_timeout.is_stopped():
		start_dash()
	if Input.is_action_pressed("primary_mouse") and not sword.animation_player.is_playing():
		sword.attack_started()
	if Input.is_action_just_released("primary_mouse"):
		sword.attack_stopped()

	
	# set velocity final
	if velocity.length() > 0:
		velocity = velocity.normalized()
	else:
		$WalkAnimations.stop()
	
	
	# change walking animation for each direction
	if velocity.x != 0 and velocity.y != 0:
		if velocity.x == velocity.y:
			$WalkAnimations.animation = "normal_dr_ul"
			if velocity.x < 0:
				$WalkAnimations.play_backwards()
				looking_at = 5
			else:
				$WalkAnimations.play()
				looking_at = 1
		else:
			$WalkAnimations.animation = "normal_dl_ur"
			if velocity.x > 0:
				$WalkAnimations.play_backwards()
				looking_at = 7
			else:
				$WalkAnimations.play()
				looking_at = 3
	elif velocity.x != 0:
		$WalkAnimations.animation = "normal_right_left"
		if velocity.x < 0:
			$WalkAnimations.play_backwards()
			looking_at = 4
		else:
			$WalkAnimations.play()
			looking_at = 0
	elif velocity.y != 0:
		$WalkAnimations.animation = "normal_up_down"
		if velocity.y < 0:
			$WalkAnimations.play_backwards()
			looking_at = 6
		else:
			$WalkAnimations.play()
			looking_at = 2
	
	# dash when dashing
	if is_dashing:
		if dash_timer.is_stopped(): 
			is_dashing = false # stop dash
			dash_timeout.start() # start dash timeout
			$DashParticles.emitting = false
	


	if move_frames != 0:
		if number == 0:
			position += Vector2(1,1) * delta * speed * op
	
		elif number == 1:
			position += Vector2(-1,-1) * delta * speed * op
		
		elif number == 2:
			position += Vector2(-1,1) * delta * speed * op
		
		elif number == 3:
			position += Vector2(1,-1) * delta * speed * op
		move_frames -= 1
	elif op < 0:
		queue_free()
		

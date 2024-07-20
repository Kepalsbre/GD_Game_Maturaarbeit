extends CharacterBody2D

@onready var label = $HpBarComponent/Label
@onready var health_component = $HealthComponent
@onready var sword = $Sword
@export var speed: int = 800

@onready var slot_1 = $EquippedAbilities/Slot1
@onready var slot_2 = $EquippedAbilities/Slot2
@onready var slot_3 = $EquippedAbilities/Slot3
@onready var slot_4 = $EquippedAbilities/Slot4
@onready var equipped_abilities = $EquippedAbilities



var dash_speed: int:
	get:
		return speed + 2200
var is_dashing := false
var dash_velocity: Vector2

var knock_frames := 0
var knockback_received := Vector2.ZERO


func knock_back(knockforce, knock_pos):
	knockback_received = (global_position - knock_pos) 
	knockback_received = knockback_received.normalized() * speed * knockforce
	knock_frames = 10


func _process(_delta):
	label.text = str(health_component.health) + "/" + str(health_component.max_health)


func _physics_process(_delta):
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
	# if Input.is_action_just_pressed("e"):
		# sword.lvlup()
	if Input.is_action_just_pressed("secondary_mouse"):
		if slot_1.get_child_count() != 0:
			slot_1.get_child(0).execute()
	elif Input.is_action_just_pressed("shift"):
		if slot_2.get_child_count() != 0:
			slot_2.get_child(0).execute()
	elif Input.is_action_just_pressed("e"):
		if slot_3.get_child_count() != 0:
			slot_3.get_child(0).execute()
	elif Input.is_action_just_pressed("q"):
		if slot_4.get_child_count() != 0:
			slot_4.get_child(0).execute()
	
	
	
	
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
	
	if knock_frames != 0:
		knock_frames -= 1
		velocity += knockback_received
	else:
		knockback_received = Vector2.ZERO
	Global.player_pos = global_position
	move_and_slide()




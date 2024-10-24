extends CharacterBody2D

@onready var label = $PlayerUI/HpBarComponent/Label
@onready var health_component = $HealthComponent
@onready var sword = $Sword
var speed: int = 800

@onready var slot_1 = $EquippedAbilities/Slot1
@onready var slot_2 = $EquippedAbilities/Slot2
@onready var slot_3 = $EquippedAbilities/Slot3
@onready var slot_4 = $EquippedAbilities/Slot4
@onready var equipped_abilities = $EquippedAbilities
@onready var hitbox_collision = $HitboxComponent/CollisionShape2D
@onready var red_timer = $RedTimer
@onready var player_image = $PlayerImage


@onready var dash_timer = $DashTimer
@onready var dash_timeout = $DashTimer/DashTimeout
const LOSE_MENU = preload("res://scenes/lose_menu.tscn")

var invincible = false
var is_dashing := false
var dash_velocity: Vector2
var dash_speed : float
var looking_at := 0  # 0 = right, 1 = rightdown, 2 = down, 3 = leftdown, 4 = left, 5 = leftup , 6 = up, 7 = rightup


var knock_frames := 0
var knockback_received := Vector2.ZERO



func knock_back(knockforce, knock_pos):
	knockback_received = (global_position - knock_pos) 
	knockback_received = knockback_received.normalized() * speed * knockforce
	knock_frames = 10


func _process(_delta):
	label.text = str(health_component.health) + "/" + str(health_component.max_health)

func start_dash(dashing_speed):
		is_dashing = true
		dash_velocity = velocity
		dash_timer.start()
		$DashParticles.emitting = true
		dash_speed = dashing_speed
		

func refresh_ability_uses():
	for slot in equipped_abilities.get_children():
		var ab = Global.inv[slot.slot_number + 11]
		if ab:
			Global.ability_uses_list[slot.slot_number -1] = ab.uses


func _physics_process(_delta):
	velocity = Vector2.ZERO # speed when pressing nothing
	
	# Inputs
	velocity = Input.get_vector("left","right","up","down")
	if Input.is_action_just_pressed("space") and not is_dashing and velocity.length() > 0 and dash_timeout.is_stopped():
		start_dash(speed + 2200)
		$DashSound.play()
	if Input.is_action_pressed("primary_mouse") and not sword.animation_player.is_playing():
		sword.attack_started()
	if Input.is_action_just_released("primary_mouse"):
		sword.attack_stopped()
	#if Input.is_action_just_pressed("scroll_up"):
		#sword.lvlup()
	if Input.is_action_just_pressed("secondary_mouse"):
		if slot_1.get_child_count() != 0:
			if slot_1.get_child(0).executing == false and Global.ability_uses_list[0] > 0:
				slot_1.get_child(0).execute()
				if slot_1.get_child(0).executing == true:
					Global.ability_uses_list[0] -= 1
	elif Input.is_action_just_pressed("shift"):
		if slot_2.get_child_count() != 0:
			if slot_2.get_child(0).executing == false and Global.ability_uses_list[1] > 0:
				slot_2.get_child(0).execute()
				if slot_2.get_child(0).executing == true:
					Global.ability_uses_list[1] -= 1
	elif Input.is_action_just_pressed("e"):
		if slot_3.get_child_count() != 0:
			if slot_3.get_child(0).executing == false and Global.ability_uses_list[2] > 0:
				slot_3.get_child(0).execute()
				if slot_3.get_child(0).executing == true:
					Global.ability_uses_list[2] -= 1
	elif Input.is_action_just_pressed("q"):
		if slot_4.get_child_count() != 0:
			if slot_4.get_child(0).executing == false and Global.ability_uses_list[3] > 0:
				slot_4.get_child(0).execute()
				if slot_4.get_child(0).executing == true:
					Global.ability_uses_list[3] -= 1
	
	
	
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
		velocity = dash_velocity.normalized() * dash_speed # apply dash
		if dash_timer.is_stopped(): 
			is_dashing = false # stop dash
			dash_timeout.start() # start dash timeout
			$DashParticles.emitting = false
	
	if knock_frames != 0:
		knock_frames -= 1
		velocity += knockback_received
	else:
		knockback_received = Vector2.ZERO
	Global.player_pos = global_position
	move_and_slide()

func heal(amount :int):
	health_component.health += amount


func _on_health_component_hitted():
	if not invincible:
		$player_hit.play()
		player_image.self_modulate = Color8(255,0,0,255)
		red_timer.start()
		invincible = true
		await get_tree().create_timer(0.8).timeout
		invincible = false


func _on_health_component_killed():
	label.text = str(health_component.health) + "/" + str(health_component.max_health)
	get_tree().root.add_child(LOSE_MENU.instantiate())


func _on_red_timer_timeout():
	player_image.self_modulate = Color8(255,255,255,255)

extends CharacterBody2D

enum state {idle, seek, attack}
enum canon_state {default, spin}
@export var current_canon_state : canon_state = canon_state.default
@export var current_state: state = state.idle
@export var wake_lenght := 400

@export var knockback: float = 1.0:
	get:
		return knockback * Global.enemy_knockback_multiplier
@export var damage: float = 20.0:
	get:
		return damage * Global.enemy_dmg_multiplier

@onready var follow_animation = $FollowAnimation
@onready var idle_image = $IdleImage
@onready var animation_player = $Canon/AnimationPlayer

@onready var health_component = $HealthComponent
@onready var offset_timer = $OffsetTimer
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var canon = $Canon
@onready var bullet_spawnpos = $Canon/BulletSpawnpos


const ENEMY_BULLET = preload("res://scenes/enemy_bullet.tscn")

@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var attack_shot = $AttackShot





var player_pos
var speed : int = randi_range(200, 280)
var offset : Vector2
var knockback_received := Vector2.ZERO
var awake := false
var knock_frames := 0
var rotation_speed := 7
var slower = 1.0

signal wake_up

func _ready():
	canon.visible = false
	follow_animation.visible = false
	
	for enemy in get_parent().get_children():
		enemy.wake_up.connect(_on_wake_up)
	health_component.max_health *= Global.enemy_hp_multiplier
	health_component.health *= Global.enemy_hp_multiplier
	navigation_agent_2d.max_speed = speed
	

func _physics_process(delta):
	player_pos = Global.player_pos
	match current_state:
		state.idle:
			if global_position.distance_to(player_pos) < wake_lenght \
			or health_component.max_health != health_component.health \
			or awake:
				follow_animation.play("default")
				current_state = state.seek
				idle_image.visible = false
				follow_animation.visible = true
				canon.visible = true
				offset = randoffset()
				offset_timer.start()
				wake_up.emit()
		state.seek:
			navigation_agent_2d.target_position = player_pos + offset
			var current_agent_position = global_position
			var next_agent_position = navigation_agent_2d.get_next_path_position()
			
			var new_velocity = current_agent_position.direction_to(next_agent_position) * speed + knockback_received
			navigation_agent_2d.set_velocity(new_velocity)
			
		state.attack:
			velocity = Vector2.ZERO
			if global_position.distance_to(player_pos) > 600:
				current_state = state.seek
	
			
	# knockback stuff
	if knock_frames != 0:
		knock_frames -= 1
		velocity = knockback_received
	else:
		knockback_received = Vector2.ZERO
		
	if current_state != state.idle:
		update_canon(delta)
	
	move_and_slide()
	

func randoffset():
	var angle = randi_range(0, 360)
	var distance = randi_range(30,200)
	return Vector2(distance * cos(angle), distance * sin(angle)) # polar to cartesian

func _on_offset_timer_timeout():
	offset = randoffset()

func knock_back(knockforce, knock_pos):
	knockback_received = (global_position - knock_pos) 
	knockback_received = knockback_received.normalized() * (speed / 4) * knockforce
	knock_frames = 20
	
func _on_wake_up():
	await get_tree().create_timer(randf_range(1,15)).timeout
	awake = true
	
func _on_navigation_agent_2d_target_reached():
	current_state = state.attack


func create_bullet(spawn_pos):
	var new_bullet = ENEMY_BULLET.instantiate()
	new_bullet.damage = damage
	new_bullet.knockback = knockback
	new_bullet.velocity = global_position.direction_to(bullet_spawnpos.global_position)
	new_bullet.position = spawn_pos
	new_bullet.scale = Vector2(7,7)
	new_bullet.super_bullet = true
	new_bullet.speed = 5000
	return new_bullet

func shoot():
	var spawn_pos = bullet_spawnpos.global_position
	get_parent().get_parent().get_node("EnemyProjectiles").add_child(create_bullet(spawn_pos))
	


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity


func _on_health_component_killed():
	hide()
	$HitboxComponent/Hitbox.set_deferred("disabled", true)
	$Collision.set_deferred("disabled", true)
	await audio_stream_player_2d.finished
	if attack_shot.playing:
		await attack_shot.finished
	queue_free()


func _on_health_component_hitted():
	audio_stream_player_2d.play()

func update_canon(delta):
	match current_canon_state:
		canon_state.default:
			if global_position.distance_to(player_pos) < 1000 and not animation_player.is_playing():
				animation_player.play("canon_shot")
				slower = 1
			
			
		canon_state.spin:
			canon.rotation_degrees += (2000 - slower)* delta
			slower += 20
			
			
	var angle_delta = rotation_speed * delta
	var angle = lerp_angle(canon.rotation, (player_pos-global_position).angle(), 1)
	angle = clamp(angle, canon.rotation - angle_delta, canon.rotation + angle_delta)
	canon.rotation = lerp_angle(canon.rotation, angle, 0.2)

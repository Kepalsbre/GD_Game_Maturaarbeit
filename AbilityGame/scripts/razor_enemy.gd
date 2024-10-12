extends CharacterBody2D


enum state {idle, seek, attack}
@export var current_state: state = state.idle
@export var wake_lenght := 400
@export var knockback: float = 3:
	get:
		return knockback * Global.enemy_knockback_multiplier
@export var damage: float = 14.0:
	get:
		return damage * Global.enemy_dmg_multiplier


@onready var idle_image = $IdleImage
@onready var body_image = $BodyImage
@onready var blades_image = $BodyImage/BladesImage
@onready var eye_image = $EyeImage
@onready var reload_animation = $ReloadAnimation
@onready var attackbox = $"HitboxComponent(attack)/Attackbox"
@onready var animation_player = $AnimationPlayer


@onready var offset_timer = $OffsetTimer
@onready var health_component = $HealthComponent
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var spin_sound = $SpinSound
@onready var spawn_in_timer = $SpawnInTimer

var attack_velocity : Vector2

var can_detect = false
var waking_up = false
var player_pos
var speed : int = randi_range(500, 580)
var offset : Vector2
var knockback_received := Vector2.ZERO
var awake := false
var knock_frames := 0

signal wake_up

func _ready():
	# disable unneeded stuff
	body_image.visible = false
	blades_image.self_modulate.a = 0
	eye_image.visible = false
	reload_animation.visible = false
	attackbox.disabled = true

	
	for enemy in get_parent().get_children():
		enemy.wake_up.connect(_on_wake_up)
	health_component.max_health *= Global.enemy_hp_multiplier
	health_component.health *= Global.enemy_hp_multiplier
	navigation_agent_2d.max_speed = speed
	
	
func _physics_process(_delta):
	player_pos = Global.player_pos
	match current_state:
		state.idle:
			if can_detect and global_position.distance_to(player_pos) < wake_lenght \
			or health_component.max_health != health_component.health \
			or awake:
				current_state = state.seek
				idle_image.visible = false
				offset = randoffset()
				offset_timer.start()
				wake_up.emit()
				
				eye_image.visible = true
				body_image.visible = true
		state.seek:
			navigation_agent_2d.target_position = player_pos + offset
			var current_agent_position = global_position
			var next_agent_position = navigation_agent_2d.get_next_path_position()
			
			var new_velocity = current_agent_position.direction_to(next_agent_position) * speed + knockback_received
			navigation_agent_2d.set_velocity(new_velocity)
			if global_position.distance_to(player_pos) < 450:
				start_attack()
				current_state = state.attack
				
			
		state.attack:
			velocity = attack_velocity.normalized() * (speed + 380)

	
	if knock_frames != 0:
		knock_frames -= 1
		velocity = knockback_received
	else:
		knockback_received = Vector2.ZERO
	move_and_slide()
	

func randoffset():
	var angle = randi_range(0, 360)
	var distance = randi_range(30,200)
	return Vector2(distance * cos(angle), distance * sin(angle)) # polar to cartesian


func _on_offset_timer_timeout():
	offset = randoffset()


func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		var hitbox : HitboxComponent = area
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		hitbox.damage(attack)

func knock_back(knockforce, knock_pos):
	knockback_received = (global_position - knock_pos) 
	knockback_received = knockback_received.normalized() * (speed / 4) * knockforce
	knockback_received /= 1.5
	knock_frames = 20 - 9
	if knockback_received.length() < 260:
		knock_frames = 0
	
	
func _on_wake_up():
	if not waking_up:
		waking_up = true
		await get_tree().create_timer(randf_range(10,26)).timeout
		awake = true


	
	

func start_attack():
	attack_velocity = (player_pos - position)
	animation_player.play("attack")
	

func stop_attack():
	attack_velocity = Vector2.ZERO
	blades_image.self_modulate.a = 0
	body_image.visible = false
	eye_image.visible = false
	reload_animation.visible = true
	reload_animation.play("default")
	

func _on_reload_animation_animation_finished():
	reload_animation.visible = false
	body_image.visible = true
	blades_image.self_modulate.a = 0
	eye_image.visible = true
	current_state = state.seek


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity


func _on_health_component_hitted():
	audio_stream_player_2d.play()


func _on_health_component_killed():
	hide()
	$"HitboxComponent(hit)"/Hitbox.set_deferred("disabled", true)
	$"HitboxComponent(attack)/Attackbox".set_deferred("disabled", true)
	$Collision.set_deferred("disabled", true)
	await audio_stream_player_2d.finished
	if spin_sound.playing:
		await spin_sound.finished
	queue_free()


func _on_hitbox_componentattack_area_entered(area):
	if area is HitboxComponent:
		var hitbox : HitboxComponent = area
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		hitbox.damage(attack)



func _on_spawn_in_timer_timeout():
	spawn_in_timer.queue_free()
	can_detect = true

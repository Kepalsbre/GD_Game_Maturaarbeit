extends CharacterBody2D

# delete "spawn" if creating new enemy
enum state {idle, seek, attack, spawn}
@export var current_state: state = state.idle
@export var wake_lenght := 800
@export var knockback: float = 1.2:
	get:
		return knockback * Global.enemy_knockback_multiplier
@export var damage: float = 8.0:
	get:
		return damage * Global.enemy_dmg_multiplier

@onready var walk_animation = $WalkAnimation
@onready var idle_image = $IdleImage
@onready var offset_timer = $OffsetTimer
@onready var health_component = $HealthComponent
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var audio_stream_player_2d = $AudioStreamPlayer2D


var player_pos
var speed : int = randi_range(400, 480)
var offset : Vector2
var knockback_received := Vector2.ZERO
var awake := false
var knock_frames := 0

# delete if creating new enemy
var spawn_frames : int
var spawn_velocity : Vector2
var hitbox_disabled := false
@onready var hitbox = $HitboxComponent/Hitbox


signal wake_up

func _ready():
	walk_animation.visible = false
	for enemy in get_parent().get_children():
		enemy.wake_up.connect(_on_wake_up)
	health_component.max_health *= Global.enemy_hp_multiplier
	health_component.health *= Global.enemy_hp_multiplier
	navigation_agent_2d.max_speed = speed
	
	# delete if creating new enemy
	hitbox.disabled = hitbox_disabled
	
	
func _physics_process(_delta):
	player_pos = Global.player_pos
	match current_state:
		state.idle:
			if global_position.distance_to(player_pos) < wake_lenght \
			or health_component.max_health != health_component.health \
			or awake:
				current_state = state.seek
				idle_image.visible = false
				walk_animation.visible = true
				offset = randoffset()
				offset_timer.start()
				walk_animation.play()
				wake_up.emit()
		state.seek:
			navigation_agent_2d.target_position = player_pos + offset
			var current_agent_position = global_position
			var next_agent_position = navigation_agent_2d.get_next_path_position()
			
			var new_velocity = current_agent_position.direction_to(next_agent_position) * speed + knockback_received
			navigation_agent_2d.set_velocity(new_velocity)
			
			
		state.attack:
			velocity = (player_pos - position)
			velocity = velocity.normalized() * speed
			if position.distance_to(player_pos) > 200:
				current_state = state.seek
		
		# delete if creating new enemy
		state.spawn:
			if idle_image.visible:
				idle_image.visible = false
				walk_animation.visible = true
			spawn_frames -= 1
			if spawn_frames == 0:
				offset = randoffset()
				offset_timer.start()
				walk_animation.play()
				hitbox.set_deferred("disabled", false)
				current_state = state.seek
			velocity = spawn_velocity
		
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

	knock_frames = 20
	
	
func _on_wake_up():
	await get_tree().create_timer(randf_range(1,15)).timeout
	awake = true
	

func _on_navigation_agent_2d_target_reached():
	current_state = state.attack



func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity


func _on_health_component_hitted():
	audio_stream_player_2d.play()


func _on_health_component_killed():
	hide()
	$HitboxComponent/Hitbox.set_deferred("disabled", true)
	$Collision.set_deferred("disabled", true)
	await audio_stream_player_2d.finished
	queue_free()


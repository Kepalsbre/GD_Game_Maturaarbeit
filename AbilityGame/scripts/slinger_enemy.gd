extends CharacterBody2D

enum state {idle, seek, attack}
@export var current_state: state = state.idle
@export var wake_lenght := 400

@export var knockback: float = 1.0:
	get:
		return knockback * Global.enemy_knockback_multiplier
@export var damage: int = 15:
	get:
		return damage * Global.enemy_dmg_multiplier

@onready var animations = $Animations
@onready var idle_image = $IdleImage
@onready var offset_timer = $OffsetTimer
@onready var health_component = $HealthComponent
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var animation_player = $AnimationPlayer
const ENEMY_BULLET = preload("res://scenes/enemy_bullet.tscn")
@onready var enemy_projectile_image = $EnemyProjectileImage
@onready var hp_bar_component = $HpBarComponent


var player_pos
var speed : int = randi_range(300, 380)
var offset : Vector2
var knockback_received := Vector2.ZERO
var awake := false
var knock_frames := 0

signal wake_up

func _ready():
	animations.visible = false
	for enemy in get_parent().get_children():
		enemy.wake_up.connect(_on_wake_up)
	health_component.max_health *= Global.enemy_hp_multiplier
	health_component.health *= Global.enemy_hp_multiplier
	hp_bar_component.top_level = true
	hp_bar_component.visible = false
	navigation_agent_2d.max_speed = speed
	
	
func _process(_delta):
	hp_bar_component.position = global_position + Vector2(-61, 85)

func _physics_process(delta):
	player_pos = Global.player_pos
	match current_state:
		state.idle:
			if global_position.distance_to(player_pos) < wake_lenght \
			or health_component.max_health != health_component.health \
			or awake:
				animations.play("follow")
				current_state = state.seek
				idle_image.visible = false
				animations.visible = true
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
			if position.distance_to(player_pos) > 1100:
				animations.play("follow")
				current_state = state.seek
				animation_player.stop()
				
	# knockback stuff
	if knock_frames != 0:
		knock_frames -= 1
		velocity = knockback_received
	else:
		knockback_received = Vector2.ZERO
	if current_state != state.idle:
		look_at(player_pos)
		
	move_and_collide(velocity*delta)
	

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
	animations.play("attack")
	animation_player.play("shoot")
	current_state = state.attack

func create_bullet(spawn_pos):
	var new_bullet = ENEMY_BULLET.instantiate()
	new_bullet.damage = damage
	new_bullet.knockback = knockback
	new_bullet.velocity = global_position.direction_to(Global.player_pos)
	new_bullet.position = spawn_pos
	new_bullet.scale = Vector2(5,5)
	return new_bullet

func shoot():
	var spawn_pos = enemy_projectile_image.global_position
	get_parent().get_parent().get_node("EnemyProjectiles").add_child(create_bullet(spawn_pos))
	


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity

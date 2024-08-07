extends CharacterBody2D

enum state {idle, seek, attack}
@export var current_state: state = state.idle
@export var wake_lenght := 600
@export var knockback: float = 1.2:
	get:
		return knockback * Global.enemy_knockback_multiplier
@export var damage: int = 10:
	get:
		return damage * Global.enemy_dmg_multiplier

@onready var animations = $Animations
@onready var idle_image = $IdleImage
@onready var offset_timer = $OffsetTimer
@onready var health_component = $HealthComponent
@onready var navigation_agent_2d = $NavigationAgent2D


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
			velocity = current_agent_position.direction_to(next_agent_position) * speed + knockback_received
		state.attack:
			velocity = Vector2.ZERO
			if position.distance_to(player_pos) > 1100:
				animations.play("follow")
				current_state = state.seek
	
	if knock_frames != 0:
		knock_frames -= 1
		velocity = knockback_received
	else:
		knockback_received = Vector2.ZERO
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
	current_state = state.attack

extends CharacterBody2D

enum state {idle, seek, attack}
@export var current_state: state = state.idle
@onready var walk_animation = $WalkAnimation
@onready var idle_image = $IdleImage
var player_pos
@export var wake_lenght := 800
@onready var offset_timer = $OffsetTimer
var speed : int = randi_range(500, 580)
var offset : Vector2
@onready var health_component = $HealthComponent
var knockback_received: float 
var knockback := 1.2
var damage = 10
var awake := false

signal wake_up

func _ready():
	walk_animation.visible = false
	for enemy in get_parent().get_children():
		enemy.wake_up.connect(_on_wake_up)
	
func _physics_process(_delta):
	player_pos = get_node("/root/Main/Player").get_global_position()
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
			velocity = (player_pos - position + offset)
			velocity = velocity.normalized() * (speed + speed * knockback_received)
			if position.distance_to(player_pos) < 200:
				current_state = state.attack
		state.attack:
			velocity = (player_pos - position)
			velocity = velocity.normalized() * (speed + speed * knockback_received)
			if position.distance_to(player_pos) > 200:
				current_state = state.seek
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


func _on_wake_up():
	await get_tree().create_timer(randf_range(1,15)).timeout
	awake = true
	
	

extends CharacterBody2D

enum state {idle, seek, attack}
@export var current_state: state = state.idle
@onready var walk_animation = $WalkAnimation
@onready var idle_image = $IdleImage
var player_pos
@export var wake_lenght := 600
@onready var offset_timer = $OffsetTimer
var speed : int = randi_range(560, 635)
var offset : Vector2

func _ready():
	walk_animation.visible = false

	
func _physics_process(delta):
	player_pos = get_node("/root/Main/Player").get_global_position()
	
	match current_state:
		state.idle:
			if global_position.distance_to(player_pos) < wake_lenght:
				current_state = state.seek
				idle_image.visible = false
				walk_animation.visible = true
				offset = randoffset()
				offset_timer.start()
		state.seek:
			walk_animation.play()
			velocity = (player_pos - position + offset)
			velocity = velocity.normalized() * speed
			
		state.attack:
			pass
	move_and_slide()

func randoffset():
	var angle = randi_range(0, 360)
	var distance = randi_range(30,200)
	return Vector2(distance * cos(angle), distance * sin(angle)) # polar to cartesian


func _on_offset_timer_timeout():
	offset = randoffset()

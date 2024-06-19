extends CharacterBody2D

enum state {idle, seek, attack}
@export var current_state: state = state.idle


func _physics_process(_delta):
	match current_state:
		state.idle:
			pass
		state.seek:
			pass
		state.attack:
			pass
	move_and_slide()

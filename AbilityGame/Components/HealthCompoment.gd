class_name HealthComponent

extends Node

@export var max_health := 100
var health: int

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# kill if health is below 0
	if health <= 0:
		get_parent().queue_free()

func hit():
	pass

extends Node2D


@onready var rockets = $Node/Rockets
@export var damage := 25.0
@export var knockback := 6.0
@export var rocketcount := 12
const ROCKET = preload("res://scenes/rocket.tscn")
@onready var points = $Points.get_children()
var exerockets := 0
var executing = false

var waitframes := 5
var waitedframes := 0

func create_rocket(spawn_pos):
	var new_rocket = ROCKET.instantiate()
	new_rocket.damage = damage
	new_rocket.knockback = knockback
	new_rocket.position = spawn_pos
	return new_rocket
	
func _physics_process(delta):
	if executing:
		if exerockets == rocketcount:
			exerockets = 0
			waitedframes = 0
			executing = false
			
		elif waitedframes == waitframes:
			var spawn_pos = points.pick_random().global_position
			rockets.add_child(create_rocket(spawn_pos))
			exerockets += 1
			waitedframes = 0
		else:
			waitedframes += 1
		
		
		
		
	if rockets.get_child_count() != 0 and is_instance_valid(Global.nearest_enemy):
		for rocket in rockets.get_children():
			rocket.target_pos = Global.nearest_enemy.global_position
		

func execute():
	if !executing:
		executing = true

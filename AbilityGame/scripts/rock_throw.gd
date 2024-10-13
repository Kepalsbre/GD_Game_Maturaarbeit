extends Node2D

@onready var rocks = $Node/Rocks
@export var damage := 65.0
@export var knockback := 3.0

const ROCK = preload("res://scenes/rock.tscn")
var executing := false

func create_rock():
	var new_rock = ROCK.instantiate()
	new_rock.damage = damage
	new_rock.knockback = knockback
	new_rock.velocity = global_position.direction_to(get_global_mouse_position())
	new_rock.position = global_position
	new_rock.scale = Vector2(5,5)
	return new_rock


func execute():
	executing = true
	rocks.add_child(create_rock())
	set_deferred("executing", false)
	

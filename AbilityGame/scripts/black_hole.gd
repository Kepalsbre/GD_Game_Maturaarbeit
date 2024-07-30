extends Node2D

@onready var black_holes = $Node/BlackHoles
@export var damage := 45.0
@export var knockback := 15.0
var speed := 400
const BLACK_HOLE_PROJECTILE = preload("res://scenes/black_hole_projectile.tscn")


func create_hole():
	var new_hole = BLACK_HOLE_PROJECTILE.instantiate()
	new_hole.speed = speed
	new_hole.damage = damage
	new_hole.knockback = knockback
	new_hole.position = Global.player_pos
	return new_hole


func execute():
	if not black_holes.get_child_count() > 0:
		black_holes.add_child(create_hole())

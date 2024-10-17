extends Node2D

@onready var black_holes = $Node/BlackHoles
@export var damage := 50.0
@export var knockback := 12.0
var speed := 400
const BLACK_HOLE_PROJECTILE = preload("res://scenes/black_hole_projectile.tscn")
var executing := false


func create_hole():
	var new_hole = BLACK_HOLE_PROJECTILE.instantiate()
	new_hole.speed = speed
	new_hole.damage = damage
	new_hole.knockback = knockback
	new_hole.position = Global.player_pos
	return new_hole


func execute():
	executing = true
	black_holes.add_child(create_hole())
	set_deferred("executing", false)

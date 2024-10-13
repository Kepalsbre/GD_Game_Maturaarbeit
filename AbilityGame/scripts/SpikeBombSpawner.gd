extends Node2D

@onready var spike_bombs = $Node/SpikeBombs
var explosion_damage = 35.0
var damage := 25.0
@export var knockback := 10.0
var speed := 800
const SPIKE_BOMB = preload("res://scenes/spike_bomb.tscn")
var executing := false


func create_spikebomb():
	var new_bomb = SPIKE_BOMB.instantiate()
	new_bomb.speed = speed
	new_bomb.damage = damage
	new_bomb.explosion_damage = explosion_damage
	new_bomb.knockback = knockback
	new_bomb.position = Global.player_pos
	new_bomb.velocity = global_position.direction_to(get_global_mouse_position())
	return new_bomb


func execute():
	executing = true
	spike_bombs.add_child(create_spikebomb())
	set_deferred("executing", false)

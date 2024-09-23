extends Node2D

var damage := 25.0
var knockback := 10.0
const PLAYER_DUPLICATE = preload("res://scenes/player_duplicate.tscn")
@onready var active_time = $ActiveTime
@onready var duplicates = $Duplicates
var executing = false


func player_duplicate(num):
	var new_player = PLAYER_DUPLICATE.instantiate()
	new_player.number = num
	new_player.move_frames = 13
	return new_player


func execute():
	if not executing:
		for i in range(4):
			duplicates.add_child(player_duplicate(i))
		active_time.start()
		executing = true


func _on_active_time_timeout():
	for child in duplicates.get_children():
		child.op = -1
		child.move_frames = 13
	executing = false

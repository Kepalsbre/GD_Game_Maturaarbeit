extends Node2D


@onready var active_time = $ActiveTime
var executing = false
@onready var player_sword = get_parent().get_parent().get_parent().get_node("Sword")


func execute():
	if not executing:
		player_sword.enable_true_form(true)
		active_time.start()
		executing = true


func _on_active_time_timeout():
	player_sword.enable_true_form(false)
	executing = false

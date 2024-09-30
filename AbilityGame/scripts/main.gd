extends Node2D

@onready var enemies = $Enemies



func _process(_delta):
	update_nearest_enemy()
	
	
func update_nearest_enemy():
	if enemies.get_child_count() != 0:
		var enemy_list = enemies.get_children()
		enemy_list.sort_custom(sort_closest)
		Global.nearest_enemy = enemy_list.front()
	

func sort_closest(a,b):
	return a.global_position.distance_to(Global.player_pos) < b.global_position.distance_to(Global.player_pos)

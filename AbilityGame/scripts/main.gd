extends Node2D

@onready var enemies = $Enemies
@onready var map = $Map
@onready var enemy_projectiles = $EnemyProjectiles
@onready var player = $Player

const spinner_scene := preload("res://scenes/spinner_enemy.tscn")
const slinger_scene := preload("res://scenes/slinger_enemy.tscn")
const razor_scene := preload("res://scenes/razor_enemy.tscn")
const blastling_scene := preload("res://scenes/blastling_enemy.tscn")

var enemies_dict := {"S" : 40, "M" : 10, "L" : 4}


var levels := [preload("res://scenes/levels/level_1.tscn")]
var current_level : PackedScene = levels[0]

func _ready():
	create_level(current_level)
	
	
	
	

func _process(_delta):
	update_nearest_enemy()



func create_level(level_scene : PackedScene):
	var new_level := level_scene.instantiate()
	clear()
	map.add_child(new_level)
	var player_positions : Array = new_level.get_node("PlayerSpawns").get_children()
	var enemy_positions : Array = new_level.get_node("EnemySpawns").get_children()
	player.position = player_positions.pick_random().global_position
	create_enemies(enemy_positions)
	
	
	


func update_nearest_enemy():
	if enemies.get_child_count() != 0:
		var enemy_list = enemies.get_children()
		enemy_list.sort_custom(sort_closest)
		Global.nearest_enemy = enemy_list.front()

func sort_closest(a,b):
	return a.global_position.distance_to(Global.player_pos) < b.global_position.distance_to(Global.player_pos)

func clear():
	for n in map.get_children():
		n.free()
	for e in enemies.get_children():
		e.free()

func sort_enemy_positions(enemy_position_list):
	var s_pos := []
	var m_pos := []
	var l_pos := []
	
	for i in enemy_position_list:
		if i.EnemyType == i.type.small:
			s_pos.append(i.global_position)
		elif i.EnemyType == i.type.medium:
			m_pos.append(i.global_position)
		elif i.EnemyType == i.type.large:
			l_pos.append(i.global_position)
	
	return [s_pos,m_pos,l_pos]

func create_packs(enemy_count : int, possible_groups : Array, group_count : int):
	var packs = []
	var enemies_left = enemy_count
	
	if enemies_left > possible_groups[-1] * group_count:
		enemies_left = possible_groups[-1] * group_count
	
	for s in range(group_count):
		if enemies_left <= 0:
			break
		 # chose if pack is empty or has enemies
		var random_pick = possible_groups.pick_random()
		if random_pick <= enemies_left:
			packs.append(random_pick)
			enemies_left -= random_pick
		else:
			packs.append(0)  # Diese Fläche bleibt leer
			
	# if enemies remain to be assigned
	while enemies_left > 0:
		for i in range(len(packs)):
			if enemies_left > 0 and packs[i] > 0:
				var add_enemy = min(possible_groups[-1] - packs[i], enemies_left)
				packs[i] += add_enemy
				enemies_left -= add_enemy
	return packs

func spawn(enemy : PackedScene, spawn_pos : Vector2):
	var new_enemy = enemy.instantiate()
	new_enemy.global_position = spawn_pos
	enemies.add_child(new_enemy)
	
	

func spawn_enemies(packs: Array, positions : Array, spawning_enemy : Array, distance : int):
	while len(packs) > 0:
		print("hel")
		var random_group = packs.pick_random()
		packs.erase(random_group)
		var random_position = positions.pick_random()
		positions.erase(random_position)
		
		match random_group:
			1:
				spawn(spawning_enemy.pick_random(), random_position)
			2:
				spawn(spawning_enemy.pick_random(), random_position + Vector2(distance,0))
				spawn(spawning_enemy.pick_random(), random_position + Vector2(-distance,0))
			3:
				spawn(spawning_enemy.pick_random(), random_position + Vector2(0,-distance))
				spawn(spawning_enemy.pick_random(), random_position + Vector2(distance,distance))
				spawn(spawning_enemy.pick_random(), random_position + Vector2(-distance,distance))
			4:
				spawn(spawning_enemy.pick_random(), random_position + Vector2(distance,-distance))
				spawn(spawning_enemy.pick_random(), random_position + Vector2(-distance,-distance))
				spawn(spawning_enemy.pick_random(), random_position + Vector2(distance,distance))
				spawn(spawning_enemy.pick_random(), random_position + Vector2(-distance,distance))

func create_enemies(enemy_positions):
	var enemy_pos_sorted : Array = sort_enemy_positions(enemy_positions)
	print(enemy_pos_sorted)
	
	var enemy_packs = [create_packs(enemies_dict["S"], [1,2,3,4], len(enemy_pos_sorted[0])),
	create_packs(enemies_dict["M"], [1,2,3], len(enemy_pos_sorted[1])),
	create_packs(enemies_dict["L"], [1,2], len(enemy_pos_sorted[2]))]
	print(enemy_packs)
	
	spawn_enemies(enemy_packs[0], enemy_pos_sorted[0], [spinner_scene], 50)
	spawn_enemies(enemy_packs[1], enemy_pos_sorted[1], [slinger_scene, razor_scene], 100)
	spawn_enemies(enemy_packs[2], enemy_pos_sorted[2], [blastling_scene], 120)
	
	
	
	
	
	

extends Node2D

@onready var enemies = $Enemies
@onready var map = $Map
@onready var enemy_projectiles = $EnemyProjectiles
@onready var player = $Player
@onready var audio_stream_player = $AudioStreamPlayer
@onready var inv_ui = player.get_node("PlayerUI").get_node("InvUI")
@onready var continue_button = $ContinueUI/Continue
@onready var instructions = $ContinueUI/Instructions



const spinner_scene := preload("res://scenes/spinner_enemy.tscn")
const slinger_scene := preload("res://scenes/slinger_enemy.tscn")
const razor_scene := preload("res://scenes/razor_enemy.tscn")
const blastling_scene := preload("res://scenes/blastling_enemy.tscn")
const LOOTBOX = preload("res://scenes/lootbox.tscn")

const SWORD_UPGRADE_ICON = preload("res://art/abilities/sword_upgrade_icon.png")
const WIN_MENU = preload("res://scenes/win_menu.tscn")

var enemies_dict := {"S" : 5, "M" : 0, "L" : 0}
var stage := 1

var lootbox_spawn_pos : Vector2
var lootbox_can_spawn := false
var next_loot 
var sword_upgrade_count := 0

var levels := [preload("res://scenes/levels/level_1.tscn"),
preload("res://scenes/levels/level_2.tscn"),
preload("res://scenes/levels/level_3.tscn"),
preload("res://scenes/levels/level_4.tscn"),
preload("res://scenes/levels/level_5.tscn"),
preload("res://scenes/levels/level_6.tscn"),
preload("res://scenes/levels/level_7.tscn"),
preload("res://scenes/levels/level_8.tscn")]
var levels_temp : Array
var next_level : PackedScene



func _ready():
	Global.ability_uses_list = [0,0,0,0]
	levels_temp = levels.duplicate()
	next_level = levels_temp[0]
	
	create_level(next_level)
	clear_inventory()
	

func _process(_delta):
	update_nearest_enemy()
	
	if enemies.get_child_count() <= 2 and not enemies.get_child_count() == 0:
		lootbox_spawn_pos = enemies.get_child(0).global_position
	
	if enemies.get_child_count() == 0:
		Global.combat = false
		if len(levels_temp) == 0:
			audio_stream_player.process_mode = Node.PROCESS_MODE_ALWAYS
			audio_stream_player.stream = load("res://music/combatwin.ogg")
			audio_stream_player.pitch_scale = 0.9
			audio_stream_player.play()
			get_tree().root.add_child(WIN_MENU.instantiate())
		elif lootbox_can_spawn:
			lootbox_can_spawn = false
			Global.ability_uses_list = [0,0,0,0]
			await get_tree().create_timer(0.5).timeout
			Global.ability_uses_list
			spawn_box()
			audio_stream_player.pitch_scale = [0.5, 0.6,0.7, 0.75, 0.8, 1, 1.15].pick_random()
			audio_stream_player.stream = load("res://music/combatwin.ogg")
			audio_stream_player.play()
			instructions.visible = true
			player.heal(35)
	
func choose_enemies():
	match stage:
		1:
			enemies_dict["S"] = 10
			enemies_dict["M"] = 1
			enemies_dict["L"] = 0
		2:
			enemies_dict["S"] = 14
			enemies_dict["M"] = 3
			enemies_dict["L"] = 0
		3:
			enemies_dict["S"] = 16
			enemies_dict["M"] = 5
			enemies_dict["L"] = 0
		4:
			enemies_dict["S"] = 18
			enemies_dict["M"] = 7
			enemies_dict["L"] = 0
		5:
			enemies_dict["S"] = 22
			enemies_dict["M"] = 8
			enemies_dict["L"] = 1
		6:
			enemies_dict["S"] = 24
			enemies_dict["M"] = 9
			enemies_dict["L"] = 1
		7:
			enemies_dict["S"] = 26
			enemies_dict["M"] = 11
			enemies_dict["L"] = 2
		8:
			enemies_dict["S"] = 30
			enemies_dict["M"] = 13
			enemies_dict["L"] = 2
	stage += 1
		


func create_level(level_scene : PackedScene):
	levels_temp.erase(level_scene)
	
	choose_enemies()
	
	continue_button.visible = false
	instructions.visible = false
	
	var new_level := level_scene.instantiate()
	clear_stuff()
	map.add_child(new_level)
	var player_positions : Array = new_level.get_node("PlayerSpawns").get_children()
	var enemy_positions : Array = new_level.get_node("EnemySpawns").get_children()
	player.position = player_positions.pick_random().global_position
	create_enemies(enemy_positions)
	Global.combat = true
	lootbox_can_spawn = true
	inv_ui.close()
	create_new_loot()
	player.refresh_ability_uses()
	
	if len(levels_temp) != 0:
		next_level = levels_temp.pick_random()



func receive_loot():
	match typeof(next_loot):
		TYPE_STRING:
			player.get_node("Sword").lvlup()
		TYPE_OBJECT:
			for i in range(Global.inv.size()):
				if Global.inv[i] == null:
					Global.inv[i] = next_loot
					inv_ui.update_slots()
					break
	continue_button.visible = true
	

func create_new_loot():
	var r = randi() % 100
	if r < 25 and sword_upgrade_count < 2:
		next_loot = "upgrade"
		sword_upgrade_count += 1
	else:
		next_loot = Global.ability_list.pick_random()
	

func spawn_box():
	var new_box = LOOTBOX.instantiate()
	new_box.global_position = lootbox_spawn_pos
	match typeof(next_loot):
		TYPE_STRING:
			new_box.loot_image_load = SWORD_UPGRADE_ICON
		TYPE_OBJECT:
			new_box.loot_image_load = next_loot.texture
	add_child(new_box)
	move_child(new_box, -2)
	new_box.looted.connect(receive_loot)
	
	

func clear_inventory():
	for i in range(Global.inv.size()):
		Global.inv[i] = null
	inv_ui.update_slots()

func update_nearest_enemy():
	if enemies.get_child_count() != 0:
		var enemy_list = enemies.get_children()
		enemy_list.sort_custom(sort_closest)
		Global.nearest_enemy = enemy_list.front()

func sort_closest(a,b):
	return a.global_position.distance_to(Global.player_pos) < b.global_position.distance_to(Global.player_pos)

func clear_stuff():
	for n in map.get_children():
		n.free()
	for e in enemies.get_children():
		e.free()
	if has_node("Lootbox"):
		get_node("Lootbox").queue_free()

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
			if enemies_left > 0 and packs[i] >= 0:
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
	#print(enemy_pos_sorted)
	
	var enemy_packs = [create_packs(enemies_dict["S"], [1,2,3,4], len(enemy_pos_sorted[0])),
	create_packs(enemies_dict["M"], [1,2,3], len(enemy_pos_sorted[1])),
	create_packs(enemies_dict["L"], [1,2], len(enemy_pos_sorted[2]))]
	#print(enemy_packs)
	
	spawn_enemies(enemy_packs[0], enemy_pos_sorted[0], [spinner_scene], 60)
	spawn_enemies(enemy_packs[1], enemy_pos_sorted[1], [slinger_scene, razor_scene], 100)
	spawn_enemies(enemy_packs[2], enemy_pos_sorted[2], [blastling_scene], 120)
	
	

func _on_continue_pressed():
	audio_stream_player.stop()
	create_level(next_level)
	

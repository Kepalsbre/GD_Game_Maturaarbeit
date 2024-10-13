extends Node

var nearest_enemy
var player_pos := Vector2.ZERO
var enemy_hp_multiplier := 1.0
var enemy_knockback_multiplier := 1.0
var enemy_dmg_multiplier := 1.0
var inv: Array =  preload("res://inventory/playerinv.tres").abilities

var is_fullscreen := false
var sfx_value := 1.0
var music_value := 1.0
var master_value := 1.0

var combat := false

var ability_uses_list := [0,0,0,0]

var ability_list := [preload("res://inventory/ability_resources/barrage.tres"),
preload("res://inventory/ability_resources/black_hole.tres"),
preload("res://inventory/ability_resources/Duplicate.tres"),
preload("res://inventory/ability_resources/pushback.tres"),
preload("res://inventory/ability_resources/rock_throw.tres"),
preload("res://inventory/ability_resources/shotgun.tres"),
preload("res://inventory/ability_resources/spike_bomb.tres"),
preload("res://inventory/ability_resources/superdash.tres"), 
preload("res://inventory/ability_resources/true_form.tres")]

var ability_dict := {
	"Pushback" : preload("res://scenes/pushback.tscn"),
	"Superdash" : preload("res://scenes/superdash.tscn"),
	"Barrage" : preload("res://scenes/barrage.tscn"),
	"Black Hole" : preload("res://scenes/black_hole.tscn"),
	"Rock Throw" : preload("res://scenes/rock_throw.tscn"),
	"Spikebomb" : preload("res://scenes/spike_bomb_spawner.tscn"),
	"Duplicate" : preload("res://scenes/duplicate.tscn"),
	"True Form" : preload("res://scenes/true_form.tscn"),
	"Shotgun" : preload("res://scenes/shotgun.tscn")
}


extends Node

var nearest_enemy
var player_pos := Vector2.ZERO
var enemy_hp_multiplier := 1
var enemy_knockback_multiplier := 1
var enemy_dmg_multiplier := 1
var inv: Array = preload("res://inventory/playerinv.tres").abilities


var ability_dict = {
	"Pushback" : preload("res://scenes/pushback.tscn"),
	"Superdash" : preload("res://scenes/superdash.tscn"),
	"Barrage" : preload("res://scenes/barrage.tscn")
}
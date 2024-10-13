extends Control

@onready var difficulty_label = $DifficultyLabel
@onready var difficulty_animation = $Control/DifficultyAnimation
@onready var buttons_difficulty = $ButtonsDifficulty
@onready var buttons_main = $ButtonsMain
@onready var buttons_options = $ButtonsOptions
@onready var game_label = $GameLabel

@onready var audio_slider = $ButtonsOptions/VBoxContainer/AudioSlider
@onready var music_slider = $ButtonsOptions/VBoxContainer2/MusicSlider
@onready var sfx_slider = $ButtonsOptions/VBoxContainer3/SFXSlider


var difficulty_text = "normal"
var game_title := "one-wheel circuit"
var bus_index_master : int
var bus_index_music : int
var bus_index_sounds : int


func _ready():
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	buttons_options.visible = false
	buttons_main.visible = true
	buttons_difficulty.visible = false
	game_label.text = game_title
	difficulty_animation.visible = false
	difficulty_label.visible = false
	update_difficulty_label()
	
	bus_index_master = AudioServer.get_bus_index("Master")
	bus_index_music = AudioServer.get_bus_index("Music")
	bus_index_sounds = AudioServer.get_bus_index("sfx")
	
	music_slider.value = Global.music_value
	sfx_slider.value = Global.sfx_value
	audio_slider.value = Global.master_value
	$ButtonsOptions/CheckBox.button_pressed = Global.is_fullscreen




func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_pressed():
	buttons_main.visible = false
	
	game_label.text = "Options"
	buttons_options.visible = true


func _on_exit_pressed():
	get_tree().quit()

func _on_button_mouse_entered():
	$Buttonhover.play()


func _on_difficulty_pressed():
	game_label.text = "Difficulty"
	buttons_main.visible = false
	buttons_difficulty.visible = true
	difficulty_label.visible = true
	difficulty_animation.visible = true
	difficulty_animation.play()

func _on_options_back_pressed():
	game_label.text = game_title
	buttons_options.visible = false
	
	buttons_main.visible = true


func _on_fullscreen_check_box_toggled(toggled_on):
	if not toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Global.is_fullscreen = toggled_on
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		Global.is_fullscreen = toggled_on


func _on_audio_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_master, linear_to_db(value))
	Global.master_value = value


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_music, linear_to_db(value))
	Global.music_value = value


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_sounds, linear_to_db(value))
	Global.sfx_value = value


func _on_difficulty_back_pressed():
	game_label.text = game_title
	buttons_main.visible = true
	buttons_difficulty.visible = false
	difficulty_animation.visible = false
	difficulty_label.visible = false
	difficulty_animation.stop()


func _on_easy_pressed():
	difficulty_animation.animation = "easy"
	difficulty_text = "easy"
	Global.enemy_dmg_multiplier = 0.5
	Global.enemy_hp_multiplier = 0.5
	Global.enemy_knockback_multiplier = 0.8
	update_difficulty_label()

func _on_normal_pressed():
	difficulty_animation.animation = "normal"
	difficulty_text = "normal"
	Global.enemy_dmg_multiplier = 1.0
	Global.enemy_hp_multiplier = 1.0
	Global.enemy_knockback_multiplier = 1.0
	update_difficulty_label()


func _on_hard_pressed():
	difficulty_animation.animation = "hard"
	difficulty_text = "hard"
	Global.enemy_dmg_multiplier = 1.5
	Global.enemy_hp_multiplier = 1.5
	Global.enemy_knockback_multiplier = 1.2
	update_difficulty_label()


func update_difficulty_label():
	difficulty_label.text = str(difficulty_text) + "\n\nEnemy HP: " + str(Global.enemy_hp_multiplier) + "x\nEnemy dmg: " + str(Global.enemy_dmg_multiplier) + "x\nEnemy KB: " + str(Global.enemy_knockback_multiplier) + "x"

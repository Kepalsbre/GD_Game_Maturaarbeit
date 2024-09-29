extends Control

@onready var buttons_main = $ButtonsMain
@onready var buttons_options = $ButtonsOptions
@onready var game_label = $GameLabel
var game_title := "Armed Circuit"
var bus_index_master : int
var bus_index_music : int
var bus_index_sounds : int

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	buttons_options.visible = false
	buttons_main.visible = true
	game_label.text = game_title
	
	bus_index_master = AudioServer.get_bus_index("Master")
	bus_index_music = AudioServer.get_bus_index("Music")
	bus_index_sounds = AudioServer.get_bus_index("sfx")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
	pass # Replace with function body.


func _on_options_back_pressed():
	game_label.text = game_title
	buttons_options.visible = false
	
	buttons_main.visible = true
	
	


func _on_fullscreen_check_box_toggled(toggled_on):
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_audio_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_master, linear_to_db(value))


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_music, linear_to_db(value))


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_sounds, linear_to_db(value))

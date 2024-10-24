extends Control


@onready var audio_slider = $CanvasLayer/ButtonsOptions/VBoxContainer/AudioSlider
@onready var music_slider = $CanvasLayer/ButtonsOptions/VBoxContainer2/MusicSlider
@onready var sfx_slider = $CanvasLayer/ButtonsOptions/VBoxContainer3/SFXSlider
@onready var check_box = $CanvasLayer/ButtonsOptions/CheckBox

var bus_index_master : int
var bus_index_music : int
var bus_index_sounds : int


func free_queue():
	get_tree().paused = false
	queue_free()
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	
	music_slider.value = Global.music_value
	sfx_slider.value = Global.sfx_value
	audio_slider.value = Global.master_value
	
	bus_index_master = AudioServer.get_bus_index("Master")
	bus_index_music = AudioServer.get_bus_index("Music")
	bus_index_sounds = AudioServer.get_bus_index("sfx")
	
	check_box.button_pressed = Global.is_fullscreen
	refresh_audio()
	get_tree().paused = true
	$CanvasLayer/ButtonsOptions/SmartSword.button_pressed = Global.smart_sword

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("esc"):
		free_queue()


func _on_quit_pressed():
	get_tree().quit()


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	free_queue()


func _on_resume_pressed():
	free_queue()

func _on_button_mouse_entered():
	$Buttonhover.play()

func refresh_audio():
	AudioServer.set_bus_volume_db(bus_index_master, linear_to_db(Global.master_value))
	AudioServer.set_bus_volume_db(bus_index_music, linear_to_db(Global.music_value))
	AudioServer.set_bus_volume_db(bus_index_sounds, linear_to_db(Global.sfx_value))


func _on_audio_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_master, linear_to_db(value))
	Global.master_value = value


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_music, linear_to_db(value))
	Global.music_value = value


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_sounds, linear_to_db(value))
	Global.sfx_value = value


func _on_fullscreen_check_box_toggled(toggled_on):
	if not toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Global.is_fullscreen = toggled_on
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		Global.is_fullscreen = toggled_on


func _on_smart_sword_toggled(toggled_on):
	Global.smart_sword = toggled_on

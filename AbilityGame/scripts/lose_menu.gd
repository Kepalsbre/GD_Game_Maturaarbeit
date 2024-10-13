extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	


func free_queue():
	get_tree().paused = false
	queue_free()
	

func _on_quit_pressed():
	get_tree().quit()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	free_queue()
	
func _on_button_mouse_entered():
	$Buttonhover.play()

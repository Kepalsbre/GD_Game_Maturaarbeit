extends Node2D

@onready var active_time = $ActiveTime
var executing = false
@onready var player_sword = get_parent().get_parent().get_parent().get_node("Sword")


func execute():
	if not executing:
		player_sword.enable_true_form(true)
		active_time.start()
		$TransformSound.play()
		executing = true


func _on_active_time_timeout():
	player_sword.enable_true_form(false)
	$BacktransformSound.play()
	executing = false

# backtransform when battle ended
func stop():
	_on_active_time_timeout()

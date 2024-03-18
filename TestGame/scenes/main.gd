extends Node

@export var mob_scene: PackedScene
var score

func _ready():
	pass

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$RecordMusic.stop()
	$Record2Music.stop()
	$DeathSound.play()
	
	
func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready, Blud!")
	get_tree().call_group("mobs", "queue_free")
	$Music.play()
	$DeathSound.stop()
	

func game_start():
	$MobTimer.start()
	$ScoreTimer.start()


func score_timer():
	score += 1
	$HUD.update_score(score)
	if score == 18:
		$Record2Music.stop()
		$RecordMusic.play()
	if score == 10:
		$Music.stop()
		$Record2Music.play()


func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate() # create mob scene
	
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf() # random location on mobspawnlocation
	
	var direction = mob_spawn_location.rotation + PI / 2 # turn point by 90
	
	mob.position = mob_spawn_location.position # set mob pos
	
	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	var velocity = Vector2(randf_range(150, 250), 0)
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)
	
	
	

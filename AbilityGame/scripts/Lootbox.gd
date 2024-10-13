extends Node2D

@onready var hp_bar_component = $HpBarComponent
@onready var health_component = $HealthComponent
@onready var hit = $Hit
@onready var open = $Open
@onready var loot_image = $LootImage

var loot_image_load
var loot : InvAbility
var move := false
const speed = 1200

signal looted

# Called when the node enters the scene tree for the first time.
func _ready():
	loot_image.visible = false
	loot_image.texture = loot_image_load


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if move:
		var image_velocity = loot_image.global_position.direction_to(Global.player_pos)
		loot_image.global_position += speed * image_velocity * delta
		if loot_image.global_position.distance_to(Global.player_pos) < 25:
			loot_image.visible = false
			move = false


func start_moving():
	move = true

func _on_health_component_killed():
	open.play()
	hp_bar_component.queue_free()
	$BoxParticles.emitting = true
	$BoxLight.enabled = false
	looted.emit()
	loot_image.visible = true
	$AnimationPlayer.play("spawn")


func _on_health_component_hitted():
	hit.play()

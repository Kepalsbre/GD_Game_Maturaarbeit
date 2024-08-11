extends Node2D

@onready var rock_image = $RockImage

var damage := 10.0
var knockback := 1.0
var speed := 1200
var velocity := Vector2.ZERO

@onready var hit = $Hit
@onready var start = $Start


func _physics_process(delta):
	global_position += velocity * delta * speed
	rock_image.rotate(deg_to_rad(360 * delta))

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		var hitbox : HitboxComponent = area
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		hitbox.damage(attack)
		free_queue()


func _on_lifetime_timeout():
	queue_free()

func free_queue():
	hide()
	$HitboxComponent/CollisionShape2D.set_deferred("disabled", true)
	hit.play()
	await hit.finished
	if start.playing == true:
		await start.finished
	queue_free()
	

extends Node2D

var damage := 10.0
var knockback := 0.0
var speed := 1350
var velocity := Vector2.ZERO

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		var hitbox : HitboxComponent = area
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		hitbox.damage(attack)
		queue_free()

func _physics_process(delta):
	global_position += velocity * delta * speed

func _on_lifetime_timeout():
	queue_free()

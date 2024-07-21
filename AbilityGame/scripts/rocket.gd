extends Node2D

var damage : float
var knockback : float

var target_pos := Vector2.ZERO
@export var speed: int = randi_range(1000, 2000)
var velocity := Vector2.UP

func _ready():
	$CPUParticles2D.emitting = true
	

func _physics_process(delta):
	look_at(target_pos)
	velocity = position.direction_to(target_pos) * speed
	global_position += velocity * delta


func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		area.damage(attack)
		queue_free()


func _on_lifetime_timeout():
	queue_free()

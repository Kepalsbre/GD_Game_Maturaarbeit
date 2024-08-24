extends Node2D

var damage := 10.0
var knockback := 0.0
var speed := 1350
var velocity := Vector2.ZERO

var super_bullet := false
@onready var particles = $Particles


func _ready():
	particles.emitting = super_bullet
	if super_bullet:
		particles.scale_amount_min = scale.x
		particles.scale_amount_max = scale.x
		particles.angular_velocity_min = 360
		particles.angular_velocity_max = 720

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
	if super_bullet:
		rotation += 20
		
		

func _on_lifetime_timeout():
	queue_free()

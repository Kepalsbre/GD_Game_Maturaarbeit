extends Area2D
class_name HitboxComponent

@export var health_component : HealthComponent


func damage(attack: Attack):
	if health_component:
		health_component.damage(attack)
	if get_parent().has_method("knock_back"):
		get_parent().knock_back(attack.knockback_force, attack.attack_position)

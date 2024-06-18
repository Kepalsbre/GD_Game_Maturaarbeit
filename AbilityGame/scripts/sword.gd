extends Node2D

@onready var sword_collision = $lvl1/HitboxComponent/CollisionShape2D
@onready var sword_image = $lvl1
@onready var animation_player = $AnimationPlayer
@export var damage := 20
@export var knockback := 100
var attacking:bool = false

func current_loop_ended():
	if not attacking:
		sword_collision.set_deferred("disabled", true)
		sword_image.visible = false
		animation_player.stop()


func attack_started():
	attacking = true
	sword_image.visible = true
	sword_collision.set_deferred("disabled", false)
	animation_player.play("attack")
	look_at(get_global_mouse_position())

	
func attack_stopped():
	attacking = false
	
	
func _on_hitbox_component_area_entered(area):
	if area.has_method("damage"):
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		area.damage(attack)

extends Node2D

@onready var sword_collision = $SwordImage/HitboxComponent/CollisionShape2D
@onready var sword_image = $SwordImage
@onready var animation_player = $AnimationPlayer
@export var damage := 20.0
@export var knockback := 1.0
var attacking:bool = false
var current_level := 1
var lvl2 = load("res://art/sword/sword_2.png")
var lvl3 = load("res://art/sword/sword_3.png")
var lvl4 = load("res://art/sword/sword_4.png")
var attack_animation = "attack"


func _ready():
	sword_image.visible = false


func lvlup():
	current_level += 1
	if current_level == 3:
		sword_image.texture = lvl2
		sword_collision.shape.height = 145
		sword_collision.position = Vector2(82, -82)
	elif current_level == 6:
		sword_image.texture = lvl3
		attack_animation = "laser_attack"
		animation_player.speed_scale += 0.2
	elif current_level == 8:
		sword_image.texture = lvl4
	else:
		damage += 5


func current_loop_ended():
	if not attacking:
		sword_collision.set_deferred("disabled", true)
		sword_image.visible = false
		animation_player.stop()
	$SwordImage/HitboxComponent.monitoring = false
	$SwordImage/HitboxComponent.monitoring = true
	
	
func attack_started():
	attacking = true
	sword_image.visible = true
	sword_collision.set_deferred("disabled", false)
	if global_position.x > get_global_mouse_position().x:
		animation_player.play_backwards(attack_animation)
	else:
		animation_player.play(attack_animation)
	look_at(get_global_mouse_position())

	
func attack_stopped():
	attacking = false
	
	
func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		area.damage(attack)

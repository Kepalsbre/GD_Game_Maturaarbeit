extends Node2D

@onready var sword_collision = $SwordImage/HitboxComponent/CollisionShape2D
@onready var sword_image = $SwordImage
@onready var animation_player = $AnimationPlayer
@export var damage := 20.0
@export var knockback := 1.0
var attacking:bool = false
var current_level := 1
var lvl1 = load("res://art/sword/sword_1.png")
var lvl2 = load("res://art/sword/sword_2.png")
var lvl3 = load("res://art/sword/sword_3.png")
var lvl4 = load("res://art/sword/sword_4.png")
var attack_animation = "attack"

var last_mouse_pos : Vector2

func _ready():
	sword_image.visible = false


func lvlup():
	current_level += 1
	if current_level == 2:
		sword_image.texture = lvl2
		sword_collision.shape.height = 145
		sword_collision.position = Vector2(82, -82)
	elif current_level == 3:
		sword_image.texture = lvl3
		attack_animation = "laser_attack"
		animation_player.speed_scale = 1.2
	else:
		#damage += 5
		pass


func current_loop_ended():
	if last_mouse_pos.distance_to(get_global_mouse_position()) > 100 and Global.smart_sword:
		look_at(get_global_mouse_position())
		last_mouse_pos = get_global_mouse_position()
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
	last_mouse_pos = get_global_mouse_position()

	
func attack_stopped():
	attacking = false
	
	
func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		area.damage(attack)

func enable_true_form(on):
	if on:
		attack_animation = "true_form"
		sword_image.texture = lvl4
		animation_player.speed_scale = 1.5
		scale = Vector2(1.5,1.5)
		if current_level == 1:
			sword_collision.shape.height = 145
			sword_collision.position = Vector2(82, -82)
	
	else:
		if current_level == 1:
			sword_image.texture = lvl1
			sword_collision.shape.height = 120
			sword_collision.position = Vector2(72, -72)
		if current_level == 2:
			sword_image.texture = lvl2
			
		attack_animation = "attack"	
		animation_player.current_animation = "attack"
		animation_player.speed_scale = 1.0
		scale = Vector2(1,1)
		
		if current_level >= 3:
			sword_image.texture = lvl3
			attack_animation = "laser_attack"
			animation_player.speed_scale = 1.2
			animation_player.current_animation = "laser_attack"
	

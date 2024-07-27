extends Node2D

@export var damage := 40.0
@export var knockback := -5.0
var speed = 300

var velocity : Vector2
var exeframes := 0
var executing = false


func _ready():
	hole_image.visible = false
	collision.disabled = true
	
func _physics_process(delta):
	if executing:
		position += velocity * delta * speed
		
		
		#if exeframes == 10:
			#hole_image.visible = false
			#collision.disabled = true
			#executing = false
			#scale = Vector2(2,2)
			#exeframes = 0
		#
		#scale += Vector2(2,2)
		#exeframes += 1
	pass
		

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		area.damage(attack)

func execute():
	if !executing:
		look_at(get_global_mouse_position())
		hole_image.visible = true
		hole_image.play("default") 
		velocity = position.direction_to(get_global_mouse_position())
		executing = true


func _on_hole_image_frame_changed():
	exeframes += 1
	if exeframes == 6:
		hit()
		exeframes = 0
		
func hit():
	collision.set_deferred("disabled", false)
	collision.set_deferred("disabled", true)

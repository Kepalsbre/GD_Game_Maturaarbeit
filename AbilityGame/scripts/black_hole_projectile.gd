extends Node2D

@onready var collision = $HitboxComponent/Collision
@onready var hole_image = $HoleImage

var current_damage := 0.0
var current_knockback := -2.5
var damage :float
var knockback :float
var speed :int 

var velocity :Vector2
var exeframes := 0
var hit_count := 0
var cycles := 0

func _ready():
	velocity = position.direction_to(get_global_mouse_position())
	look_at(get_global_mouse_position())
	collision.disabled = true


func _physics_process(delta):
	global_position += velocity * speed * delta
	
	if hit_count > 1:
		collision.set_deferred("disabled", true)
		hit_count = 0
		
		if cycles == 6:
			current_damage = damage
			current_knockback = knockback
		if cycles > 6:
			queue_free()
		
	if hit_count == 1:
		collision.set_deferred("disabled", false)
		hit_count += 1
	
	


func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		var attack = Attack.new()
		attack.attack_damage = current_damage
		attack.knockback_force = current_knockback
		attack.attack_position = global_position
		area.damage(attack)


func _on_hole_image_frame_changed():
	exeframes += 1
	if exeframes == 4:
		hit_count = 1
		cycles += 1
		exeframes = 0
		

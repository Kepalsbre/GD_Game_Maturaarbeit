extends Node2D

@export var damage := 8.0
@export var knockback := 16.0
@onready var knock_image = $KnockImage
@onready var collision = $HitboxComponent/collision
var executing = false
var exeframes := 0

func _ready():
	knock_image.visible = false
	collision.disabled = true
	
func _physics_process(delta):
	if executing:
		
		if exeframes == 10:
			knock_image.visible = false
			collision.disabled = true
			executing = false
			scale = Vector2(2,2)
			exeframes = 0
		
		scale += Vector2(2,2)
		exeframes += 1
		

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		area.damage(attack)

func execute():
	if !executing:
		knock_image.visible = true
		collision.disabled = false
		executing = true


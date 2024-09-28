extends Node2D

@export var damage := 10.0
@export var knockback := 24.0
@onready var knock_image = $KnockImage
@onready var collision = $HitboxComponent/Collision
var executing = false
var exeframes := 0

func _ready():
	knock_image.visible = false
	collision.disabled = true
	
func _physics_process(_delta):
	if executing:
		
		if exeframes == 10:
			knock_image.visible = false
			collision.disabled = true
			executing = false
			scale = Vector2(2.5,2.5)
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
		$AudioStreamPlayer2D.play()


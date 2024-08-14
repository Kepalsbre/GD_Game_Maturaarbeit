extends Node2D

@export var damage := 20.0
@export var knockback := 1.0
@export var dash_speed := 3200
@onready var dash_animation = $DashAnimation
@onready var collision = $HitboxComponent/Collision
@onready var dash_particles = $DashParticles

var executing = false
@onready var player : CharacterBody2D = get_parent().get_parent().get_parent()


func _ready():
	dash_animation.visible = false
	collision.disabled = true
	
	
func _physics_process(_delta):
	if executing:
		if player.dash_timer.is_stopped():
			dash_animation.visible = false
			dash_animation.stop()
			collision.disabled = true
			player.dash_timeout.stop()
			player.hitbox_collision.disabled = false
			dash_particles.emitting = false
			executing = false
			

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		area.damage(attack)

func execute():
	if !executing and not player.is_dashing and player.velocity.length() > 0:
		set_rotation_degrees(45 * player.looking_at + 90)
		dash_animation.visible = true
		dash_animation.play("default")
		collision.disabled = false
		player.start_dash(player.speed + dash_speed)
		player.hitbox_collision.disabled = true
		dash_particles.emitting = true
		executing = true
		$AudioStreamPlayer2D.play()
		


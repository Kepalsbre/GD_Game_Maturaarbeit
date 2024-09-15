extends Node2D

@onready var spike_bomb_image = $SpikeBombImage


var damage := 10.0
var explosion_damage := 20.0
var knockback := 5.0
var speed := 700
var velocity := Vector2.ZERO
var hitted := 0

@onready var explosion = $explosion
@onready var hit = $Hit
@onready var start = $Start
@onready var cpu_particles_2d = $SpikeBombImage/CPUParticles2D
@onready var explosion_collision = $HitHitbox/ExplosionCollision
@onready var bomb_collision = $HitHitbox/BombCollision



func _ready():
	cpu_particles_2d.emitting = true
	explosion_collision.disabled = true


func _physics_process(delta):
	global_position += velocity * delta * speed
	spike_bomb_image.rotate(deg_to_rad(340 * delta))
	if hitted == 3:
		bomb_collision.set_deferred("disabled", true)
		explosion_collision.set_deferred("disabled", false)

		

func _on_hitbox_component_area_entered(area):
	if not hitted > 3:
		if explosion_collision.disabled:
			if area is HitboxComponent:
				var hitbox : HitboxComponent = area
				var attack = Attack.new()
				attack.attack_damage = damage
				attack.knockback_force = 1
				attack.attack_position = global_position
				hitbox.damage(attack)
				hit.play()
				hitted += 1
		else:
			if area is HitboxComponent:
				var hitbox : HitboxComponent = area
				var attack = Attack.new()
				attack.attack_damage = explosion_damage
				attack.knockback_force = knockback
				attack.attack_position = global_position
				hitbox.damage(attack)
				explosion.play()
				free_queue()


func free_queue():
	velocity = Vector2.ZERO
	spike_bomb_image.visible = false
	cpu_particles_2d.emitting = false
	explosion_collision.set_deferred("disabled", true)
	await explosion.finished
	if hit.playing:
		await hit.finished
	if start.playing:
		await start.finished
	queue_free()



func _on_lifetime_timeout():
	queue_free()

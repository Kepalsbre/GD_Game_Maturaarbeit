extends Node2D

@onready var shotgun_image = $ShotgunImage
@onready var shot = $Shot

@onready var bullets = $Node/Bullets
@export var damage := 16
@export var knockback := 1.0
@onready var marker_2d_flipped = $ShotgunImage/Marker2DFlipped
@onready var marker_2d = $ShotgunImage/Marker2D
var bullet_count := 15
var executing = false

const SHOTGUN_BULLET = preload("res://scenes/shotgun_bullet.tscn")

var current_marker : Marker2D

func _ready():
	shotgun_image.self_modulate = Color(1,1,1,0)

func create_bullet(i):
	var new_bullet = SHOTGUN_BULLET.instantiate()
	new_bullet.damage = damage
	new_bullet.knockback = knockback
	#var direction = current_marker.global_position.direction_to(get_global_mouse_position())
	new_bullet.rotation = global_rotation
	new_bullet.velocity = Vector2.from_angle(deg_to_rad(100 - 100/bullet_count * i - 60)+ global_rotation) 
	new_bullet.position = current_marker.global_position
	new_bullet.scale = Vector2(1,1)
	return new_bullet


func _process(_delta):
	if not executing:
		look_at(get_global_mouse_position())
		if global_position.x > get_global_mouse_position().x:
			shotgun_image.flip_v = true
			current_marker = marker_2d_flipped
		else:
			shotgun_image.flip_v = false
			current_marker = marker_2d
	

func execute():
	if not executing:
		executing = true
		shotgun_image.self_modulate = Color(1,1,1,1)
		for g in range(2):
			shot.play()
			for i in range(bullet_count):
				bullets.add_child(create_bullet(i))
			await get_tree().create_timer(0.12).timeout
		await shot.finished
		shotgun_image.self_modulate = Color(1,1,1,0)
		executing = false
		
			
	

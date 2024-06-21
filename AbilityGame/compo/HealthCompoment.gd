class_name HealthComponent
extends Node

@export var max_health := 100.0
var health: float


func _ready():
	health = max_health

func _process(_delta):

	# kill if health is below 0
	if health <= 0:
		if get_parent().name == "Player":
			pass # write death code here
		else:
			get_parent().queue_free()

func damage(attack: Attack):
	if get_parent().name == "Player":
		if get_parent().is_dashing:
			attack.attack_damage /= 2
	
	health -= attack.attack_damage

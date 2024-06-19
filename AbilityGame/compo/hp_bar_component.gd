extends ProgressBar
class_name HpBarComponent

@export var health_component: HealthComponent
@export var lenght: int = 120
@export var height: int = 10
@export var pos_y: int = 30

func _ready():
	
	visible = false
	max_value = health_component.max_health
	step = 1
	scale = Vector2(0.5,0.5)
	var sb = StyleBoxFlat.new()
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	add_theme_stylebox_override("fill", sb)
	sb.bg_color = Color("#ff4d00")
	size = Vector2(lenght, height)
	position = Vector2(-(lenght/4), pos_y)

	
func _process(_delta):
	set_value_no_signal(health_component.health)
	if health_component.health != max_value and not visible:
		visible = true

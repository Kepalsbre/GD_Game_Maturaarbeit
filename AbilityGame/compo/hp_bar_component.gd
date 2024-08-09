extends ProgressBar
class_name HpBarComponent


@export var health_component: HealthComponent
@export var lenght: int = 120
@export var height: int = 10
## pos_x for enemies = lenght / -4
@export var use_position := true
@export var pos_x: int = -30
@export var pos_y: int = 30
@export var scale_factor := 0.5
@export var fill_color := "#ff4d00"



func _ready():
	step = 1
	scale = Vector2(scale_factor,scale_factor)
	var sb = StyleBoxFlat.new()
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	add_theme_stylebox_override("fill", sb)
	sb.bg_color = Color(fill_color)
	size = Vector2(lenght, height)
	if use_position:
		position = Vector2(pos_x, pos_y)

	
func _process(_delta):
	max_value = health_component.max_health
	set_value_no_signal(health_component.health)
	if health_component.health != max_value and not visible:
		visible = true


extends Panel

@onready var eqipped_ability_image = $CenterContainer/EqippedAbilityImage
@onready var uses_counter = $UsesCounter
@export var control_key_text := ""

func _ready():
	eqipped_ability_image.visible = false
	uses_counter.visible = false
	$control_key.text = control_key_text

func update(ability: InvAbility, i):
	if !ability:
		eqipped_ability_image.visible = false
		uses_counter.visible = false
		
	else:
		eqipped_ability_image.texture = ability.texture
		uses_counter.text = str(Global.ability_uses_list[i])
		eqipped_ability_image.visible = true
		uses_counter.visible = true


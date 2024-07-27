extends Panel


@onready var slot = $slot
@export var slot_texture: Texture2D = preload("res://art/inventory/inventory_slot.png")
@onready var ability_display = $CenterContainer/Panel/ability_display
@onready var slothide = $CenterContainer/Panel/slothide
@onready var button = $CenterContainer/Panel/Button
var slotnum: int = -1

signal selected

func _ready():
	slot.texture = slot_texture
	selected.connect(get_parent().get_parent().get_parent().on_select)

func update(ability: InvAbility, slotnumber):
	if !ability:
		ability_display.visible = false
		slothide.visible = false
		
	else:
		ability_display.visible = true
		ability_display.texture = ability.texture
		slothide.visible = true
		
	ability_display.self_modulate = Color8(255,255,255)
	slotnum = slotnumber
	
	

func _on_button_button_down():
	selected.emit(slotnum)
	
func blink():
	ability_display.self_modulate = Color8(255, 121,133)

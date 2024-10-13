extends CanvasLayer

var ui_ability_slots

func _ready():
	ui_ability_slots = $HBoxContainer.get_children()

func _process(_delta):
	var i := 0
	for slot in get_parent().equipped_abilities.get_children():
		var ab = Global.inv[slot.slot_number + 11]
		ui_ability_slots[slot.slot_number - 1].update(ab, i)
		i += 1
		

extends Control

@onready var slots: Array = $NinePatchRect/GridContainer.get_children()


var is_open = false

func _ready():
	update_slots()
	close()

func update_slots():
	for i in range(min(Global.inv.abilities.size(), slots.size())):
		slots[i].update(Global.inv.abilities[i], i)
		
		
func _process(_delta):
	if Input.is_action_just_pressed("i"):
		if is_open:
			close()
		else:
			open()

func close():
	visible = false
	is_open = false

func open():
	visible = true
	is_open = true

func on_select(slotnum: int):
	print("select")
	print(slotnum)

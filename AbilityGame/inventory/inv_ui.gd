extends Control

@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var step := 1
var selec1 :InvAbility
var num1 :int

var is_open = false

func _ready():
	update_slots()
	close()

func update_slots():
	for i in range(min(Global.inv.size(), slots.size())):
		slots[i].update(Global.inv[i], i)
		
		
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
	print(slotnum)
	print(Global.inv[slotnum])
	
	if step == 1:
		if Global.inv[slotnum]:  # check if ability in slot
			selec1 = Global.inv[slotnum]
			num1 = slotnum
			slots[slotnum].blink()
			step += 1  # go to next step when ability in slot
			
			
	else:
		Global.inv[num1] = Global.inv[slotnum]  # 1st selected ability into new selected
		Global.inv[slotnum] = selec1  # new selected is the 1st selected
		step = 1
		update_slots()

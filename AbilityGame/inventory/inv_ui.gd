extends Control

@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var description = $Description
const PAUSE_MENU = preload("res://scenes/pause_menu.tscn")


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
	description.text = ""
		
		
func update_equipped():
	var player = get_parent().get_parent()
	for slot in player.equipped_abilities.get_children():  # check each equipped slot
		if Global.inv[slot.slot_number + 11] and slot.get_child_count() == 0:  # if ability in inventory at slot and no ability equipped in slot
			var inst_ability = Global.ability_dict[Global.inv[slot.slot_number + 11].name].instantiate() 
			slot.add_child(inst_ability)
		elif !Global.inv[slot.slot_number + 11] and slot.get_child_count() != 0:
			slot.get_child(0).queue_free()
			
		elif Global.inv[slot.slot_number + 11] and slot.get_child_count() != 0:
			slot.get_child(0).queue_free()
			var inst_ability = Global.ability_dict[Global.inv[slot.slot_number + 11].name].instantiate() 
			slot.add_child(inst_ability)
			
			
func _process(_delta):
	if not Global.combat:
		if Input.is_action_just_pressed("i") or Input.is_action_just_pressed("esc") and is_open:
			if is_open:
				update_slots()
				close()
			else:
				update_slots()
				open()
	if Input.is_action_just_pressed("esc") and not is_open:
		get_tree().root.add_child(PAUSE_MENU.instantiate())

func close():
	visible = false
	is_open = false

func open():
	visible = true
	is_open = true

func on_select(slotnum: int):
	if step == 1:
		if Global.inv[slotnum]:  # check if ability in sloty
			$Clicked.play()
			selec1 = Global.inv[slotnum]
			num1 = slotnum
			slots[slotnum].blink()
			description.text = Global.inv[slotnum].desc + " (" + str(Global.inv[slotnum].uses) + " uses per battle)"
			step += 1  # go to next step when ability in slot
			
			
	else:
		$Clicked.play()
		Global.inv[num1] = Global.inv[slotnum]  # 1st selected ability into new selected
		Global.inv[slotnum] = selec1  # new selected is the 1st selected
		step = 1
		update_slots()
		update_equipped()
	
	

	

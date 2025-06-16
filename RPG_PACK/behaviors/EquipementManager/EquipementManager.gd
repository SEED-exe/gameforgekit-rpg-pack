@icon("res://addons/GameForgeKit/RPG_PACK/behaviors/EquipementManager/EquipementManager.gd")
extends RPG_PACK_BEHAVIORS
class_name GF_EquipementManager

@export var weapon_slots : Array[GF_WeaponItem]
@export var maximum_weapon_slot : int = 2

var weapon_id_arr : Array = []

@export_subgroup("armor")


@export var Helmet_slots : GF_ArmorItem = null
@export var Chestplate_slots : GF_ArmorItem = null
@export var Leggings_slots : GF_ArmorItem = null
@export var Boots_slots : GF_ArmorItem = null
@export var Gloves_slots : GF_ArmorItem = null
@export var Shoulders_slots : GF_ArmorItem = null
@export var Belt_slots : GF_ArmorItem = null
@export var Shield_slots : GF_ArmorItem = null

var parent : Node2D = null

func _ready() -> void:
	get_all_weapon_id()
	add_to_group("persist")  # Important for automatic saving
	parent = get_parent()
	Global.ressource_weapon_path = 'res://ressources/weapon/'
	
	SaveManager.connect("save",_save)
	SaveManager.connect("_load",_load)
	
	get_all_equipement()
	
func _save(debug : bool):
	get_all_weapon_id()
	var data = SaveManager.data_save
	var _name = name + parent.name
	data[_name] = weapon_id_arr
	
func get_all_weapon_id():
	weapon_id_arr.clear()
	if weapon_slots.size() > 0:
		for slot in weapon_slots:
			if slot : weapon_id_arr.append(slot.ID)


func _load(debug : bool):
	weapon_slots.clear()
	var data = SaveManager.data_save
	var _name = name + parent.name
	if data.has(_name):
		weapon_id_arr = data[_name]
	
	for id in weapon_id_arr:
		add_weapon_by_file_name(id,1)

func add_weapon_by_file_name(id,amount):
	add_weapon(Global.get_weapon_item_by_file_name(id))
	
func can_add_weapon() -> bool:
	for slot in weapon_slots:
		if slot == null:
			weapon_slots.erase(slot)
	if weapon_slots.size() >= maximum_weapon_slot:
		print("To much weapon in the equipementInventory")
		return false
	else:
		return true

func add_weapon(new_weapon : GF_WeaponItem):
	if parent:
		if weapon_slots.size() >= maximum_weapon_slot:
			print("maximun weapon for " + parent.name)
		else:
			weapon_slots.append(new_weapon)
			
func get_all_equipement() -> Array:
	
	var all_equipment: Array = []

	## Ajouter toutes les armes équipées
	#for weapon in weapon_slots:
		#if weapon != null:
			#all_equipment.append(weapon)
	
	# Ajouter toutes les armures équipées
	var armor_slots = [
		Helmet_slots,
		Chestplate_slots,
		Leggings_slots,
		Boots_slots,
		Gloves_slots,
		Shoulders_slots,
		Belt_slots,
		Shield_slots
	]
	
	for armor in armor_slots:
		if armor != null:
			all_equipment.append(armor)
	
	return all_equipment

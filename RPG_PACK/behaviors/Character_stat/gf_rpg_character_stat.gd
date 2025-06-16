extends RPG_PACK_BEHAVIORS
class_name GF_RPG_Character_stat

## Manages RPG character statistics, including base attributes, equipment bonuses, and combat-related modifiers.

## The character's base class definition, providing natural attributes (strength, dexterity, etc.).
@export var Character_Class: BaseClass

## Reference to the parent node, usually a CharacterBody2D. Automatically assigned in _ready().
var parent = null

## Bonus stats applied from external sources like equipment or buffs.
var equipment_modifiers := {
	"strength": 0.0,
	"constitution": 0.0,
	"dexterity": 0.0,
	"intelligence": 0.0,
	"wisdom": 0.0,
	"charisma": 0.0,
	"agility": 0.0,
	"luck": 0.0,
	"perception": 0.0,
	"willpower": 0.0,
	"resistance": 0.0
}

## Multiplies outgoing damage by type. (Example: "FIRE": 0.5 means 50% fire damage dealt.)
@export var damage_modifiers : Dictionary = {
	"PHYSICAL": 0.0,
	"MAGICAL": 0.0,
	"FIRE": 0.0,
	"ICE": 0.0,
	"LIGHTNING": 0.0,
	"POISON": 0.0,
	"DARK": 0.0,
	"HOLY": 0.0,
	"BLEED": 0.0,
	"CURSE": 0.0,
	"TRUE_DAMAGE": 0.0
}

## Multiplies incoming damage taken by type. (Example: "ICE": 5.0 means taking 5x ice damage.)
@export var damage_take_modifiers : Dictionary = {
	"PHYSICAL": 1.0,
	"MAGICAL": 1.0,
	"FIRE": 1.0,
	"ICE": 1.0,
	"LIGHTNING": 1.0,
	"POISON": 1.0,
	"DARK": 1.0,
	"HOLY": 1.0,
	"BLEED": 1.0,
	"CURSE": 1.0,
	"TRUE_DAMAGE": 1.0
}

## If true for a given damage type, negative incoming damage heals instead of being ignored.
@export var negative_damage_heal_type : Dictionary = {
	"PHYSICAL": false,
	"MAGICAL": false,
	"FIRE": false,
	"ICE": false,
	"LIGHTNING": false,
	"POISON": false,
	"DARK": false,
	"HOLY": false,
	"BLEED": false,
	"CURSE": false,
	"TRUE_DAMAGE": false
}

## The equipment manager node handling equipped weapons and armor.
@export var EquipementManager : GF_EquipementManager

var equipped_armors: Array = []
var all_weapon: Array = []

var current_weapon_index: int = 0
var current_weapon: GF_WeaponItem = null


func _ready() -> void:
	add_to_group("GF_RPG_Character_stat")
	parent = get_parent()
	
	if EquipementManager == null and parent.has_node("GF_EquipementManager"):
		EquipementManager = parent.get_node("GF_EquipementManager")
	
	if EquipementManager:
		get_all_armor()
		get_weapon_armor()
		equip_first_weapon()

func get_attributes() -> Dictionary:
	var attributes := {}
	if Character_Class:
		attributes["strength"] = Character_Class.strength + equipment_modifiers["strength"]
		attributes["constitution"] = Character_Class.constitution + equipment_modifiers["constitution"]
		attributes["dexterity"] = Character_Class.dexterity + equipment_modifiers["dexterity"]
		attributes["intelligence"] = Character_Class.intelligence + equipment_modifiers["intelligence"]
		attributes["wisdom"] = Character_Class.wisdom + equipment_modifiers["wisdom"]
		attributes["charisma"] = Character_Class.charisma + equipment_modifiers["charisma"]
		attributes["agility"] = Character_Class.agility + equipment_modifiers["agility"]
		attributes["luck"] = Character_Class.luck + equipment_modifiers["luck"]
		attributes["perception"] = Character_Class.perception + equipment_modifiers["perception"]
		attributes["willpower"] = Character_Class.willpower + equipment_modifiers["willpower"]
		attributes["resistance"] = Character_Class.resistance + equipment_modifiers["resistance"]
	return attributes

func get_all_armor():
	if EquipementManager:
		equipped_armors.clear()
		for equip in EquipementManager.get_all_equipement():
			if equip and equip is GF_ArmorItem:
				equipped_armors.append(equip)
		print("Equipped Armors: ", equipped_armors)

func get_weapon_armor():
	if EquipementManager:
		all_weapon.clear()
		for weapon in EquipementManager.weapon_slots:
			if weapon:
				all_weapon.append(weapon)
func get_total_defense() -> Dictionary:
	var total_defense: Dictionary = {}
	for armor in equipped_armors:
		if armor:
			for defense_data in armor.defense_values:
				if defense_data:
					var defense_type_name = GF_DefenseType.DefenseType.keys()[defense_data.defense_type]
					total_defense[defense_type_name] = total_defense.get(defense_type_name, 0.0) + defense_data.value
	return total_defense

func switch_weapon(direction: int = 1) -> void:
	get_weapon_armor()
	if all_weapon.size() == 0:
		current_weapon = null
		return
	
	current_weapon_index += direction
	
	if current_weapon_index >= all_weapon.size():
		current_weapon_index = 0  # Retour au début si on dépasse
	elif current_weapon_index < 0:
		current_weapon_index = all_weapon.size() - 1  # Aller à la fin si on descend trop

	current_weapon = all_weapon[current_weapon_index]
	#print("Switched to weapon: ", current_weapon.weapon_name)

	var total_weapon_damage = get_current_weapon_damage()

	#for damage_type_name in total_weapon_damage.keys():
		#print("Damage Type:", damage_type_name, "Value:", total_weapon_damage[damage_type_name])
	if parent.is_in_group('player'):
		if Hud.has_node("WeaponHUD"):
			var WeaponHUD = Hud.get_node("WeaponHUD")
			WeaponHUD.update_weaponHUD(current_weapon.weapon_name, current_weapon.icon_texture)

func equip_first_weapon():
	if all_weapon.size() > 0:
		current_weapon_index = 0
		current_weapon = all_weapon[current_weapon_index]
		print(parent.name + " has equipped: " + current_weapon.weapon_name)
	else:
		current_weapon = null

func get_current_weapon_damage() -> Dictionary:
	var total_damage: Dictionary = {}
	if current_weapon:
		for damage_data in current_weapon.Damage_Type:
			if damage_data:
				var damage_type_name = DamageType.Damage_Type.keys()[damage_data.damage_type]
				total_damage[damage_type_name] = total_damage.get(damage_type_name, 0.0) + damage_data.value
	return total_damage

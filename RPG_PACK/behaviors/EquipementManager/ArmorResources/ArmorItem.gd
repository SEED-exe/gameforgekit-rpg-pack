extends Resource
class_name GF_ArmorItem

enum ArmorType {
	Shield,
	Belt,
	Shoulders,
	Gloves,
	Boots,
	Leggings,
	Chestplate,
	Helmet,
}


@export var defense_values : Array[GF_DefenseType]

@export var Armor_Type: ArmorType = ArmorType.Helmet

@export var armor_name: String = "Default Armor"
## MUST BE THE SAME NAME AS THE RESOURCE NAME OF THE FILE IN "item_ressources" in "res://addons/GameForgeKit/Behaviors/Inventory/Item_Ressources/"
@export var ID : String = "demo_armor"
@export var description: String = "This is a default weapon."
@export var icon_texture : Texture2D = null
@export var weapon_texture : Texture2D = null
@export var weight: float = 0.0
@export var price : float = 0.0

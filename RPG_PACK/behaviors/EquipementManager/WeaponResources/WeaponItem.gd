extends Resource
class_name GF_WeaponItem

# Enumération pour classifier les arme.
enum WeaponType {
	MELEE,         # Iron Sword, Axe
	MAGIC_MELEE,   # Enchanted Sword, Magic Axe
	
	RANGED,        # Bow, Crossbow, Throwing Knives
	MAGIC_RANGED,  # Magic Bow, Elemental Crossbow
	
	MAGIC,         # Staff, Wand, Spellbook
	
	THROWABLE,     # Grenades, Javelins (physique mais jetable)
	DUAL_WIELD,    # Dual small swords, daggers
	SHIELD         # Shields (could block and bash)
}





# Propriétés exportées pour configurer l'item dans l'Inspector.
@export var Damage_Type: Array[DamageType]

@export var Weapon_Type: WeaponType = WeaponType.MELEE

@export var weapon_name: String = "Default weapon"
## MUST BE THE SAME NAME AS THE RESOURCE NAME OF THE FILE IN "item_ressources" in "res://addons/GameForgeKit/Behaviors/Inventory/Item_Ressources/"
@export var ID : String = "demo_weapon"
@export var description: String = "This is a default weapon."
@export var icon_texture : Texture2D = null
@export var weapon_texture : Texture2D = null
@export var weight: float = 0.0
@export var price : float = 0.0

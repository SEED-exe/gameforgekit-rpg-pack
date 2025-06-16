extends Resource
class_name GF_DefenseType

enum DefenseType {
	PHYSICAL,
	MAGICAL,
	FIRE,
	ICE,
	LIGHTNING,
	POISON,
	DARK,
	HOLY,
	BLEED,
	CURSE,
	TRUE_DAMAGE
}

@export var defense_type : DefenseType = DefenseType.PHYSICAL
@export var value : float = 0.0

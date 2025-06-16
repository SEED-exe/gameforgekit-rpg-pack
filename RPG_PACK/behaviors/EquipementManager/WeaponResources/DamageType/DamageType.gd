extends Resource
class_name DamageType



enum Damage_Type {
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

@export var damage_type : Damage_Type = Damage_Type.PHYSICAL
@export var value : float = 0.0

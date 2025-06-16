extends RPG_PACK_BEHAVIORS
class_name GF_Damage_Calculator_rpg_pack

## Static calculator for RPG damage handling.
##
## Calculates physical or magical damage based on attacker and defender stats,
## applies defense, and determines critical hits based on the attacker's luck.

#TODO Faire avec la luck, une chance calculer avec du random de loupé la cible ou alors d'esquiver la cible, ou les deux.

static func calculate_damage(attacker_stats: Dictionary, defender_stats: Dictionary, options: Dictionary = {}) -> Dictionary:
	var damage_type: String = options.get("damage_type", "physical").to_lower()
	var base_damage: float = options.get("base_damage", 10.0)
	var weapon_damage: float = options.get("weapon_damage", 0.0)
	var armor_defense: float = options.get("armor_defense", 0.0)
	var crit_multiplier: float = 1.5
	var coef_luck = 9.7

	var result := {
		"final_damage": 0.0,
		"is_crit": false,
		"damage_type": damage_type,
		"raw_damage": 0.0,
		"defense": 0.0
	}

	var damage := base_damage + weapon_damage
	var defense := 0.0

	# Appliquer bonus d'attaque selon type
	if damage_type == "physical":
		var strength = attacker_stats.get("strength", 0.0)
		var dexterity = attacker_stats.get("dexterity", 0.0)
		damage += strength * 1.2 + dexterity * 0.2
	elif damage_type == "magical":
		var intelligence = attacker_stats.get("intelligence", 0.0)
		var wisdom = attacker_stats.get("wisdom", 0.0)
		damage += intelligence * 0.7 + wisdom * 0.4
	else:
		# pour types spéciaux (feu, glace, etc.), on booste avec intelligence
		var intelligence = attacker_stats.get("intelligence", 0.0)
		damage += intelligence * 0.5

	# Appliquer défense selon type
	match damage_type:
		"physical":
			defense = defender_stats.get("constitution", 0.0) * 0.3 + defender_stats.get("resistance", 0.0)
		"magical":
			defense = defender_stats.get("willpower", 0.0) * 0.3 + defender_stats.get("resistance", 0.0) * 0.2
		"fire":
			defense = defender_stats.get("fire_resistance", 0.0)
		"ice":
			defense = defender_stats.get("ice_resistance", 0.0)
		"lightning":
			defense = defender_stats.get("lightning_resistance", 0.0)
		"poison":
			defense = defender_stats.get("poison_resistance", 0.0)
		"dark":
			defense = defender_stats.get("dark_resistance", 0.0)
		"holy":
			defense = defender_stats.get("holy_resistance", 0.0)
		"bleed":
			defense = defender_stats.get("bleed_resistance", 0.0)
		"curse":
			defense = defender_stats.get("curse_resistance", 0.0)
		"true_damage":
			defense = 0.0  # true damage ignore toutes les défenses
		_:
			defense = defender_stats.get("resistance", 0.0)  # fallback général

	# Ajouter armure générique
	defense += armor_defense

	# Critique chance
	var luck = attacker_stats.get("luck", 0.0)
	var crit_chance = clamp(luck * coef_luck, 0.0, 100.0)
	var is_crit = rng_pourcent(crit_chance)

	if is_crit:
		damage *= crit_multiplier
		result["is_crit"] = true

	result["raw_damage"] = damage
	result["defense"] = defense
	result["final_damage"] = max(0.0, damage - defense)

	return result



## Returns true if a random number between 0 and 100 is less than the given percentage.
static func rng_pourcent(pourcent: float) -> bool:
	randomize()
	return randf() * 100.0 < pourcent

extends Game_Forge_RPG_PACK
class_name GF_RPG_Health_Manager

signal dead
signal hurt

const DamageCalculator = preload("res://addons/GameForgeKit/RPG_PACK/behaviors/damage_calculator/damage_calculator.gd")

var Character_stat = null
var attributes := {}

@export var base_hp : float = 100
var hp_max : float = 0
var hp : float = 0


@export_subgroup("xp randomize")
@export var MinBaseXP : float = 10
@export var MaxBaseXP : float = 20
var coef_level = 1.2

@export_category("Audio")
@export var hurt_sound: AudioStream = null

@export_category("DEBUG")
@export var debug : bool = true

var _knockback_velocity: Vector2 = Vector2.ZERO
var _knockback_time_left: float = 0.0
@export var do_knockback : bool = true

var parent : Node2D = null

func _ready() -> void:
	parent = get_parent()
	add_to_group("GF_RPG_Health")
	Character_stat = parent.get_node("GF_RPG_Character_stat")
	
	if Character_stat:
		get_attributes()
		set_hp_max()
		hp = hp_max
	else:
		push_error("Character_stat node not found in scene tree.")

func get_attributes():
	attributes = Character_stat.get_attributes()

func set_hp_max():
	var constitution = attributes.get("constitution", 0.0)
	var strength = attributes.get("strength", 0.0)
	hp_max = base_hp + (constitution * 8.0) + (strength * 5.0)

func do_weapon_damage(user) -> void:
	randomize()

	if not user.has_node("GF_RPG_Character_stat"):
		push_error("The user (%s) does not have a GF_RPG_Character_stat" % user.name)
		return

	var rpg_stat = user.get_node("GF_RPG_Character_stat")
	var attacker_stats = rpg_stat.get_attributes()
	var weapon_damage_dict = rpg_stat.get_current_weapon_damage()

	var total_final_damage = 0.0
	var debug_damage_details = {}

	for damage_type_name in weapon_damage_dict.keys():
		var weapon_damage = weapon_damage_dict[damage_type_name]

		# 1. Appliquer bonus/malus d'attaque
		var attacker_damage_modifier = 1.0
		if rpg_stat.damage_modifiers.has(damage_type_name):
			attacker_damage_modifier += rpg_stat.damage_modifiers[damage_type_name] / 100.0

		weapon_damage *= attacker_damage_modifier

		# 2. Calcul de base (force, résistance, etc.)
		var result = DamageCalculator.calculate_damage(attacker_stats, attributes, {
			"base_damage": weapon_damage,
			"damage_type": damage_type_name.to_lower()
		})

		# 3. Appliquer le multiplicateur de défense
		var defense_multiplier = 1.0
		if Character_stat.damage_take_modifiers.has(damage_type_name):
			defense_multiplier = Character_stat.damage_take_modifiers[damage_type_name]

		# Important: on multiplie les dégâts finaux par le defense_multiplier
		var final_damage = result["final_damage"] * defense_multiplier

		if final_damage < 0.0:
			if Character_stat.negative_damage_heal_type.has(damage_type_name) and Character_stat.negative_damage_heal_type[damage_type_name]:
				# Si le type de dégât est autorisé pour heal
				heal_raw(-final_damage)
				final_damage = 0.0
			else:
				# Sinon annuler les dégâts négatifs
				final_damage = 0.0


		total_final_damage += final_damage

		debug_damage_details[damage_type_name] = {
			"raw_damage": result["raw_damage"],
			"defense": result["defense"],
			"final_damage": final_damage,
			"attack_modifier": attacker_damage_modifier,
			"defense_multiplier": defense_multiplier,
			"is_crit": result["is_crit"]
		}

	hp -= total_final_damage

	if debug:
		print_combat_debug_multi("Damage Application", {
			"Damage_Taker": parent.name,
			"Damage_Giver": user.name,
			"total_final_damage": total_final_damage,
			"hp_après_dégâts": hp,
			"details_par_type": debug_damage_details
		})

	if hp <= 0:
		hp = 0
		if user.has_node("Level_XP"):
			var level_xp: Level_XP = user.get_node("Level_XP")
			var coef_total = level_xp.level * coef_level
			var baseXP = randf_range(MinBaseXP, MaxBaseXP)
			var xp_total = baseXP * coef_total
			level_xp.gain_xp(xp_total)
		emit_signal("dead")
	else:
		emit_signal("hurt")
		if hurt_sound:
			var fx = GF_OneShot_Audio_2D.new()
			parent.add_child(fx)
			fx.bus_name = "sfx"
			fx.volume -= 10
			fx.setup(hurt_sound, parent)
			fx.play()

		var strength = attributes.get("strength", 0.0)
		apply_knockback(user, strength * 50, 0.2)



func heal_raw(amount: float) -> void:
	hp += amount
	if hp > hp_max:
		hp = hp_max
	print("Healed (raw):", amount)
	print("Current HP:", hp)

func heal_with_attributes(base_heal: float) -> void:
	var intelligence = attributes.get("intelligence", 0.0)
	var wisdom = attributes.get("wisdom", 0.0)

	var coef_int = 0.2
	var coef_wis = 0.3

	var bonus_heal = (intelligence * coef_int) + (wisdom * coef_wis) / 2
	var total_heal = base_heal + bonus_heal

	hp += total_heal
	if hp > hp_max:
		hp = hp_max

	print("Healed (with attributes):", total_heal)
	print("Current HP:", hp)

func _physics_process(delta: float) -> void:
	if _knockback_time_left > 0.0 and parent:
		_knockback_time_left -= delta
		parent.global_position += _knockback_velocity * delta

func apply_knockback(user: Node2D, strength: float = 200.0, duration: float = 0.2) -> void:
	if !do_knockback:
		return
	var body = get_parent()
	if not (body and body is CharacterBody2D):
		return

	var direction = (body.global_position - user.global_position).normalized()
	_knockback_velocity = direction * strength
	_knockback_time_left = duration

func print_combat_debug_multi(title: String, data: Dictionary) -> void:
	if not debug:
		return

	print_rich("\n[color=orange][b][DEBUG COMBAT MULTI-DAMAGE][/b][/color] [b]%s[/b]" % title)
	print_rich("[color=gray]==============================[/color]")

	var damage_details = data.get("details_par_type", {})

	for damage_type in damage_details.keys():
		var detail = damage_details[damage_type]

		print_rich("\n[color=yellow][b]%s DAMAGE[/b][/color]" % damage_type.capitalize())

		if detail.get("is_crit", false):
			print_rich("[color=red]🎯 CRITICAL HIT![/color]")

		var raw_damage = detail.get("raw_damage", 0.0)
		var attack_modifier = detail.get("attack_modifier", 1.0)
		var defense = detail.get("defense", 0.0)
		var defense_multiplier = detail.get("defense_multiplier", 1.0)
		var final_damage = detail.get("final_damage", 0.0)

		# Correction ici !
		print_rich("➔ [color=lime]Base Damage (after modifiers):[/color] %.2f" % raw_damage)
		print_rich("➔ [color=orange]Attack Modifier:[/color] x%.2f (%.2f%%)" % [attack_modifier, (attack_modifier - 1.0) * 100])

		if defense_multiplier != 0.0:
			print_rich("➔ [color=cyan]Defense:[/color] %.2f" % (defense / defense_multiplier))
		else:
			print_rich("➔ [color=cyan]Defense:[/color] INF")

		print_rich("➔ [color=cyan]Defense Multiplier:[/color] x%.2f" % defense_multiplier)
		print_rich("➔ [color=white]Final Damage:[/color] [b]%.2f[/b]" % final_damage)

		print_rich("[color=gray]------------------------------[/color]")

	print_rich("\n[b]Damage Taker:[/b] %s" % data.get("Damage_Taker", ""))
	print_rich("[b]Damage Giver:[/b] %s" % data.get("Damage_Giver", ""))
	print_rich("[b]Total Final Damage:[/b] %.2f" % data.get("total_final_damage", 0.0))
	print_rich("[b]HP After Damage:[/b] %.2f" % data.get("hp_après_dégâts", 0.0))
	print_rich("[color=gray]==============================[/color]\n")

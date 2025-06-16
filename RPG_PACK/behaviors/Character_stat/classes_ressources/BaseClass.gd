extends Resource
class_name BaseClass

## Villager — typical civilian character in an RPG

@export_category("Core Attributes")
## Name of the class
@export var _class_name: String = "Villager"

## Name of the race
@export var race_name : String = "Human"

## Physical strength (low, untrained)
@export var strength: float = 2.0

## Vitality and stamina (rural life = decent endurance)
@export var constitution: float = 4.5

## Dexterity (not agile, not used to fighting)
@export var dexterity: float = 2.5

## Intelligence (basic literacy, no formal education)
@export var intelligence: float = 1.2

## Wisdom (common sense, life experience)
@export var wisdom: float = 4.2

## Charisma (talks to people, social life)
@export var charisma: float = 1.3

@export_category("Secondary Attributes")

## Agility (walks a lot, but not fast)
@export var agility: float = 3.5

## Luck (nothing special)
@export var luck: float = 2.0

## Perception (notices things, but not an expert)
@export var perception: float = 4.0

## Willpower (some resistance to mental influence)
@export var willpower: float = 1.1

## Physical/magical resistance (almost none)
@export var resistance: float = 0.5

@export_category("Custom Attributes")
## Optional secondary stats like corruption, fame, etc.
@export var custom_attributes: Array[BaseAttribute] = []

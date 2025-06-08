extends Label3D

enum ATTRIBUTE_TYPE {DEFENSE, ATTACK}
@export var collection : XRCardCollection
@export var attribute : ATTRIBUTE_TYPE
var label_format : String
var value : int = 0:
	set(new_value):
		value = new_value
		text = label_format % value

func _ready() -> void:
	DK.set_current_camera($"../XROrigin3D/XRCamera3D")
	if attribute == ATTRIBUTE_TYPE.DEFENSE:
		label_format = 'Defense\n%d'
	else:
		label_format = 'Attack\n%d'
	collection.card_added.connect(_add_attribute_value)
	collection.card_removed.connect(_substract_attribute_value)
	
func _substract_attribute_value(card : XRCard) -> void:
	if card is BattleCard:
		value -= _get_card_attribute_value(card)
func _add_attribute_value(card : XRCard) -> void:
	if card is BattleCard:
		value += _get_card_attribute_value(card)

func _get_card_attribute_value(card : BattleCard) -> int:
	if attribute == ATTRIBUTE_TYPE.DEFENSE:
		return card.creature.defence
	else:
		return card.creature.attack

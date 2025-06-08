extends XRCardCollection

func can_add_card(card : Node) -> bool:
	var super_return = super(card)
	if not super_return or not card is BattleCard:
		return false
	return true

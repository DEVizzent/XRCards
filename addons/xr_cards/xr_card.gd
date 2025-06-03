class_name XRCard
extends XRToolsPickable


var position_tween: Tween
var rotate_tween: Tween
var destination

func dragging_rotation(drag_rotation):
	if rotate_tween and rotate_tween.is_running:
		rotate_tween.kill()
	
	rotate_tween = create_tween()
	_tween_card_rotation(drag_rotation, 1.0)


func animate_to_position(new_position: Vector3, duration = 1.0):
	if position_tween and position_tween.is_running:
		position_tween.kill()
	
	position.z = new_position.z # set z to prevent transition spring from making card go below another card
	position_tween = create_tween()
	position_tween.set_ease(Tween.EASE_OUT)
	position_tween.set_trans(Tween.TRANS_SPRING)
	_tween_card_position(new_position, duration)
	return position_tween

func _tween_card_position(pos: Vector3, duration: float):
	position_tween.tween_property($".", "position", pos, duration)


func _tween_card_rotation(target_rotation, duration):
	rotate_tween.set_ease(Tween.EASE_IN)
	rotate_tween.tween_property($".", "rotation", target_rotation, duration)

func set_destination(new_destination) -> void:
	if new_destination == null or new_destination is XRCardCollection:
		destination = new_destination
	
func has_destination() -> bool:
	return destination is XRCardCollection

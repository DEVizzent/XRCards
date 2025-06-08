class_name XRCardCollection
extends Area3D


# Signal emitted when the highlight state changes
signal highlight_updated(pickable, enable)

# Signal emitted when the highlight state changes
signal close_highlight_updated(pickable, enable)

#Signal emitted when a Card is added to the collection
signal card_added(card: XRCard)

#Signal emitted when a Card is removed from the collection
signal card_removed(card: XRCard)

var cards : Array[XRCard] = []

@export var limit : int = 99999
@onready var card_nodes = $XRCardNodes
@export var card_layout_strategy : CardLayout = LineCardLayout.new():
	set(strategy):
		card_layout_strategy = strategy
		apply_card_layout()
# Private fields
var _object_in_grab_area = Array()

func can_add_card(card : Node) -> bool:
	if not card is XRCard:
		return false
	if cards.has(card):
		apply_card_layout()
		return false
	return cards.size() <= limit
	
func add_card(card: XRCard) -> void:
	cards.append(card)
	card.reparent(card_nodes, true)
	card.freeze = true
	apply_card_layout()
	card_added.emit(card)

func remove_card(card: XRCard) -> void:
	cards.erase(card)
	card.reparent($"../../..", true)
	card.freeze = false
	apply_card_layout()
	card_removed.emit(card)

func _on_card_collection_body_entered(target: Node3D) -> void:
	# Ignore objects already known about
	if _object_in_grab_area.find(target) >= 0:
		return

	if cards.has(target) and target.is_connected("dropped", _on_target_dropped_remove):
		target.disconnect("dropped", _on_target_dropped_remove)
		
	# Reject objects which don't support picking up
	if not target.has_method('pick_up'):
		return

	if target is not XRCard:
		return
	# Add to the list of objects in grab area
	_object_in_grab_area.push_back(target)
	
	target.connect("dropped", _on_target_dropped, CONNECT_DEFERRED)
	target.set_destination(self)
	close_highlight_updated.emit(self, true)

# Called when a body leaves the snap zone
func _on_card_collection_body_exited(target: Node3D) -> void:
	if cards.has(target) and not target.is_connected("dropped", _on_target_dropped_remove):
		target.connect("dropped", _on_target_dropped_remove)
	# Ensure the object is not in our list
	_object_in_grab_area.erase(target)

	# Stop listening for dropped signals
	if target.has_signal("dropped") and target.is_connected("dropped", _on_target_dropped):
		target.disconnect("dropped", _on_target_dropped)

	# Hide highlight when nothing could be snapped
	if _object_in_grab_area.is_empty():
		close_highlight_updated.emit(self, false)
	# Remove this collection as destination for the card
	if target is XRCard and target.destination == self:
		target.set_destination(null)

func _on_target_dropped(card: Node3D) -> void:
	card.disconnect("dropped", _on_target_dropped)
	card.set_destination(null)
	if not can_add_card(card):
		return
	add_card(card)

func _on_target_dropped_remove(card: Node3D) -> void:
	card.disconnect("dropped", _on_target_dropped_remove)
	if (card is XRCard and not card.has_destination()):
		apply_card_layout()
		return
	remove_card(card)
	

func apply_card_layout():
	card_layout_strategy.update_card_positions(cards, 1.0)

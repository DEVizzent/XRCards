extends XRCard
class_name BattleCard

@export var creature : Creature

func _ready() -> void:
	var mesh = $CardMesh/CardFrontMesh
	var front_material : StandardMaterial3D = $CardMesh/CardFrontMesh.get_active_material(0).duplicate()
	front_material.albedo_texture = creature.texture
	mesh.set_surface_override_material(0, front_material)

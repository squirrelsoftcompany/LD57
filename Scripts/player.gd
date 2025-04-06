extends Node3D

static func get_first_child_of_type(parent : Node, type : String) -> Variant:
	for child in parent.get_children():
		if child.is_class(type):
			return child
	return null  # Si aucun nœud MeshInstance3D n'est trouvé


@onready var _moving_interaction : MovingInteraction = get_first_child_of_type(self, "MovingInteraction")


func _ready() -> void:
	assert(_moving_interaction != null)
	pass

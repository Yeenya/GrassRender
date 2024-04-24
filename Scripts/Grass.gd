extends MultiMeshInstance3D

@export var character_path := NodePath()
@onready var _character: Node3D = get_node(character_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if character_path != null:
		material_override.set_shader_parameter(
			"character_position", _character.global_transform.origin
		)

extends MultiMeshInstance3D

@export var character_path := NodePath()
@onready var _character: Node3D = get_node(character_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	var char_mesh: Mesh = _character.get_child(0).mesh
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, char_mesh.surface_get_arrays(0))
	var mdt = MeshDataTool.new() 
	mdt.create_from_surface(array_mesh, 0)
	for vtx in range(mdt.get_vertex_count()):
		var vert: Vector3 = mdt.get_vertex(vtx)
		#print(str(_character.get_child(0).global_transform.basis * vert) + " vs " + str(vert))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if character_path != null:
		material_override.set_shader_parameter(
			"character_position", _character.global_transform.origin
		)
		#if position.distance_to(_character.position) < 5:
			

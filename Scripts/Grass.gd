extends MultiMeshInstance3D

@export var character_path := NodePath()
@onready var _character: Node3D = get_node(character_path)
var wind_vector := Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	switch_shadows(Messenger.shadows_on)
	'''
	var char_mesh: Mesh = _character.get_child(0).mesh
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, char_mesh.surface_get_arrays(0))
	var mdt = MeshDataTool.new() 
	mdt.create_from_surface(array_mesh, 0)
	for vtx in range(mdt.get_vertex_count()):
		var vert: Vector3 = mdt.get_vertex(vtx)
		#print(str(_character.get_child(0).global_transform.basis * vert) + " vs " + str(vert))
	'''
	
	Messenger.SHADOWS.connect(switch_shadows)
	Messenger.WIND_CHANGE_Z.connect(wind_change_z)
	Messenger.WIND_CHANGE_X.connect(wind_change_x)
	
func switch_shadows(shadows_on):
	if shadows_on:
		self.set_cast_shadows_setting(SHADOW_CASTING_SETTING_ON)
	else:
		self.set_cast_shadows_setting(SHADOW_CASTING_SETTING_OFF)
	
func wind_change_x(value):
	wind_vector.x = value + randf_range(-0.3,0.3)
	material_override.set_shader_parameter(
			"wind_direction", wind_vector
		)
		
func wind_change_z(value):
	wind_vector.z = value + randf_range(-0.3,0.3)
	material_override.set_shader_parameter(
			"wind_direction", wind_vector
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	if character_path != null:
		'''
		material_override.set_shader_parameter(
			"character_position", _character.global_transform.origin
		)
		'''
		material_override.set_shader_parameter(
			"right_foot_position", _character.right_foot_position
		)
		material_override.set_shader_parameter(
			"left_foot_position", _character.left_foot_position
		)

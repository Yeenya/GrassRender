extends Node3D

@export var plane_scene: Resource
@export var radius = 8
@export var speed = 0.12
@export var size = 10
var plane_map = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Messenger.TIME_SET_MORNING.connect(set_morning)
	Messenger.TIME_SET_DAY.connect(set_day)
	Messenger.TIME_SET_EVENING.connect(set_evening)
	Messenger.TIME_SET_NIGHT.connect(set_night)
	
func set_morning():
	$DirectionalLight3D.rotation.x = 0.0
	$DirectionalLight3D.visible = true
func set_day():
	$DirectionalLight3D.rotation.x = -1.0
	$DirectionalLight3D.visible = true
	
func set_evening():
	$DirectionalLight3D.rotation.x = 180.0
	$DirectionalLight3D.visible = true
	
func set_night():
	$DirectionalLight3D.rotation.x = 90.0
	$DirectionalLight3D.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cam_grid_pos = $Player.position
	var cam_pos_2d = Vector2($Player.position.x,$Player.position.z)
	#Convert to grid coordinates
	cam_grid_pos.x = floor(cam_grid_pos.x / size)
	cam_grid_pos.z = floor(cam_grid_pos.z / size)
	#Unload planes
	for plane_pos in plane_map:
		if !is_in_radius(plane_pos,cam_pos_2d):
			unload_plane(plane_pos)
	#Load planes
	for p_x in range(cam_grid_pos.x-radius,cam_grid_pos.x+radius):
		for p_y in range(cam_grid_pos.z-radius,cam_grid_pos.z+radius):
			var plane_pos = Vector2(p_x*size+size/2,p_y*size+size/2)
			if is_in_radius(plane_pos,cam_pos_2d):
				load_plane(plane_pos)
	
	'''
	var direction = Vector3(0,0,0)
	if Input.is_action_pressed("cam_left"):
		direction.x = -1
	if Input.is_action_pressed("cam_right"):
		direction.x = 1
	if Input.is_action_pressed("cam_forward"):
		direction.z = -1
	if Input.is_action_pressed("cam_backward"):
		direction.z = 1
	if Input.is_action_pressed("cam_up"):
		direction.y = 1
	if Input.is_action_pressed("cam_down"):
		direction.y = -1
	
	#Fast movement
	if Input.is_action_just_pressed("cam_fast"):
		speed *= 4
	if Input.is_action_just_released("cam_fast"):
		speed /= 4
	
	#Move in direction relative to camera
	$Camera.position += $Camera.transform.basis * (direction * speed)
	'''
	
var LOOKAROUND_SPEED = 0.003
# accumulators
var rot_x = 0
var rot_y = 0
	
func _input(event):
	pass
	'''
	if event is InputEventMouseMotion:
		# modify accumulated mouse rotation
		rot_x += event.relative.x * LOOKAROUND_SPEED
		rot_y += event.relative.y * LOOKAROUND_SPEED
		$Camera.transform.basis = Basis() # reset rotation
		$Camera.rotate_object_local(Vector3(0, -1, 0), rot_x) # first rotate in Y
		$Camera.rotate_object_local(Vector3(-1, 0, 0), rot_y) # then rotate in X
		'''

func is_in_radius(p: Vector2,cam_pos: Vector2):
	return p.distance_to(cam_pos) <= radius*size

func load_plane(p: Vector2):
	if !plane_map.has(p):
		plane_map[p] = plane_scene.instantiate()
		plane_map[p].position = Vector3(p.x,0,p.y)
		plane_map[p].get_node("Grass").character_path = $Player.get_path()
		add_child(plane_map[p])

func unload_plane(p: Vector2):
	if plane_map.has(p):
		plane_map[p].queue_free()
		plane_map.erase(p)

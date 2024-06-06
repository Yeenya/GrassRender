extends CharacterBody3D

@onready var camera_mount = $Camera_mount
@onready var animation_player = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals = $Visuals

const SPEEDBASE = 10
var SPEED: int
const JUMP_VELOCITY = 10

@export var sens_horizontal = 0.1
@export var sens_vertical = 0.1
var right_foot: int
var left_foot: int
@export var right_foot_position: Vector3
@export var left_foot_position: Vector3

@onready var default_cam_position = $Camera_mount/Camera3D.position
var zoom_amount = 1.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	right_foot = $Visuals/mixamo_base/Armature/Skeleton3D.find_bone("mixamorig_RightToeBase")
	left_foot = $Visuals/mixamo_base/Armature/Skeleton3D.find_bone("mixamorig_LeftToeBase")

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
	if event.is_action_pressed("zoom_in"):
		zoom_amount -= 0.1
		if zoom_amount < 0.1:
			zoom_amount = 0.1
	if event.is_action_pressed("zoom_out"):
		zoom_amount += 0.1
		if zoom_amount > 3:
			zoom_amount = 3
	$Camera_mount/Camera3D.position = default_cam_position * zoom_amount + Vector3(0.0, -0.5, -0.5)

func _physics_process(delta):
	SPEED = SPEEDBASE * $Visuals/mixamo_base/AnimationPlayer.speed_scale
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if animation_player.current_animation != "walking":
			animation_player.play("walking")
		visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	right_foot_position = ($Visuals/mixamo_base/Armature/Skeleton3D.global_transform * $Visuals/mixamo_base/Armature/Skeleton3D.get_bone_global_pose(right_foot)).origin
	left_foot_position = ($Visuals/mixamo_base/Armature/Skeleton3D.global_transform * $Visuals/mixamo_base/Armature/Skeleton3D.get_bone_global_pose(left_foot)).origin

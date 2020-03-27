extends KinematicBody

onready var ray = get_node("/root/level/controller/RayCast")
onready var rayLight = get_node("/root/level/controller/Spotlight")
onready var camera = get_node("/root/level/controller")
onready var placer = get_node("/root/level/placer")
onready var carrier = get_node("/root/level/carrier")

export var SPEED = 40
export var mouse_sensitivity = .3
export var camera_x_rotation = 0

var velocity = Vector3(0,0,0)

# Helper functions
func get_input():
	var input_dir = Vector3()
	if Input.is_action_pressed("move_foward"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += camera.global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir

var world;
var selecting = true
var moving = false
var lastPoint;

func _ready():
	world = get_parent()
	set_process_input(true)
	set_process(true)

func _input(event):
	if Input.is_action_pressed("move_objects"):
		ray.rotation = Vector3(0,0,0)
		#rayLight.
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		moving = true
		selecting = false
		
	if Input.is_action_pressed("select_objects"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		moving = false
		selecting = true
	
	if Input.is_action_pressed("place_object"):
		# var scene = load("res://block.tscn")
		# var player = scene.instance()
		# add_child(player)
		placer.transform.origin = Vector3(
			lastPoint.x,
			0,
			lastPoint.z
		)
		
	if event is InputEventMouseMotion and moving:
		ray.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))

		# stop the mouse movement from passing 90 digrees for a more fluid control system
		var x_delta = event.relative.y * mouse_sensitivity
		if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90 :
			ray.rotate_x(deg2rad(-x_delta))
			camera_x_rotation += x_delta
			# camera.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
			
	if event is InputEventMouseMotion and Input.is_action_pressed("free_rotate"):
		camera.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))

		# stop the mouse movement from passing 90 digrees for a more fluid control system
		# var x_delta = event.relative.y * mouse_sensitivity
		# if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90 :
			# camera.rotate_x(deg2rad(-x_delta))
			# camera_x_rotation += x_delta
			# camera.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
	
func _physics_process(delta):
	# right left direct movement
	# velocity.y += GRAVITY * delta
	var desired_velocity = get_input() * SPEED

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z

	velocity = move_and_slide(velocity, Vector3.UP, true)

	# get point where ray is coliding
	if ray.is_colliding() and selecting==true:
		print("Colliding at point", ray.get_collision_point())
		# block.transform.origin = ray.get_collision_point()
		lastPoint =  ray.get_collision_point()
		carrier.transform.origin = Vector3(
			lastPoint.x,
			0,
			lastPoint.z
		)

func _fixed_process(delta):
	print("_fixed_process called")
	var space_state = get_world().get_direct_space_state()
	# use global coordinates, not local to node
	var result = space_state.intersect_ray( Vector2(0,0), Vector2(50,100) )
	
	if (not result.empty()):
		print("Hit at point: ",result.position)

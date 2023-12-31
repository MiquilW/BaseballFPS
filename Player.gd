extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 4.5
const FORCE = 500
const SENS = 0.001

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var anim := $Neck/Camera3D/Bat/AnimationPlayer
@onready var ray := $Neck/Camera3D/RayCast3D
	
func _ready():
	camera.current = true

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * SENS)
			camera.rotate_x(-event.relative.y * SENS)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		anim.play("swing")
		if ray.is_colliding() and ray.get_collider().is_in_group("ball"):
			var dir = (neck.transform.basis * Vector3(0, 0, -1)).normalized()
			var ball = ray.get_collider()
			dir = Vector3(dir.x, camera.rotation.x, dir.z)
			ball.apply_central_force(dir * FORCE)
			ball.set_gravity_scale(1)

	move_and_slide()
	

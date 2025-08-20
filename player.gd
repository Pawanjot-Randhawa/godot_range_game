extends CharacterBody3D

@export_range(0.0, 2.0) var sensitivity := .5
@export var sprint_ratio = 2
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var friction = 5.0
@export var roation_speed = 12

@onready var camera_pivot = $CameraPivot
@onready var camera = %Camera3D
@onready var model = $Barbarian

var camera_input_direction = Vector2.ZERO
var last_input_direction := Vector3.BACK
var aiming = false
var tween

signal is_aiming
signal is_not_aiming
signal hit_escape

func _input(event: InputEvent) -> void:
	#following if block is to only mouse cam if winodw is in focus
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		hit_escape.emit()
		
	if event.is_action_pressed("aiming"):
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property($CameraPivot/SpringArm3D, "position", Vector3(2,0.5,-2), 0.5)
		aiming = true
		is_aiming.emit()
	if event.is_action_released("aiming"):
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property($CameraPivot/SpringArm3D, "position", Vector3(0,1.5,0), 0.5)		
		is_not_aiming.emit()
		
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED #only when cursor is bound to game window
	)
	if is_camera_motion:
		camera_input_direction = event.screen_relative * sensitivity

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
		velocity.z = move_toward(velocity.z, 0, friction)
		
	#CUSTOM CODE
	#store last direciton player made
	if direction.length() > 0.2:
		last_input_direction = direction
	
	#play animations
	var ground_speed = velocity.length()
	if ground_speed > 0:
		$Barbarian/AnimationPlayer.play("Running_B")
	else:
		$Barbarian/AnimationPlayer.play("Idle")
	
	#camera rotaion for free looking
	if aiming:
		rotate_y(-deg_to_rad(camera_input_direction.x))
		model.look_at(position + direction)
		#lock up and down aiming until i can fix the snap back
		#camera_pivot.rotate_x(-deg_to_rad(camera_input_direction.y))
	#camera roation for 3d person camera
	else:		
		camera_pivot.rotation.x += camera_input_direction.y * delta #vertical roation
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI / 6, PI / 3) #clamp to pervent too much vertical camera movment
		camera_pivot.rotation.y += camera_input_direction.x * delta #horizontal roation
		#rotate skin to face last direction
		var target_angle = Vector3.BACK.signed_angle_to(last_input_direction, Vector3.UP)
		model.global_rotation.y = lerp_angle(model.rotation.y, target_angle, roation_speed * delta)
	
	camera_input_direction = Vector2.ZERO

	move_and_slide()

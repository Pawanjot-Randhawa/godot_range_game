extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export_range(0.25, 2) var AIM_SENSITIVITY = 0.25

@onready var camera_pivot: Node3D = $CameraPivot
@onready var model: Node3D = $Rogue_Hooded
@onready var animation_player: AnimationPlayer = $Rogue_Hooded/AnimationPlayer

const SMOOTH_SPEED = 10.0

var aiming = false

signal is_aiming
signal is_not_aiming

func _input(event: InputEvent) -> void:
	#following if block is to only mouse cam if winodw is in focus
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event.is_action_pressed("aiming"):
		var tween = get_tree().create_tween()
		tween.tween_property($CameraPivot/Camera3D, "position", Vector3(2,1.5,1.5), 0.5)
		aiming = true
		is_aiming.emit()
	if event.is_action_released("aiming"):
		var tween = get_tree().create_tween()
		tween.tween_property($CameraPivot/Camera3D, "position", Vector3(2,2,3), 0.5)
		aiming = false
		is_not_aiming.emit()
		
	#camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * AIM_SENSITIVITY ))
		camera_pivot.rotate_x(deg_to_rad(-event.relative.y * AIM_SENSITIVITY)) #rotate around pivot for vertical rotation
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-45), deg_to_rad(45)) #clamp it to pervent too much up down
		if !aiming:
			model.rotate_y(deg_to_rad(event.relative.x * AIM_SENSITIVITY )) #done to make player static


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
	var visual_dir = -Vector3(input_dir.x, 0, input_dir.y).normalized()#used for smoothing, had to make negatvie since model is backwards
	if aiming:
			pass#model.look_at($CameraPivot/Camera3D.transform.basis.z, Vector3.UP)#model.look_at(position-direction) #more snappy for aim down sight
	if direction: #if block for if charcter is moving
		if animation_player.current_animation!="Running_B": #do it like this to pervent animation fropm replaying 
			animation_player.play("Running_B")
		if !aiming:
			model.rotation.y = lerp_angle(model.rotation.y, atan2(-visual_dir.x, -visual_dir.z), delta * SMOOTH_SPEED) #rotates model smoothly
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation!="Idle": 
			animation_player.play("Idle")
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()

extends Node

const STARTINGMENU = preload("res://startingmenu.tscn")
@onready var ui: Control = $UI
@onready var crosshair = $UI/TextureRect
@onready var escape_menu: Control = $UI/EscapeMenu
@onready var escape_menu_buttons: VBoxContainer = $UI/EscapeMenu/EscapeMenuButtons
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	crosshair.visible = false
	escape_menu.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and escape_menu.visible == false:
		escape_menu.visible = true
		ui.mouse_filter = Control.MOUSE_FILTER_PASS
		ui.grab_focus()
		print("escape Menu on")
	elif event.is_action_pressed("ui_cancel") and escape_menu.visible == true:
		escape_menu.visible = false
		ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("escape Menu off")


func _on_rougue_is_aiming() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property($AudioStreamPlayer, "pitch_scale", 1.5, 0.5)
	await tween.finished
	crosshair.visible = true


func _on_rougue_is_not_aiming() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property($AudioStreamPlayer, "pitch_scale", 1, 0.5)
	if tween.is_running():
		crosshair.visible = false


func _on_main_menu_pressed() -> void:
	print("main!")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_packed(STARTINGMENU)


func _on_quit_pressed() -> void:
	print("quit!")
	get_tree().quit()

func _on_audio_toggle_toggled(toggled_on: bool) -> void:
	print("audio toggle")
	if(toggled_on == true):
		audio_stream_player.play()
	else:
		audio_stream_player.stop()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

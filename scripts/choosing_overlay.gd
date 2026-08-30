extends Node2D

@onready var gun: AnimatedSprite2D = $Gun
@onready var human_explosion: Node2D = $human_explosion
@onready var character: Node2D = $"../Character_slim"
@onready var alien_explosion: Node2D = $alien_explosion

@export var target_position: Vector2 = Vector2(592, 553)
@export var start_pos: Vector2 = Vector2(577, 716)
@export var move_duration: float = 1.0

signal allow_pressed
signal deny_pressed

var forbidden_top_type: String = "tshirt"
var forbidden_color: Color = Color.WHITE

func is_character_allowed() -> bool:
	#if character.apperance_data["top_type"] == forbidden_top_type:
		#return false
		#
	#if character.apperance_data["top_type"] != "none" and character.aperance_data["top_color"] == forbidden_color:
		#return false
	return true

func _on_button_pressed() -> void:
	deny_pressed.emit()
	gun.visible = true
	var tween := create_tween()
	tween.tween_property(gun, "position", target_position, move_duration)

	tween.finished.connect(func ():
		gun.play()
		#human_explosion.visible = true
		#human_explosion.play_splatter()
		print("alle weg alle weg ich komme")
	)

func play_alien_explosion():
	alien_explosion.visible = true
	alien_explosion.play_splatter()

func play_human_explosion():
	human_explosion.visible = true
	human_explosion.play_splatter()

func _on_button_pressed_in() -> void:
	allow_pressed.emit()
	
	# Hier irgendwie signal das der spieler rein kommt
	

func reset():
	gun.stop()
	gun.position = start_pos
	human_explosion.visible = false

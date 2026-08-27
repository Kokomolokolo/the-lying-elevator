extends Node2D

@onready var gun: AnimatedSprite2D = $Gun
@onready var human_explosion: Node2D = $human_explosion

@export var target_position: Vector2 = Vector2(592, 553)
@export var move_duration: float = 1.0

var forbidden_top_type: String = "tshirt"
var forbidden_color: Color = Color.WHITE

func is_character_allowed() -> bool:
	var character = get_tree().get_first_node_in_group("character")
	if character: 
		if character.aperance_data["top_type"] == forbidden_top_type:
			return false
		
		if character.appearance_data["top_type"] != "none" and character.aperance_data["top_color"] == forbidden_color:
			return false
	return true

func _on_button_pressed() -> void:
	print("JLKDFKJ")
	var tween := create_tween()
	tween.tween_property(gun, "position", target_position, move_duration)

	tween.finished.connect(func ():
		gun.play()
		if is_character_allowed():
			print("dumbo gekackt")
			human_explosion.visible = true
			human_explosion.play_splatter()
		else:
			print("premium geschafft")
		print("alle weg alle weg ich komme")
	)
	self.visible = false
		
func _on_button_pressed_in() -> void:
	if is_character_allowed():
		print("LetIn")
	else:
		print("not allowed")
			
	# Hier irgendwie signal das der spieler rein kommt
	

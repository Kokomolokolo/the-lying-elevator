extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $Erase/AnimatedSprite2D

@export var target_position: Vector2 = Vector2(-125, -10)
@export var move_duration: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_button_pressed() -> void:
	print("JLKDFKJ")
	var tween := create_tween()
	
	tween.tween_property(animated_sprite, "position", target_position, move_duration)

	tween.finished.connect(func ():
		animated_sprite.play()
		print("alle weg alle weg ich komme")
		)
	# Entscheiden ob mensch oder alien getötet
		
func _on_button_pressed_in() -> void:
	var checker = get_tree().get_first_node_in_group("checker")
	if checker:
		if checker.is_chatacter_allowed():
			print("LetIn")
		else:
			print("not allowed")
	else: 
		print("no checker")
			
	# Hier irgendwie signal das der spieler rein kommt
	

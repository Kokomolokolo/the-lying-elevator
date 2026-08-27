extends AnimatedSprite2D

@onready var door_sound: AudioStreamPlayer = $door_opening_sound

var is_open: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		toggle_doors()

func toggle_doors() -> void:
	door_sound.play()

	if not is_open:
		play("default")
		is_open = true
	else:
		play_backwards("default")
		is_open = false

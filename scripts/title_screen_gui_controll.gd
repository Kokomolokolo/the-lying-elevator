extends Control

@onready var play_button: TextureButton = $PlayButton
@onready var quit_button: TextureButton = $QuitButton

func _ready() -> void:
	for btn in [play_button, quit_button]:
		_setup_button_hover(btn)

	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _setup_button_hover(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size / 2
	btn.mouse_entered.connect(func(): _animate_scale(btn, Vector2(1.2, 1.2)))
	btn.mouse_exited.connect(func(): _animate_scale(btn, Vector2(1.0, 1.0)))

func _animate_scale(btn: TextureButton, target_scale: Vector2) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", target_scale, 0.2)

func _on_play_pressed() -> void:
	$PlayButton/AudioStreamPlayer.play()
	await $PlayButton/AudioStreamPlayer.finished
	Engine.get_main_loop().change_scene_to_file("res://scenes/explaning.tscn")
	
func _on_quit_pressed() -> void:
	$QuitButton/AudioStreamPlayer.play()
	await $QuitButton/AudioStreamPlayer.finished
	get_tree().quit()

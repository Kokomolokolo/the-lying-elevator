extends Node2D

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var splatter_sound: AudioStreamPlayer = $AnimatedSprite2D/Splatter_sound

func play_splatter() -> void:
	splatter_sound.play()
	animation_player.play()

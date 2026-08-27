extends Node2D

@onready var animation_player: AnimatedSprite2D = $Splatter
@onready var splatter_sound: AudioStreamPlayer = $Splatter_sound

func play_splatter() -> void:
	splatter_sound.play()
	animation_player.play()

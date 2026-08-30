extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var splatter_sound: AudioStreamPlayer = $AnimatedSprite2D/Splatter_sound

func play_splatter() -> void:
	splatter_sound.play()
	animation_player.play()

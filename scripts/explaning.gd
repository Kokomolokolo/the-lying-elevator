extends Node2D
@onready var boss: Sprite2D = $Boss
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rot = randf_range(-0.2, 0.2)
	boss.rotation = rot

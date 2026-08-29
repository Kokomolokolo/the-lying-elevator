extends Node2D

@onready var boss: Sprite2D = $Boss

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var tween := create_tween()
	var rot = randf_range(-0.3, 0.3)
	
	tween.tween_property(boss, "rotation", rot, 0.7)

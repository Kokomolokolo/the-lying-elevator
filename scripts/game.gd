extends Node2D
@onready var elevator_background: Sprite2D = $elevator_doors/ElevatorBackground
@onready var elevator_doors: AnimatedSprite2D = $elevator_doors
@onready var choosing: Node2D = $choosing
@onready var character: Node2D = $Character_slim

var target_pos = Vector2(-120, 760)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	choosing.allow_pressed.connect(_on_allow_received)

func _on_allow_received() -> void:
	var tween := create_tween()
	character.z_index = 10
	tween.tween_property(character, "position", target_pos, 1.0)
	
	# Wieder zurück gehen das muss besser gemacht werden
	tween.finished.connect(func():
		character.position = Vector2(588, 388)
		character.z_index = -1
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if elevator_doors.is_open:
		choosing.visible = true
	else: 
		choosing.visible = false

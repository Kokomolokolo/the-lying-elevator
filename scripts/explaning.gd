extends Node2D
@onready var boss: Sprite2D = $Boss

@onready var label: Label = $Label

@onready var times_pressed = 0

var dialog = [
	"Our company has been 
	infiltrated by monsters!",
	"Luckiy, you can 
	tell who is real 
	and who is fake by 
	how they dress.",
	"I will update you! 
	As CEO, I leave you in 
	charnge of the elevators.",
	"Dont let those aliens
	on it,or you will be fired!", 
	"Trust no one!"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var tween := create_tween()
	var rot = randf_range(-0.3, 0.3)
	
	tween.tween_property(boss, "rotation", rot, 0.7)

	

func _unhandled_input(event: InputEvent) -> void:
	# Reagiert genau EINMAL beim Herunterdrücken
	
	if event.is_action_pressed("ui_accept"): # "ui_accept" ist standardmäßig u.a. die Leertaste
		times_pressed += 1
		print(times_pressed >= dialog.size() - 1)
		if times_pressed >= dialog.size():
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		else:
			label.text = dialog[0 + times_pressed]

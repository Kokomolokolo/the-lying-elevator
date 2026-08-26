extends Node2D

@export var textures: Dictionary = {
	"body_slim": preload("res://assets/pain_human.png"),
	"tshirt": preload("res://assets/white_shirt.png"),
	"hoodie": preload("res://assets/white_hoodie.png")
}

@export var appearance_data: Dictionary = {
	"body": textures["body_slim"],
	"hoodie_texture": null,
	"hoodie_color": null,
	"tshirt_texture": null,
	"tshirt_color": null,
	"tag": null,
}

@export var colors: Array[Color] = [
	Color.RED, Color.WHITE, Color.BLUE, Color.GREEN, Color.VIOLET
]

@onready var base_body: Sprite2D = $BaseBody
@onready var hoodie: Sprite2D = $Hoodie
@onready var tshirt: Sprite2D = $Tshirt
@onready var tag: Sprite2D = $Tag

@onready var elevator_doors = $"../elevator_doors"

func rand_color() -> Color:
	return colors[randi_range(0, len(colors) - 1)]

func rand_tshirt_or_hoodie(type: String) -> void:
	var chosen_color = rand_color()
	
	var color_key: String = type + "_color"
	var texture_key: String = type + "_texture"
	
	appearance_data[color_key] = chosen_color
	appearance_data[texture_key] = textures[type]
	
	var target_sprite: Sprite2D = hoodie if type == "hoodie" else tshirt
	target_sprite.texture = appearance_data[texture_key]
	target_sprite.modulate = appearance_data[color_key]


func rand_top() -> void:
	var roll: float = randf()

	if roll < 0.10: # 10% nackt
		appearance_data["top"] = "none"
		tshirt.visible = false
		hoodie.visible = false
	elif roll < 0.55: # 45% hoodie
		appearance_data["top"] = "hoodie"
		rand_tshirt_or_hoodie("hoodie")
		hoodie.visible = true
		tshirt.visible = false
	else: # 45% tshirt
		appearance_data["top"] = "tshirt"
		rand_tshirt_or_hoodie("tshirt")
		hoodie.visible = false
		tshirt.visible = true

func randomize_character() -> void:
	rand_top()
	base_body.texture = appearance_data["body"]

# zum trollen
func _on_doors_animation_finished() -> void:
	if elevator_doors.frame == 0:
		randomize_character()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	elevator_doors.animation_finished.connect(_on_doors_animation_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

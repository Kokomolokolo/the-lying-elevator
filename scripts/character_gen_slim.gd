extends Node2D

@export var textures: Dictionary = {
	"body_slim": preload("res://assets/pain_human.png"),
	"tshirt": preload("res://assets/white_shirt.png"),
	"hoodie": preload("res://assets/white_hoodie.png")
}

@export var appearance_data: Dictionary = {
	"body": "body_slim",
	"top_type": "none",
	"top_color": Color.WHITE,
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
	return colors.pick_random()

func rand_body() -> void:
	appearance_data["body"] = "body_slim"
	base_body.texture = textures[appearance_data["body"]]

func rand_top() -> void:
	var roll: float = randf()

	if roll < 0.10:
		appearance_data["top_type"] = "none"
		appearance_data["top_color"] = Color.WHITE
		tshirt.visible = false
		hoodie.visible = false
	elif roll < 0.55:
		rand_tshirt_or_hoodie("hoodie")
	else:
		rand_tshirt_or_hoodie("tshirt")

func rand_tshirt_or_hoodie(type: String) -> void:
	var chosen_color = rand_color()
	
	appearance_data["top_type"] = type
	appearance_data["top_color"] = chosen_color
	
	var active_sprite: Sprite2D = hoodie if type == "hoodie" else tshirt
	var inactive_sprite: Sprite2D = tshirt if type == "hoodie" else hoodie
	
	active_sprite.texture = textures[type]
	active_sprite.modulate = appearance_data["top_color"]
	active_sprite.visible = true
	inactive_sprite.visible = false

func randomize_character() -> void:
	rand_body()
	rand_top()


func _on_doors_animation_finished() -> void:
	if elevator_doors.frame == 0:
		randomize_character()
		

func _ready() -> void:
	add_to_group("character")
	elevator_doors.animation_finished.connect(_on_doors_animation_finished)
	randomize_character()

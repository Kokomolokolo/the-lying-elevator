extends Node2D

@export var textures: Dictionary = {
	"body_slim": preload("res://assets/pain_human.png"),
	"tshirt": preload("res://assets/white_shirt.png"),
	"hoodie": preload("res://assets/white_hoodie.png"),
	"sneaker": preload("res://assets/sneaker.png"),
	"boots": preload("res://assets/boots.png"),
	"pants": preload("res://assets/hose.png"),
	"hair": preload("res://assets/normal_hair.png"),
	"crazy_hair": preload("res://assets/crazy_hair.png"),
	"tag_red": preload("res://assets/tags/tag_red.png"),
	"tag_blue": preload("res://assets/tags/tag_blue.png"),
	"tag_green": preload("res://assets/tags/tag_green.png"),
	"tag_orange": preload("res://assets/tags/tag_orange.png"),
}

@export var appearance_data: Dictionary = {
	"body": "body_slim",
	"top_type": null,
	"top_color": Color.WHITE,
	"tag": null,
	"tag_color": null,
	"hair_type": "normal", # kann auch crazy sein
	"hair_color": Color.BROWN,
	"shoes": "sneaker", # boots
	"shoe_color": Color.RED,
	"pants_color": null, # wenn null keine pants
}

@export var colors: Array[Color] = [
	Color.RED, Color.WHITE, Color.BLUE, Color.GREEN, Color.VIOLET
]

@export var hair_color: Array[Color] = [
	Color.MAROON, Color.YELLOW, Color.ORANGE, Color.BLACK
]

@export var pants_color: Array[Color] = [
	Color.DARK_BLUE, Color.BEIGE, Color.LIGHT_BLUE, Color.BLACK
]

# Die ganzen Kleidungsstücke
@onready var base_body: Sprite2D = $BaseBody
@onready var hoodie: Sprite2D = $Hoodie
@onready var tshirt: Sprite2D = $Tshirt
@onready var tag: Sprite2D = $Tag
@onready var pants: Sprite2D = $Pants
@onready var hair: Sprite2D = $Hair
@onready var shoes: Sprite2D = $Shoes

@onready var elevator_doors = $"../elevator_doors"

func rand_color() -> Color:
	return colors.pick_random()

func rand_body() -> void:
	appearance_data["body"] = "body_slim"
	base_body.texture = textures[appearance_data["body"]]

func rand_sneaker_or_boots() -> void:
	appearance_data["shoe_color"] = colors.pick_random()
	if randf() < 0.5:
		appearance_data["shoes"] = "boots"
		shoes.texture = textures[appearance_data["shoes"]]
	else:
		appearance_data["shoes"] = "sneaker"
		shoes.texture = textures[appearance_data["shoes"]]
	shoes.modulate = appearance_data["shoe_color"]

func rand_pants() -> void:
	if randf() < 0.9: # 10% das ohne Hose
		appearance_data["pants_color"] = pants_color.pick_random()
		pants.texture = textures["pants"]
		pants.modulate = appearance_data["pants_color"]
		pants.visible = true
	else:
		appearance_data["pants_color"] = null
		pants.visible = false

func rand_hair() -> void:
	appearance_data["hair_color"] = hair_color.pick_random()
	
	if randf() < 0.9:
		appearance_data["hair_type"] = "hair"
		hair.texture = textures[appearance_data["hair_type"]]
	else:
		appearance_data["hair_type"] = "crazy_hair"
		hair.texture = textures["crazy_hair"]
	hair.modulate = appearance_data["hair_color"]

func rand_tag() -> void:	
	if randf() < 0.8: # 20% für einen tag
		appearance_data["tag"] = null
		tag.visible = false
	else:
		appearance_data["tag"] = ["tag_blue","tag_red","tag_orange","tag_green"].pick_random()
		tag.visible = true
		tag.texture = textures[appearance_data["tag"]]

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
	rand_sneaker_or_boots()
	rand_hair()
	rand_pants()
	rand_tag()


func _on_doors_animation_finished() -> void:
	if elevator_doors.frame == 0:
		randomize_character()
		

func _ready() -> void:
	add_to_group("character")
	elevator_doors.animation_finished.connect(_on_doors_animation_finished)
	randomize_character()

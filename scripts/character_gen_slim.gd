extends Node2D

@export var textures: Dictionary = {
	"body_slim": preload("res://assets/pain_human.png"),
	"tshirt": preload("res://assets/white_shirt.png"),
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

func rand_tshirt() -> void: 
	var color = rand_color()
	
	appearance_data["tshirt_color"] = color
	appearance_data["tshirt_color"] = textures["tshirt"]
	
	tshirt.texture = appearance_data["tshirt_texture"]
	tshirt.modulate = appearance_data["tshirt_color"]
	
func rand_top() -> void:
	var roll: float = randf() # Returns a random float between 0.0 and 1.0

	if roll < 0.10:
		appearance_data["top"] = "none"
		tshirt.visible = false # mache ich nur, weil im editor er ein tshirt anhaben muss wegen positionieren und so
		hoodie.visible = false
	elif roll < 0.55: # hoodie
		
		hoodie.visible = true
		tshirt.visible = false
	else: # thsirt
		rand_tshirt()
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

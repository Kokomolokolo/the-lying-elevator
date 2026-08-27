extends Node2D

var forbidden_top_type: String = "none"
var forbidden_color: Color = Color.TRANSPARENT

@export var colors: Array[Color] = [
	Color.RED, Color.WHITE, Color.BLUE, Color.GREEN, Color.VIOLET
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("checker")
	generate_random_rules()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_random_rules() -> void:
	if randf() < 0.5: 
		forbidden_top_type = ["hoddie", "thsirt"].pick_random()
	else:
		forbidden_top_type = "none"

func is_chatacter_allowed() -> bool:
	var character = get_tree().get_first_node_in_group("character")
	if character: 
		if character.aperance_data["top_type"] == forbidden_top_type:
			return false
		
		if character.appearance_data["top_type"] != "none" and character.aperance_data["top_color"] == forbidden_color:
			return false
		
	return true

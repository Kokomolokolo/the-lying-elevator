extends Node2D

@onready var elevator_background: Sprite2D = $elevator_doors/ElevatorBackground
@onready var elevator_doors: AnimatedSprite2D = $elevator_doors
@onready var choosing: Node2D = $choosing
@onready var character: Node2D = $Character_slim
@onready var boss: Node2D = $Boss
@onready var boss_text: Label = $Boss/boss_text

var start_pos = Vector2(588, 388)
var target_pos = Vector2(-120, 760)

var forbidden_rules: Dictionary = {
	"has_top": null, "top_type": null, "top_color": null,
	"shoes": null, "shoe_color": null,
	"hair_type": null, "hair_color": null,
	"has_tag": null, "tag_color": null, "has_pants": null
}

var guest_counter: int = 0
var max_guests_wave: int = 3
var is_processing_choice: bool = false

@export var colors: Array[Color] = [Color.RED, Color.WHITE, Color.BLUE, Color.GREEN, Color.VIOLET]
@export var hair_color: Array[Color] = [Color.MAROON, Color.YELLOW, Color.ORANGE, Color.BLACK]
@export var pants_color: Array[Color] = [Color.DARK_BLUE, Color.BEIGE, Color.LIGHT_BLUE, Color.BLACK]

var active_boss_message: String = ""

func _ready() -> void:
	# Buttons verbinden
	choosing.allow_pressed.connect(_on_allow_received)
	choosing.deny_pressed.connect(_on_deny_pressed)
	
	# Eigene Signale der Aufzugstür verbinden
	elevator_doors.door_opened.connect(_on_door_opened)
	
	# Am Anfang alles ausblenden & Boss-Phasen starten
	choosing.visible = false
	character.visible = false
	boss_visit()

# --- SPIELFLUSS & BOSS-PHASE ---

func boss_visit() -> void:
	elevator_doors.open_doors()
	is_processing_choice = true
	character.visible = false
	choosing.visible = false
	
	# Boss anzeigen während die Türen noch ZU sind
	boss.visible = true
	boss_text.text = generate_boss_rules()
	
	# Boss bleibt 3.5 Sekunden sichtbar
	get_tree().create_timer(3.5).timeout.connect(func():
		elevator_doors.close_doors()
		get_tree().create_timer(1.).timeout.connect(func():
			boss.visible = false
			guest_counter = 0
			open_elevator_for_next_guest()
			)
	)

func open_elevator_for_next_guest() -> void:
	character.position = start_pos
	character.z_index = -1
	character.visible = true
	character.randomize_character()
	
	# Türen automatisch öffnen
	elevator_doors.open_doors()

func _on_door_opened() -> void:
	# Buttons ERST anzeigen, wenn die Tür komplett offen ist!
	if character.visible:
		choosing.visible = true
		is_processing_choice = false

# --- DECISION LOGIK ---

func _on_allow_received() -> void:
	if is_processing_choice: return
	is_processing_choice = true
	choosing.visible = false
	
	var allowed = is_character_allowed(character.appearance_data)
	print("Ergebnis: ", "Richtig! Mensch" if allowed else "Falsch! Alien")
	
	var tween := create_tween()
	character.z_index = 10
	tween.tween_property(character, "position", target_pos, 1.0)
	
	tween.finished.connect(func():
		elevator_doors.close_doors()
		_on_guest_action_finished()
	)

func _on_deny_pressed() -> void:
	if is_processing_choice: return
	is_processing_choice = true
	#choosing.visible = false
	
	var allowed = is_character_allowed(character.appearance_data)
	print("Ergebnis: ", "Falsch! Mensch abgewiesen" if allowed else "Richtig! Alien abgewiesen")
	
	# Tür schließt direkt
	get_tree().create_timer(2.3).timeout.connect(func():
		choosing.visible = false
		elevator_doors.close_doors()
		_on_guest_action_finished()
		choosing.reset()
	)

func _on_guest_action_finished() -> void:
	guest_counter += 1
	
	# Warten bis die Schließ-Animation vorbei ist & Pause machen
	get_tree().create_timer(1.5).timeout.connect(func():
		if guest_counter >= max_guests_wave:
			boss_visit()
		else:
			open_elevator_for_next_guest()
	)

# --- PRÜFUNG & GENERATOR ---

func is_character_allowed(data: Dictionary) -> bool:
	if forbidden_rules["has_top"] == false and data["top_type"] == "none": return false
	if forbidden_rules["top_type"] != null and data["top_type"] == forbidden_rules["top_type"]: return false
	if forbidden_rules["top_color"] != null and data["top_type"] != "none" and data["top_color"] == forbidden_rules["top_color"]: return false
	if forbidden_rules["shoes"] != null and data["shoes"] == forbidden_rules["shoes"]: return false
	if forbidden_rules["shoe_color"] != null and data["shoe_color"] == forbidden_rules["shoe_color"]: return false
	if forbidden_rules["hair_type"] != null and data["hair_type"] == forbidden_rules["hair_type"]: return false
	if forbidden_rules["hair_color"] != null and data["hair_color"] == forbidden_rules["hair_color"]: return false
	if forbidden_rules["has_tag"] == true and data["tag"] != null: return false
	if forbidden_rules["tag_color"] != null and data["tag"] == forbidden_rules["tag_color"]: return false
	if forbidden_rules["has_pants"] == false and data["pants_color"] == null: return false
	return true

func generate_boss_rules() -> String:
	for key in forbidden_rules.keys():
		forbidden_rules[key] = null
		
	var category = randi() % 6
	match category:
		0:
			if randf() < 0.5:
				forbidden_rules["has_tag"] = true
				active_boss_message = "BOSS: 'The survivors turned in all their ID tags. 
				Anyone still wearing a tag is an alien!'"
			else:
				var forbidden_tag = ["tag_blue", "tag_red", "tag_orange", "tag_green"].pick_random()
				forbidden_rules["tag_color"] = forbidden_tag
				var tag_name = forbidden_tag.replace("tag_", "").capitalize()
				active_boss_message = "BOSS: 'Warning! Aliens hacked the " + tag_name + " tags. 
				Do NOT let anyone with that tag in!'"
		1:
			if randf() < 0.4:
				forbidden_rules["has_top"] = false
				active_boss_message = "BOSS: 'Aliens tend to forget their clothes. 
				Anyone shirtless gets rejected!'"
			elif randf() < 0.7:
				forbidden_rules["top_type"] = ["hoodie", "tshirt"].pick_random()
				active_boss_message = "BOSS: 'Shapeshifters currently prefer wearing " + forbidden_rules["top_type"] + "s. 
				No " + forbidden_rules["top_type"] + "s today!'"
			else:
				forbidden_rules["top_color"] = colors.pick_random()
				active_boss_message = "BOSS: 'Alien blood stains clothing. 
				Anyone wearing a top with this exact color is infected!'"
		2:
			if randf() < 0.5:
				forbidden_rules["hair_type"] = "crazy_hair"
				active_boss_message = "BOSS: 'Brain parasites cause wild hair growth! 
				Reject anyone with crazy hair!'"
			else:
				forbidden_rules["hair_color"] = hair_color.pick_random()
				active_boss_message = "BOSS: 'Radiation alters hair color. 
				Watch out for people with this hair color!'"
		3:
			forbidden_rules["has_pants"] = false
			active_boss_message = "BOSS: 'I don't care if it's mutation or panic: 
				anyone without pants stays outside!'"
		4:
			if randf() < 0.5:
				forbidden_rules["shoes"] = ["sneaker", "boots"].pick_random()
				active_boss_message = "BOSS: 'Alien tentacles don't fit into " + forbidden_rules["shoes"] + ". 
				Those shoes are banned!'"
			else:
				forbidden_rules["shoe_color"] = colors.pick_random()
				active_boss_message = "BOSS: 'Aliens stole shoes from the cafeteria staff! 
				Watch out for this shoe color:" + forbidden_rules["shoe_color"] + "'"
		5:
			forbidden_rules["has_pants"] = false
			forbidden_rules["has_tag"] = true
			active_boss_message = "BOSS: 'Security Code Red! No one without pants AND no one wearing a tag gets through!'"

	print(active_boss_message)
	return active_boss_message

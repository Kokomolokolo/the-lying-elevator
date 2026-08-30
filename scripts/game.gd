extends Node2D

@onready var elevator_background: Sprite2D = $elevator_doors/ElevatorBackground
@onready var elevator_doors: AnimatedSprite2D = $elevator_doors
@onready var choosing: Node2D = $choosing
@onready var character: Node2D = $Character_slim
@onready var boss: Node2D = $Boss
@onready var boss_text2: Label = $Boss/boss_text3
@onready var boss_text: RichTextLabel = $Boss/boss_text

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
		get_tree().create_timer(0.8).timeout.connect(func():
			boss.visible = false
			streak.visible = true
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
		if not allowed:
			game_over("alien")
		else:
			add_to_streak()
			elevator_doors.close_doors()
			_on_guest_action_finished()
	)

func _on_deny_pressed() -> void:
	if is_processing_choice: return
	is_processing_choice = true
	#choosing.visible = false
	
	var human = is_character_allowed(character.appearance_data)
	print("Ergebnis: ", "Falsch! Mensch abgewiesen" if human else "Richtig! Alien abgewiesen")
	if human:
		get_tree().create_timer(1.0).timeout.connect(choosing.play_human_explosion)
	else:
		get_tree().create_timer(1.0).timeout.connect(choosing.play_alien_explosion)
	# Tür schließt
	get_tree().create_timer(2.2).timeout.connect(func():
		if human:
			game_over("human")
		else:
			add_to_streak()
			choosing.visible = false
			elevator_doors.close_doors()
			_on_guest_action_finished()
			choosing.reset()
	)
@onready var gameover: Label = $gameover
@onready var subtext: Label = $gameover/subtext

func game_over(type: String):
	if type == "human":
		gameover.visible = true
		gameover.text = "Game Over"
		subtext.text = "You killed a human!"
	else:
		gameover.visible = true
		gameover.text = "Game Over"
		subtext.text = "You let in a alien!"
	get_tree().create_timer(3.).timeout.connect(func():
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	)
@onready var streak: Label = $streak
var streak_number = 0
func add_to_streak() -> void:
	streak_number += 1
	streak.text = str(streak_number) + " correct in a row!"
	
	# Pivot-Punkt in die Mitte setzen, damit Drehung & Skalierung aus der Mitte geschehen
	streak.pivot_offset = streak.size / 2.0
	
	var target_scale = Vector2(1.5, 1.5) # Finale/Größere Zielgröße
	var pop_scale = Vector2(2.0, 2.0)    # Maximaler Plopp-Effekt
	var random_rot = randf_range(-0.15, 0.15) # Leichte temporäre Drehung
	
	# Paralleles Tweening für simultanes Rotieren & Skalieren
	var tween := create_tween().set_parallel(true)
	
	# 1. Aufploppen + kurz leicht eindrehen
	tween.tween_property(streak, "scale", pop_scale, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EaseType.EASE_OUT)
	tween.tween_property(streak, "rotation", random_rot, 0.1)
	
	# 2. Zurückfedern zur Zielgröße + Drehung wieder exakt auf 0 (gerade) zurücksetzen
	tween.chain().tween_property(streak, "scale", target_scale, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EaseType.EASE_OUT)
	tween.parallel().tween_property(streak, "rotation", 0.0, 0.2)

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
	# Die Reset-Schleife wurde entfernt. Alte Regeln bleiben in 'forbidden_rules' gespeichert!
	
	var category = randi() % 6
	
	match category:
		0:
			if randf() < 0.5:
				forbidden_rules["has_tag"] = true
				active_boss_message = "The survivors turned in all their ID tags. Anyone still wearing a [b]tag[/b] is an alien!"
			else:
				var forbidden_tag = ["tag_blue", "tag_red", "tag_orange", "tag_green"].pick_random()
				forbidden_rules["tag_color"] = forbidden_tag
				var tag_name = forbidden_tag.replace("tag_", "").capitalize()
				active_boss_message = "Warning! Aliens hacked the [b]" + tag_name + " tags[/b]. Do NOT let anyone with that tag in!"
		1:
			if randf() < 0.4:
				forbidden_rules["has_top"] = false
				active_boss_message = "Aliens tend to forget their clothes. Anyone [b]shirtless[/b] gets rejected!"
			elif randf() < 0.7:
				var t_type = ["hoodie", "tshirt"].pick_random()
				forbidden_rules["top_type"] = t_type
				active_boss_message = "Shapeshifters currently prefer wearing " + t_type + "s. No [b]" + t_type + "s[/b] today!"
			else:
				var t_color = colors.pick_random()
				forbidden_rules["top_color"] = t_color
				active_boss_message = "Alien blood stains clothing. Anyone wearing a [b]" + get_color_name(t_color) + " top[/b] is infected!"
		2:
			if randf() < 0.5:
				forbidden_rules["hair_type"] = "crazy_hair"
				active_boss_message = "Brain parasites cause wild hair growth! Reject anyone with [b]crazy hair[/b]!"
			else:
				var h_color = hair_color.pick_random()
				forbidden_rules["hair_color"] = h_color
				active_boss_message = "Radiation alters hair color. Watch out for people with [b]" + get_color_name(h_color) + " hair[/b]!"
		3:
			forbidden_rules["has_pants"] = false
			active_boss_message = "I don't care if it's mutation or panic: anyone [b]without pants[/b] stays outside!"
		4:
			if randf() < 0.5:
				var s_type = ["sneaker", "boots"].pick_random()
				forbidden_rules["shoes"] = s_type
				active_boss_message = "Alien tentacles don't fit into " + s_type + ". Those [b]" + s_type + "[/b] are banned!"
			else:
				var s_color = colors.pick_random()
				forbidden_rules["shoe_color"] = s_color
				active_boss_message = "Aliens stole shoes from the cafeteria staff!Watch out for [b]" + get_color_name(s_color) + " shoes[/b]!"
		5:
			forbidden_rules["has_pants"] = false
			forbidden_rules["has_tag"] = true
			active_boss_message = "Security Code Red! No one [b]without pants[/b] AND no one wearing a [b]tag[/b] gets through!"

	print(active_boss_message)
	return active_boss_message


func get_color_name(c: Color) -> String:
	if c == Color.RED: return "Red"
	if c == Color.WHITE: return "White"
	if c == Color.BLUE: return "Blue"
	if c == Color.GREEN: return "Green"
	if c == Color.VIOLET: return "Violet"
	if c == Color.MAROON: return "Maroon"
	if c == Color.YELLOW: return "Yellow"
	if c == Color.ORANGE: return "Orange"
	if c == Color.BLACK: return "Black"
	if c == Color.DARK_BLUE: return "Dark Blue"
	if c == Color.BEIGE: return "Beige"
	if c == Color.LIGHT_BLUE: return "Light Blue"
	return "Unknown Color"

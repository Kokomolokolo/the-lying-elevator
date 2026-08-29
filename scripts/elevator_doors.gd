extends AnimatedSprite2D

@onready var door_sound: AudioStreamPlayer = $door_opening_sound

@export var is_open: bool = false

# Signale für die Hauptszene
signal door_opened
signal door_closed

func _ready() -> void:
	add_to_group("elevator_doors")
	# Signal der AnimatedSprite2D verbinden
	animation_finished.connect(_on_animation_finished)

# Öffnet die Tür vorwärts
func open_doors() -> void:
	if is_open: return
	if door_sound: door_sound.play()
	play("default") # Vorwärts abspielen zum Öffnen

# Schließt die Tür rückwärts
func close_doors() -> void:
	if not is_open: return
	if door_sound: door_sound.play()
	play_backwards("default") # Rückwärts abspielen zum Schließen

func _on_animation_finished() -> void:
	# Da play_backwards genutzt wird, prüfen wir die Abspielrichtung über frame
	if frame > 0:
		is_open = true
		door_opened.emit()
	else:
		is_open = false
		door_closed.emit()

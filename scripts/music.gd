class_name Music extends Node

enum FADE {IN, OUT, NONE}

static var mode: FADE = FADE.NONE; ## If the music is fading in, out, or neither

const FADE_DURATION: float = 2.0 ## Duration of fade effect, in seconds

static var fade_timer: float = 0.0 ## Timer for the fade effect

static var vol_multiplier_nofade: float ## Multiplier for the volume, before taking fade in/out volumes into account

static var singleton: Music

static var audio_player: AudioStreamPlayer

func _ready() -> void:
	if is_instance_valid(singleton):
		queue_free()
	else:
		singleton = self
		audio_player = $AudioStreamPlayer

func _process(delta: float) -> void:
	match mode:
		FADE.IN:
			fade_timer -= delta
			if fade_timer <= 0.0:
				fade_timer = 0.0
				audio_player.volume_linear = vol_multiplier_nofade
				mode = FADE.NONE
			else:
				audio_player.volume_linear = vol_multiplier_nofade * (1.0 - fade_timer / FADE_DURATION)
		FADE.OUT:
			fade_timer -= delta
			if fade_timer <= 0.0:
				fade_timer = 0.0
				audio_player.stop()
				mode = FADE.NONE
			else:
				audio_player.volume_linear = vol_multiplier_nofade * (fade_timer / FADE_DURATION)
		FADE.NONE:
			return



## Begins playing music in the menu
static func begin_menu_playback() -> void:
	var start_pos: float = randf() * 216.5
	audio_player.play(start_pos)
	vol_multiplier_nofade = 0.25
	audio_player.volume_linear = 0.25


## Fades out menu music and resets everything
static func stop_menu_playback() -> void:
	mode = FADE.OUT
	fade_timer = FADE_DURATION


## Begins playing music in-game
static func begin_gameplay_playback() -> void:
	audio_player.play(0.0)
	vol_multiplier_nofade = 1.0
	audio_player.volume_linear = 1.0

## Stops in-game music and resets everything
static func stop_gameplay_playback() -> void:
	mode = FADE.OUT
	fade_timer = FADE_DURATION

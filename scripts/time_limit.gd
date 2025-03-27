class_name TimeManager extends Node3D
## A class for processing the time limit

@onready var sun: DirectionalLight3D = $Sun
@onready var environ: Environment = $WorldEnvironment.environment

const TIME_LIMIT: int = 15 ## How long a game lasts, in seconds

const START_VISUAL_TIME: float =  6.0 ## The time (military time) at the start of the game
const   END_VISUAL_TIME: float = 24.0 ## The time (military time) at the start of the game

static var time_scale: float = (END_VISUAL_TIME - START_VISUAL_TIME) / float(TIME_LIMIT)

var time: float = 0.0 ## The time in seconds since the game started
var visual_time: float: ## The visual (military) time
	get: return time * time_scale + START_VISUAL_TIME
	set(x): time = (x - START_VISUAL_TIME) / time_scale

## Rotates the TimeManager so the sun moves across the sky
func get_rotation_from_time() -> void:
	global_rotation.z = fmod(-PI / 12.0 * (visual_time - 12.0), TAU)


## Function that interpolates between a few values according to time
func cyclical_lerp(midnight: float, dawn: float, noon: float) -> float:
	var broad_sine: float = pow(sin(TAU / 48.0 * visual_time), 2.0) * (noon - midnight) + midnight
	var  fine_sine: float = pow(sin(TAU / 24.0 * visual_time), 2.0) * (dawn - 0.5 * (noon + midnight))
	return broad_sine + fine_sine
	

## Sets the ambient light to be the correct color
func process_ambient_light() -> void:
	const color_day = Color(0.6, 0.6, 0.6)
	const color_dusk = Color(0.3, 0.3, 0.3)
	const color_night = Color(0.1, 0.1, 0.1)
	print(environ.ambient_light_color)
	environ.ambient_light_color.r = cyclical_lerp(color_night.r, color_dusk.r, color_day.r)
	environ.ambient_light_color.g = cyclical_lerp(color_night.g, color_dusk.g, color_day.g)
	environ.ambient_light_color.b = cyclical_lerp(color_night.b, color_dusk.b, color_day.b)

## Sets the sunlight to be the correct color
func process_sunlight() -> void:
	const color_day = Color(1.0, 1.0, 0.6)
	const color_dusk = Color(0.8, 0.4, 0.2)
	const color_night = Color(0.1, 0.1, 0.1)
	print(environ.ambient_light_color)
	sun.light_color.r = cyclical_lerp(color_night.r, color_dusk.r, color_day.r)
	sun.light_color.g = cyclical_lerp(color_night.g, color_dusk.g, color_day.g)
	sun.light_color.b = cyclical_lerp(color_night.b, color_dusk.b, color_day.b)


func _ready() -> void:
	get_rotation_from_time()

func _process(delta: float) -> void:
	time += delta
	get_rotation_from_time()
	process_ambient_light()
	process_sunlight()

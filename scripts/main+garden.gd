extends Node

@onready var garden = $Garden

@export var initial_music: AudioStream
var current_music: AudioStream

func _ready():
	if initial_music:
		play_music(initial_music)

func play_music(stream: AudioStream):
	if garden.stream == stream:
		return 

	garden.stop()
	garden.stream = stream
	garden.play()
	current_music = stream

func stop_music():
	garden.stop()
	current_music = null

extends Node

@onready var fps_text : RichTextLabel = $FPSText

func _process(_delta):
	fps_text.text = str(Engine.get_frames_per_second())

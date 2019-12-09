tool
extends PanelContainer

func _ready():
	pass

func set_label(text):
	$"Panel/Body/Label".set_text(text)
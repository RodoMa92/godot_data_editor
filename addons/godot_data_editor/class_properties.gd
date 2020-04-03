tool
extends Panel

var property_item_class = preload("property_item.tscn")

onready var class_properties_box = 			$"Body/Scroll/ClassProperties"
onready var no_class_properties_label = 	$"Body/Scroll/ClassProperties/NoClassPropertiesLabel"

var config_prev_size_x = 0
var config_prev_size_y = 0

var item = null

signal on_item_changed(item)

func _ready():
	var config = ConfigFile.new()
	config.load("res://addons/godot_data_editor/plugin.cfg")
	self.config_prev_size_x = int(config.get_value("custom", "prev_size_x"))
	self.config_prev_size_y = int(config.get_value("custom", "prev_size_y"))

func build_properties(item):
	self.item = item
	for node in class_properties_box.get_children():
		if node.has_meta("property"):
			class_properties_box.remove_child(node)
	var number_of_properties = 0
	for property in item.get_property_list():
		if property["usage"] == (PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR + PROPERTY_USAGE_NETWORK):
			no_class_properties_label.hide()
			number_of_properties += 1
			var property_item = property_item_class.instance()
			var property_name = property["name"]
			var value = item.get(property_name)
			property_item.initialize(property_name, property["type"], value, property["hint"], property["hint_string"], false, self.config_prev_size_x, self.config_prev_size_y)
			property_item.connect("property_item_load_button_down", self, "_property_item_requests_file_dialog", [])
			var changed_values = []
			property_item.connect("on_property_value_changed", self, "item_changed", changed_values)
			property_item.set_meta("property", true)
			class_properties_box.add_child(property_item)
	pass
	if number_of_properties == 0:
		no_class_properties_label.show()

func item_changed(property, value):
	if item:
		item.set(property, value)
		emit_signal("on_item_changed", item)

func _on_OptionsDialog_preview_size_changed(size_x, size_y):
	self.config_prev_size_x = size_x
	self.config_prev_size_y = size_y
	for node in class_properties_box.get_children():
		if node.has_meta("property"):
			node.update_preview_sizes(size_x, size_y)

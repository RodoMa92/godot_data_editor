tool
extends AcceptDialog

var config = null

onready var serializer_label = $"Panel/GridContainer/SerializerLabel"
onready var serializer_option = $"Panel/GridContainer/SerializerOption"
onready var extension_label = $"Panel/GridContainer/ExtensionLabel"
onready var extension_line_edit = $"Panel/GridContainer/ExtensionLineEdit"
onready var encrypt_label = $"Panel/GridContainer/EncryptLabel"
onready var encrypt_check_box = $"Panel/GridContainer/EncryptCheckBox"
onready var password_label = $"Panel/GridContainer/PasswordLabel"
onready var password_line_edit = $"Panel/GridContainer/PasswordLineEdit"
onready var output_directory_label = $"Panel/GridContainer/OutputDirectoryLabel"
onready var output_directory_line_edit = $"Panel/GridContainer/OutputDirectoryHBox/OutputDirectoryLineEdit"
onready var class_directory_label = $"Panel/GridContainer/OutputDirectoryLabel"
onready var class_directory_line_edit = $"Panel/GridContainer/ClassDirectoryHBox/ClassDirectoryLineEdit"
onready var sanitize_ids_label = $"Panel/GridContainer/SanitizeIdsLabel"
onready var sanitize_ids_check_box = $"Panel/GridContainer/SanitizeIdsCheckBox"
onready var file_manager_label = $"Panel/GridContainer/FileManagerLabel"
onready var file_manager_edit = $"Panel/GridContainer/FileManagerEdit"
onready var max_prev_size_label = $"Panel/GridContainer/MaxPrevSizeLabel"
onready var prev_size_x_edit = $"Panel/GridContainer/SizeVBox/x"
onready var prev_size_y_edit = $"Panel/GridContainer/SizeVBox/y"

onready var warn_dialog = $"WarnDialog"

var extension = ""
var serializer = ""
var encrypt = false
var password = ""
var class_directory = ""
var output_directory = ""
var file_manager = ""
var prev_size_x = ""
var prev_size_y = ""
var sanitize_ids = true

signal extension_changed(new_extension, serializer)
signal encryption_changed(is_encrypted, password)
signal file_editor_changed
signal preview_size_changed(size_x, size_y)

func _ready():
	self.set_title(tr("Options"))
	self.add_cancel(tr("Cancel"))							# TODO: Does this keep on adding cancels?
	serializer_label.set_text(tr("Serializer"))
	extension_label.set_text(tr("File Extension"))
	encrypt_label.set_text(tr("Encrypt Files"))
	class_directory_label.set_text(tr("Class Directory"))
	output_directory_label.set_text(tr("Output Directory"))
	sanitize_ids_label.set_text(tr("Sanitize IDs"))
	config = ConfigFile.new()
	config.load("res://addons/godot_data_editor/plugin.cfg")
	serializer = config.get_value("custom", "serializer")
	extension = config.get_value("custom", "extension")
	class_directory = config.get_value("custom", "class_directory")
	sanitize_ids = config.get_value("custom", "sanitize_ids")
	encrypt = config.get_value("custom", "encrypt")
	password = config.get_value("custom", "password")
	output_directory = config.get_value("custom", "output_directory")
	file_manager = config.get_value("custom", "file_manager")
	prev_size_x = config.get_value("custom", "prev_size_x", "64")
	prev_size_y = config.get_value("custom", "prev_size_y", "64")
	serializer_option.clear()
	serializer_option.add_item("json", 0)
	serializer_option.add_item("binary", 1)
	if serializer == "json":
		serializer_option.select(0)
	elif serializer == "binary":
		serializer_option.select(1)
	else:
		serializer_option.select(0)
		serializer = "json"
	extension_line_edit.set_text(extension)
	if serializer == "binary":
		encrypt_check_box.set_disabled(false)
		password_line_edit.set_editable(true)
	else:
		encrypt = false
		password = ""
		encrypt_check_box.set_disabled(true)
		password_line_edit.set_editable(false)
	encrypt_check_box.set_pressed(encrypt)
	encrypt_check_box.set_text(str(encrypt))
	password_line_edit.set_text(str(password))
	class_directory_line_edit.set_text(str(class_directory))
	output_directory_line_edit.set_text(str(output_directory))
	sanitize_ids_check_box.set_pressed(sanitize_ids)
	sanitize_ids_check_box.set_text(str(sanitize_ids))
	file_manager_edit.set_text(str(file_manager))
	prev_size_x_edit.set_text(str(prev_size_x))
	prev_size_y_edit.set_text(str(prev_size_y))

func _on_SerializerOption_item_selected(index):
	if index == 0:
		extension_line_edit.set_text("json")
		encrypt = false
		password = ""
		encrypt_check_box.set_disabled(true)
		password_line_edit.set_editable(false)
	if index == 1:
		extension_line_edit.set_text("gob")
		encrypt_check_box.set_disabled(false)
		password_line_edit.set_editable(true)

func _on_Options_confirmed():
	extract_values()
	extension = extension.strip_edges()
	if extension.begins_with("."):
		extension = extension.replace(".", "")
	# TODO: Validate
	var error_message = ""
	if self.extension == "":
		error_message = tr("Please choose a valid file extension, e.g. 'gob' or 'json'.")
	if self.class_directory == "" or not self.class_directory.begins_with("res://"):
		error_message = tr("The class directory must be a resource path, e.g. 'res://classes'.")
	if self.output_directory == "" or not self.output_directory.begins_with("res://"):
		error_message = tr("The output directory must be a resource path, e.g. 'res://data'.")
	var extension_changed = false
	var encryption_changed = false
	var file_manager_changed = false
	if extension != config.get_value("custom", "extension") or serializer != config.get_value("custom", "serializer"):
		extension_changed = true
	if encrypt != config.get_value("custom", "encrypt") or password != config.get_value("custom", "password"):
		encryption_changed = true
	if file_manager != config.get_value("custom", "file_manager"):
		file_manager_changed = true
	if int(self.prev_size_x_edit.get_text()) < 0 or int(self.prev_size_y_edit.get_text()) < 0:
		error_message = tr("Please insert a positive integer as preview sizes for the popup preview.")
	var cur_val_x = int(self.prev_size_x_edit.get_text())
	var cur_val_y = int(self.prev_size_y_edit.get_text())
	if int(config.get_value("custom", "prev_size_x")) != cur_val_x or int(config.get_value("custom", "prev_size_y")) != cur_val_y:
		emit_signal("preview_size_changed", int(self.prev_size_x_edit.get_text()), int(self.prev_size_y_edit.get_text()))
	if error_message == "":
		config.set_value("custom", "extension", extension)
		config.set_value("custom", "serializer", serializer)
		config.set_value("custom", "encrypt", encrypt)
		config.set_value("custom", "password", password)
		config.set_value("custom", "class_directory", class_directory)
		config.set_value("custom", "output_directory", output_directory)
		config.set_value("custom", "sanitize_ids", sanitize_ids)
		config.set_value("custom", "file_manager", file_manager)
		config.set_value("custom", "prev_size_x", String(int(prev_size_x)))
		config.set_value("custom", "prev_size_y", String(int(prev_size_y)))
		# Reupdating the text fields, otherwise they will still show the decimal, 
		# even if it was removed
		prev_size_x_edit.set_text(String(int(prev_size_x)))
		prev_size_y_edit.set_text(String(int(prev_size_y)))
		config.save("res://addons/godot_data_editor/plugin.cfg")
		extract_values()
		hide()
	else:
		warn_dialog.set_text(error_message)
		warn_dialog.popup_centered()
	if extension_changed:
		emit_signal("extension_changed", extension, serializer)
	if encryption_changed:
		emit_signal("encryption_changed", encrypt, password)
	if file_manager_changed:
		emit_signal("file_editor_changed")
# TODO: Add a tip to NOT FORGET THE PASSWORD

func extract_values():
	serializer = serializer_option.get_item_text(serializer_option.get_selected())
	extension = extension_line_edit.get_text()
	encrypt = encrypt_check_box.is_pressed()
	password = password_line_edit.get_text()
	output_directory = output_directory_line_edit.get_text()
	sanitize_ids = sanitize_ids_check_box.is_pressed()
	file_manager = file_manager_edit.get_text()
	prev_size_x = prev_size_x_edit.get_text()
	prev_size_y = prev_size_y_edit.get_text()

func _on_ClassDirectoryButton_button_down():
	var dialog = EditorFileDialog.new()
	dialog.set_mode(EditorFileDialog.MODE_OPEN_DIR)
	dialog.connect("dir_selected", self, "set_class_directory", [])
	if not self.find_node("EditorFileDialog"):
		add_child(dialog)
	else:
		get_node("EditorFileDialog").popup_centered()
	dialog.popup_centered_ratio()

func _on_OutputDirectoryButton_button_down():
	var dialog = EditorFileDialog.new()
	dialog.set_mode(EditorFileDialog.MODE_OPEN_DIR)
	dialog.connect("dir_selected", self, "set_output_directory", [])
	if not self.find_node("EditorFileDialog"):
		add_child(dialog)
	else:
		get_node("EditorFileDialog").popup_centered()
	dialog.popup_centered_ratio()

func set_class_directory(selected_directory):
	class_directory = selected_directory
	class_directory_line_edit.set_text(selected_directory)

func set_output_directory(selected_directory):
	output_directory = selected_directory
	output_directory_line_edit.set_text(selected_directory)

func _on_EncryptCheckBox_button_down():
	encrypt_check_box.set_text(str(!encrypt_check_box.is_pressed()))

func _on_SanitizeIdsCheckBox_button_down():
	sanitize_ids_check_box.set_text(str(!sanitize_ids_check_box.is_pressed()))

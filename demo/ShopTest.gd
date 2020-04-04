extends Node2D

onready var buttons_array = $ShopButtons
onready var shop_dialog = $ShopDialog
onready var run_test = $Label


func _ready():
	var shop_types = ["Armor Shop", "Weapon Shop", "Inn", "Travelling Salesman"]
	run_test.visible = false
	for shop_type in shop_types:
		var button = Button.new()
		button.set_text(shop_type)
		button.connect("pressed", self, "_on_ShopButtons_button_selected", [button])
		buttons_array.add_child(button)

func _on_ShopButtons_button_selected(button):
	var text = button.get_text()
	var all_merchants = data.get_items("merchant")
	for merchant in all_merchants.values():
		if merchant.merchant_name == text:
			shop_dialog.create_shop(merchant)
			shop_dialog.popup_centered()

extends Control
## 主菜单场景

func _ready() -> void:
	print("主菜单已加载")

func _on_new_game_pressed() -> void:
	print("新游戏开始")
	GameManager.start_new_game()

func _on_load_game_pressed() -> void:
	print("加载游戏")

func _on_settings_pressed() -> void:
	print("打开设置")

func _on_quit_pressed() -> void:
	GameManager.quit_game()

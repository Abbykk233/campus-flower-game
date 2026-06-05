## 全局游戏管理器 - 协调所有系统
class_name GameManager
extends Node

# 游戏状态枚举
enum GameState {
	MENU,           # 主菜单
	GAMEPLAY,       # 游戏中
	BATTLE,         # 战斗中
	DIALOGUE,       # 对话中
	MEMORY_SCENE,   # 回忆场景
	PAUSE,          # 暂停
	LOADING,        # 加载中
}

# 信号
signal game_state_changed(new_state: GameState)
signal location_changed(location_id: String)

# 当前游戏状态
var current_state: GameState = GameState.MENU
var current_location: String = ""

func _ready() -> void:
	print("=== ", Constants.GAME_TITLE, " v", Constants.GAME_VERSION, " ===")

func _process(delta: float) -> void:
	# 处理全局暂停快捷键
	if Input.is_action_just_pressed("ui_cancel"):
		if current_state != GameState.PAUSE and current_state != GameState.MENU:
			toggle_pause()

## 改变游戏状态
func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	game_state_changed.emit(new_state)

## 切换暂停状态
func toggle_pause() -> void:
	if current_state == GameState.PAUSE:
		get_tree().paused = false
		change_state(GameState.GAMEPLAY)
	else:
		get_tree().paused = true
		change_state(GameState.PAUSE)

## 改变位置
func change_location(location_id: String) -> void:
	current_location = location_id
	location_changed.emit(location_id)

## 新游戏开始
func start_new_game() -> void:
	PlayerData.reset()
	AffectionSystem.reset()
	StoryManager.reset()
	
	# 播放开场回忆
	StoryManager.play_opening_memory()
	change_state(GameState.MEMORY_SCENE)

func finish_opening_memory() -> void:
	"""
	完成开场回忆后进入游戏
	"""
	StoryManager.finish_opening_memory()
	change_state(GameState.GAMEPLAY)
	change_location("shop")  # 进入豆花屋

## 加载游戏
func load_game(save_slot: int) -> void:
	change_state(GameState.LOADING)
	var success = await SaveSystem.load_game(save_slot)
	if success:
		change_state(GameState.GAMEPLAY)
		change_location("shop")
	else:
		push_error("Failed to load game from slot: ", save_slot)

## 保存游戏
func save_game(save_slot: int) -> bool:
	return await SaveSystem.save_game(save_slot)

## 回到主菜单
func back_to_menu() -> void:
	change_state(GameState.MENU)
	get_tree().reload_current_scene()

## 退出游戏
func quit_game() -> void:
	get_tree().quit()

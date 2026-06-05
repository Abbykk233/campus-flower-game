## 保存系统 - 10个存档槽
class_name SaveSystem
extends Node

const SAVE_DIR = "user://saves/"
const SAVE_FILE_PREFIX = "save_"
const SAVE_FILE_SUFFIX = ".json"

func _ready() -> void:
	# 确保保存目录存在
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_absolute(SAVE_DIR)

func save_game(slot: int) -> bool:
	"""
	保存游戏到指定槽位
	"""
	if slot < 0 or slot >= Constants.SAVE_SLOTS:
		push_error("Invalid save slot: ", slot)
		return false
	
	var save_data = {
		"version": Constants.GAME_VERSION,
		"timestamp": Time.get_ticks_msec(),
		"date": TimeManager.get_date_string(),
		"time": TimeManager.get_time_string(),
		"player": {
			"level": PlayerData.player_level,
			"exp": PlayerData.player_exp,
			"hp": PlayerData.hp,
			"mp": PlayerData.mp,
			"gold": PlayerData.player_gold,
		},
		"affections": AffectionSystem.affections.duplicate(),
		"story_flags": StoryManager.story_flags.duplicate(),
	}
	
	var json_string = JSON.stringify(save_data)
	var file_path = SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_SUFFIX
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file: ", file_path)
		return false
	
	file.store_string(json_string)
	print("Game saved to slot ", slot)
	return true

func load_game(slot: int) -> bool:
	"""
	从指定槽位加载游戏
	"""
	if slot < 0 or slot >= Constants.SAVE_SLOTS:
		push_error("Invalid save slot: ", slot)
		return false
	
	var file_path = SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_SUFFIX
	
	if not FileAccess.file_exists(file_path):
		print("Save file does not exist: ", file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file: ", file_path)
		return false
	
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse save file")
		return false
	
	var save_data = json.data
	
	# 恢复玩家数据
	PlayerData.player_level = save_data["player"]["level"]
	PlayerData.player_exp = save_data["player"]["exp"]
	PlayerData.hp = save_data["player"]["hp"]
	PlayerData.mp = save_data["player"]["mp"]
	PlayerData.player_gold = save_data["player"]["gold"]
	
	# 恢复好感度
	AffectionSystem.affections = save_data["affections"].duplicate()
	
	# 恢复故事标志
	StoryManager.story_flags = save_data["story_flags"].duplicate()
	
	print("Game loaded from slot ", slot)
	return true

func delete_save(slot: int) -> bool:
	"""
	删除指定槽位的存档
	"""
	var file_path = SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_SUFFIX
	
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("Save file deleted: ", file_path)
			return true
	
	return false

func get_save_info(slot: int) -> Dictionary:
	"""
	获取存档信息（用于加载菜单显示）
	"""
	var file_path = SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_SUFFIX
	
	if not FileAccess.file_exists(file_path):
		return {"exists": false}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	json.parse(json_string)
	var save_data = json.data
	
	return {
		"exists": true,
		"level": save_data["player"]["level"],
		"date": save_data["date"],
		"time": save_data["time"],
		"timestamp": save_data["timestamp"],
	}

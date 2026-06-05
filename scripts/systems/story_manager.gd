## 故事管理系统 - 分支故事、对话、标志
class_name StoryManager
extends Node

# 故事标志（全局）
var story_flags: Dictionary = {}

# 开场回忆相关
var opening_memory_played: bool = false
var fang_story_data: Dictionary = {}

# 分支故事进度
var character_stories: Dictionary = {}  # {character_id: story_progress}

# 信号
signal story_flag_set(flag_name: String, value: bool)
signal memory_scene_started()
signal memory_scene_ended()

func _ready() -> void:
	_load_story_data()

func _load_story_data() -> void:
	"""
	从JSON加载故事数据
	"""
	fang_story_data = {
		"character_id": Constants.CHARACTER_FANG,
		"name": "芳",
		"type": "memory",  # 纯回忆，不可攻略
		"theme": "开场回忆",
		"intro_text": "高中时代，那是最美好的时光...",
		"painful_text": "因为异地恋，我们还是分开了。",
		"memory_description": "在豆花屋里，主角回想起与芳的高中故事。青涩的高中恋爱，却因为异地最终不得不分开。这段回忆成为了主角追求其他角色的经验与教训。",
	}

## 重置故事系统
func reset() -> void:
	story_flags.clear()
	opening_memory_played = false
	character_stories.clear()

func set_flag(flag_name: String, value: bool = true) -> void:
	story_flags[flag_name] = value
	story_flag_set.emit(flag_name, value)

func get_flag(flag_name: String) -> bool:
	return story_flags.get(flag_name, false)

func has_flag(flag_name: String) -> bool:
	return flag_name in story_flags

## 播放开场回忆
func play_opening_memory() -> void:
	if opening_memory_played:
		return
	
	opening_memory_played = true
	memory_scene_started.emit()
	# 实际的场景加载由主管理器处理

func finish_opening_memory() -> void:
	memory_scene_ended.emit()

func get_fang_memory_data() -> Dictionary:
	return fang_story_data.duplicate()

## 设置角色故事进度
func set_character_story_progress(character_id: String, progress: int) -> void:
	character_stories[character_id] = progress

func get_character_story_progress(character_id: String) -> int:
	return character_stories.get(character_id, 0)

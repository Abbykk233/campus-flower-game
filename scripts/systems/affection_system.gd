## 好感度系统 - 管理5个可攻略角色 + 白月光芳
class_name AffectionSystem
extends Node

# 角色好感度数据
var affections: Dictionary = {}  # {character_id: affection_value}
var character_encountered: Dictionary = {}  # {character_id: bool} 是否已邂逅
var romance_flags: Dictionary = {}  # {character_id: flag} 故事进度标志
var daily_interactions: Dictionary = {}  # {character_id: int} 每日互动次数

# 白月光芳路线追踪
var fang_memory_triggered: bool = false
var fang_hidden_route_progress: float = 0.0  # 隐藏路线进度（0.0-1.0）
var is_pursuing_fang_route: bool = false  # 是否在追求芳的隐藏路线

# 信号
signal affection_changed(character_id: String, new_value: float, old_value: float)
signal affection_level_changed(character_id: String, new_level: int)
signal character_encountered(character_id: String)
signal fang_route_triggered()

func _ready() -> void:
	_initialize_characters()

## 初始化所有角色
func _initialize_characters() -> void:
	for char_id in Constants.ALL_ROMANCE_CHARACTERS:
		affections[char_id] = 0.0
		character_encountered[char_id] = false
		romance_flags[char_id] = {}
		daily_interactions[char_id] = 0
	
	# 芳（白月光）
	affections[Constants.CHARACTER_FANG] = 0.0
	character_encountered[Constants.CHARACTER_FANG] = true  # 芳在开场回忆中已邂逅

## 重置系统
func reset() -> void:
	for char_id in affections.keys():
		affections[char_id] = 0.0
		character_encountered[char_id] = false
		romance_flags[char_id] = {}
	daily_interactions.clear()
	fang_memory_triggered = false
	fang_hidden_route_progress = 0.0
	is_pursuing_fang_route = false

## 重置每日互动计数
func reset_daily_interactions() -> void:
	for char_id in daily_interactions.keys():
		daily_interactions[char_id] = 0

## 增加好感度
func add_affection(character_id: String, amount: float) -> void:
	if character_id not in affections:
		return
	
	var old_value = affections[character_id]
	affections[character_id] = clamp(affections[character_id] + amount, 0.0, Constants.MAX_AFFECTION)
	var new_value = affections[character_id]
	
	# 第一次邂逅
	if not character_encountered[character_id] and new_value > 0:
		character_encountered[character_id] = true
		character_encountered.emit(character_id)
	
	affection_changed.emit(character_id, new_value, old_value)
	
	# 检查好感度等级变化
	var old_level = get_affection_level(old_value)
	var new_level = get_affection_level(new_value)
	if new_level != old_level:
		affection_level_changed.emit(character_id, new_level)
		print("%s的好感度达到 %s" % [character_id, _get_level_name(new_level)])

## 扣除好感度
func remove_affection(character_id: String, amount: float) -> void:
	add_affection(character_id, -amount)

## 获取好感度值
func get_affection(character_id: String) -> float:
	return affections.get(character_id, 0.0)

## 获取好感度等级（0-4）
func get_affection_level(value: float = -1.0) -> int:
	if value == -1.0:
		return -1  # 无效值
	
	if value >= Constants.AFFECTION_LEVEL_DEEP_LOVE:
		return 4  # 深爱
	elif value >= Constants.AFFECTION_LEVEL_LOVE:
		return 3  # 恋爱
	elif value >= Constants.AFFECTION_LEVEL_CLOSE:
		return 2  # 亲近
	elif value >= Constants.AFFECTION_LEVEL_FRIEND:
		return 1  # 好友
	else:
		return 0  # 陌生人

## 获取角色的好感度加成（0.0-1.0）
func get_affection_bonus(character_id: String) -> float:
	var level = get_affection_level(get_affection(character_id))
	return float(level) / 4.0

## 对话选择影响好感度
func apply_dialogue_choice(character_id: String, choice_data: Dictionary) -> void:
	if "affection_change" in choice_data:
		add_affection(character_id, choice_data["affection_change"])

## 战斗中增加好感度（基于配合/胜利）
func add_battle_affection(character_id: String, battle_quality: float) -> void:
	# battle_quality: 0.5 (战斗失败), 1.0 (正常), 1.5 (完美配合)
	var amount = 5.0 * battle_quality
	add_affection(character_id, amount)

## 设置故事标志
func set_flag(character_id: String, flag_name: String, value: bool = true) -> void:
	if character_id not in romance_flags:
		romance_flags[character_id] = {}
	romance_flags[character_id][flag_name] = value

## 获取故事标志
func get_flag(character_id: String, flag_name: String) -> bool:
	return romance_flags.get(character_id, {}).get(flag_name, false)

## 检查是否可以触发隐藏路线
func check_fang_hidden_route() -> bool:
	# 隐藏条件：所有5个女主好感度都达到深爱
	var all_deep_love = true
	for char_id in Constants.ALL_ROMANCE_CHARACTERS:
		if get_affection_level(get_affection(char_id)) < 4:
			all_deep_love = false
			break
	
	if all_deep_love and not is_pursuing_fang_route:
		is_pursuing_fang_route = true
		fang_route_triggered.emit()
		return true
	
	return false

## 推进芳的隐藏路线进度
func progress_fang_route(amount: float) -> void:
	fang_hidden_route_progress = clamp(fang_hidden_route_progress + amount, 0.0, 1.0)
	if fang_hidden_route_progress >= 1.0:
		print("芳的隐藏路线已完成！")

# ============ 私有方法 ============

func _get_level_name(level: int) -> String:
	match level:
		0:
			return "陌生人"
		1:
			return "好友"
		2:
			return "亲近"
		3:
			return "恋爱"
		4:
			return "深爱"
		_:
			return "未知"

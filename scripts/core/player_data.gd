## 玩家数据管理系统
class_name PlayerData
extends Node

# 基础属性
var player_name: String = "主角"
var player_level: int = 1
var player_exp: float = 0.0
var player_max_exp: float = 100.0
var player_gold: int = 0

# 战斗属性
var hp: float = 100.0
var max_hp: float = 100.0
var mp: float = 50.0
var max_mp: float = 50.0
var attack: float = 10.0
var defense: float = 5.0
var speed: float = 10.0
var crit_rate: float = 0.1
var crit_damage: float = 1.5

# 当前配备的技能（4个技能槽）
var equipped_skills: Array[String] = ["attack", "", "", ""]  # 技能ID
var skills: Dictionary = {}  # 解锁的所有技能 {skill_id: skill_data}
var skill_levels: Dictionary = {}  # 技能等级 {skill_id: level}

# 当前约会对象
var current_companion: String = ""  # 角色ID，用于战斗中的搭档

# 物品/豆花商品库存
var inventory: Dictionary = {}  # {item_id: count}

# 信号
signal level_up(new_level: int)
signal exp_gained(exp_amount: float)
signal skill_unlocked(skill_id: String)
signal skill_equipped(slot: int, skill_id: String)
signal companion_changed(character_id: String)

func _ready() -> void:
	_initialize_base_skills()

## 重置玩家数据
func reset() -> void:
	player_level = 1
	player_exp = 0.0
	player_max_exp = 100.0
	player_gold = 0
	hp = max_hp
	mp = max_mp
	equipped_skills = ["attack", "", "", ""]
	current_companion = ""
	inventory.clear()
	_initialize_base_skills()

## 增加经验
func add_exp(amount: float) -> void:
	player_exp += amount
	exp_gained.emit(amount)
	
	# 检查升级
	while player_exp >= player_max_exp:
		player_exp -= player_max_exp
		level_up_player()

## 升级
func level_up_player() -> void:
	player_level += 1
	player_max_exp = int(player_max_exp * 1.1)  # 每级需要经验增加10%
	
	# 属性提升
	max_hp += 10
	hp = max_hp
	max_mp += 5
	mp = max_mp
	attack += 2
	defense += 1
	
	level_up.emit(player_level)
	print("升级到 Lv.%d" % player_level)

## 增加金钱
func add_gold(amount: int) -> void:
	player_gold += amount

## 扣除金钱
func remove_gold(amount: int) -> bool:
	if player_gold >= amount:
		player_gold -= amount
		return true
	return false

## 设置当前同伴
func set_companion(character_id: String) -> void:
	current_companion = character_id
	companion_changed.emit(character_id)

## 装备技能
func equip_skill(slot: int, skill_id: String) -> bool:
	if slot < 0 or slot >= 4:
		push_error("Invalid skill slot: ", slot)
		return false
	
	if skill_id == "" or skill_id in skills:
		equipped_skills[slot] = skill_id
		skill_equipped.emit(slot, skill_id)
		return true
	
	return false

## 解锁技能
func unlock_skill(skill_id: String, skill_data: Dictionary) -> void:
	if skill_id not in skills:
		skills[skill_id] = skill_data
		skill_levels[skill_id] = 1
		skill_unlocked.emit(skill_id)
		print("解锁技能: ", skill_id)

## 提升技能等级
func upgrade_skill(skill_id: String) -> bool:
	if skill_id not in skill_levels:
		return false
	
	skill_levels[skill_id] += 1
	return true

## 获取战斗属性（含好感度加成）
func get_battle_stats(affection_bonus: float = 0.0) -> Dictionary:
	# affection_bonus: 0.0 - 1.0，根据好感度添加的加成
	return {
		"hp": max_hp,
		"mp": max_mp,
		"attack": attack * (1.0 + affection_bonus * 0.2),
		"defense": defense * (1.0 + affection_bonus * 0.1),
		"speed": speed,
		"crit_rate": crit_rate,
		"crit_damage": crit_damage,
	}

## 获取已装备的技能
func get_equipped_skills() -> Array[String]:
	return equipped_skills

## 获取技能详情
func get_skill_data(skill_id: String) -> Dictionary:
	if skill_id in skills:
		return skills[skill_id].duplicate()
	return {}

# ============ 私有方法 ============

func _initialize_base_skills() -> void:
	# 初始化基础技能
	var attack_skill = {
		"id": "attack",
		"name": "普通攻击",
		"type": "physical",
		"cost": 0,  # 无消耗
		"cooldown": 0.5,
		"damage_multiplier": 1.0,
		"description": "基础攻击",
	}
	skills["attack"] = attack_skill
	skill_levels["attack"] = 1

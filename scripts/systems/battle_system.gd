## 战斗系统 - 纯实时战斗
class_name BattleSystem
extends Node

enum BattleState {
	IDLE,
	BATTLE,
	PAUSED,
	VICTORY,
	DEFEAT,
}

var current_state: BattleState = BattleState.IDLE
var is_in_battle: bool = false

# 战斗参与者
var player_unit: BattleUnit
var companion_unit: BattleUnit
var enemy_unit: BattleUnit

# 战斗统计
var battle_duration: float = 0.0
var damage_dealt: int = 0
var damage_taken: int = 0

# 信号
signal battle_started()
signal battle_ended(victory: bool)
signal unit_died(unit_type: String)  # "player", "companion", "enemy"
signal turn_changed()

func _ready() -> void:
	pass

func start_battle(enemy_data: Dictionary, companion_id: String = "") -> void:
	"""
	开始战斗
	Args:
		enemy_data: 敌人数据
		companion_id: 同伴角色ID（可选）
	"""
	current_state = BattleState.BATTLE
	is_in_battle = true
	battle_duration = 0.0
	damage_dealt = 0
	damage_taken = 0
	
	# 创建战斗单位
	player_unit = _create_player_unit()
	if companion_id:
		companion_unit = _create_companion_unit(companion_id)
	enemy_unit = _create_enemy_unit(enemy_data)
	
	battle_started.emit()

func end_battle(victory: bool) -> Dictionary:
	"""
	结束战斗，返回奖励
	"""
	current_state = BattleState.IDLE if victory else BattleState.DEFEAT
	is_in_battle = false
	
	var rewards = {}
	if victory:
		# 计算奖励
		rewards["exp"] = int(enemy_unit.base_exp * (1.0 + float(damage_dealt) / enemy_unit.max_hp))
		rewards["gold"] = int(enemy_unit.drop_gold * randf_range(0.8, 1.2))
		rewards["items"] = []
	
	battle_ended.emit(victory)
	return rewards

func _create_player_unit() -> BattleUnit:
	var unit = BattleUnit.new()
	unit.unit_type = "player"
	unit.max_hp = PlayerData.max_hp
	unit.hp = PlayerData.hp
	unit.attack = PlayerData.attack
	unit.defense = PlayerData.defense
	unit.speed = PlayerData.speed
	return unit

func _create_companion_unit(character_id: String) -> BattleUnit:
	# 从角色数据加载同伴信息
	var unit = BattleUnit.new()
	unit.unit_type = "companion"
	unit.character_id = character_id
	# 加载实际的同伴数据...
	return unit

func _create_enemy_unit(enemy_data: Dictionary) -> BattleUnit:
	var unit = BattleUnit.new()
	unit.unit_type = "enemy"
	unit.max_hp = enemy_data.get("hp", 50)
	unit.hp = unit.max_hp
	unit.attack = enemy_data.get("attack", 8)
	unit.defense = enemy_data.get("defense", 3)
	unit.speed = enemy_data.get("speed", 7)
	unit.base_exp = enemy_data.get("exp", 50)
	unit.drop_gold = enemy_data.get("gold", 30)
	return unit

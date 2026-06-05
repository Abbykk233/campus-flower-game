## 战斗单位（玩家、同伴、敌人）
class_name BattleUnit
extends Node

var unit_type: String = ""  # "player", "companion", "enemy"
var character_id: String = ""

# 基础属性
var max_hp: float = 100.0
var hp: float = 100.0
var attack: float = 10.0
var defense: float = 5.0
var speed: float = 10.0

# 战斗状态
var is_alive: bool = true
var current_skill_cd: Dictionary = {}  # {skill_id: remaining_cd}
var applied_buffs: Array = []  # 当前应用的增益
var applied_debuffs: Array = []  # 当前应用的减益

# 敌人特有
var base_exp: int = 0
var drop_gold: int = 0

# 信号
signal hp_changed(new_hp: float)
signal died()

func _ready() -> void:
	pass

func take_damage(damage: float) -> void:
	# 防御减伤
	damage = max(1.0, damage - (defense * 0.1))
	hp -= damage
	hp_changed.emit(hp)
	
	if hp <= 0:
		hp = 0
		is_alive = false
		died.emit()

func heal(amount: float) -> void:
	hp = min(hp + amount, max_hp)
	hp_changed.emit(hp)

func apply_skill(skill_id: String, target: BattleUnit, damage_multiplier: float = 1.0) -> void:
	var damage = attack * damage_multiplier
	# 暴击判定
	var crit_roll = randf()
	if crit_roll < 0.1:  # 10%暴击率
		damage *= 1.5
		print("暴击！")
	
	target.take_damage(damage)

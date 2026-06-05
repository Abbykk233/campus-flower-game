## 每日循环系统 - 管理天数进行与睡眠
class_name DailyCycle
extends Node

enum Phase {
	MORNING,     # 早上 - 豆花屋营业
	AFTERNOON,   # 下午 - 探险/战斗
	EVENING,     # 晚上 - 约会
}

var current_day: int = 1
var is_sleeping: bool = false
var sleep_requested: bool = false

signal sleep_requested()
signal day_end(day: int)
signal woke_up(day: int)

func _ready() -> void:
	TimeManager.day_changed.connect(_on_day_changed)

func request_sleep() -> void:
	"""
	玩家请求睡眠
	"""
	if not is_sleeping:
		sleep_requested = true
		sleep_requested.emit()

## 执行睡眠（天数结束）
func do_sleep() -> void:
	if is_sleeping:
		return
	
	is_sleeping = true
	day_end.emit(current_day)
	
	# 增加一天
	TimeManager.add_day(1)
	current_day = TimeManager.current_day
	
	is_sleeping = false
	woke_up.emit(current_day)

## 是否可以睡眠
func can_sleep() -> bool:
	return TimeManager.is_sleep_time()

func _on_day_changed(new_day: int) -> void:
	current_day = new_day

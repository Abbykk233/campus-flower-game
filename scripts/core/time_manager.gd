## 时间管理系统 - 类似星露谷的时间系统
## 玩家可自由分配时间，时间消耗基于活动
class_name TimeManager
extends Node

# 游戏时间单位：分钟
const MINUTES_PER_HOUR = 60
const HOURS_PER_DAY = 24
const TOTAL_MINUTES_PER_DAY = MINUTES_PER_HOUR * HOURS_PER_DAY

# 游戏阶段定义
enum TimePhase {
	EARLY_MORNING = 0,    # 00:00-06:00
	MORNING = 1,          # 06:00-12:00 - 豆花屋营业
	AFTERNOON = 2,        # 12:00-18:00 - 探险/战斗
	EVENING = 3,          # 18:00-24:00 - 约会
}

# 信号
signal time_changed(hour: int, minute: int)
signal hour_changed(hour: int)
signal phase_changed(new_phase: TimePhase)
signal day_changed(new_day: int)
signal time_warning(minutes_until_sleep: int)  # 距离睡眠时间的警告

# 当前游戏时间
var current_day: int = 1
var current_month: int = 1
var current_year: int = 2024
var current_hour: int = 6  # 早上6点开始
var current_minute: int = 0

# 上一次的阶段
var last_phase: TimePhase = TimePhase.EARLY_MORNING

# 时间相关设置
@export var sleep_hour: int = 24  # 午夜（次日0点）睡眠
@export var wake_hour: int = 6    # 早上6点醒来

func _ready() -> void:
	set_process(false)  # 不在 _process 中自动推进时间

## 增加游戏时间（分钟）
func add_minutes(minutes: int) -> void:
	current_minute += minutes
	
	# 处理进位
	while current_minute >= MINUTES_PER_HOUR:
		current_minute -= MINUTES_PER_HOUR
		add_hour(1)

## 增加游戏时间（小时）
func add_hour(hours: int) -> void:
	current_hour += hours
	
	# 处理天数进位
	while current_hour >= HOURS_PER_DAY:
		current_hour -= HOURS_PER_DAY
		add_day(1)

## 增加游戏时间（天数）
func add_day(days: int) -> void:
	current_day += days
	
	# 处理月份进位（简单处理，假设每月30天）
	while current_day > 30:
		current_day -= 30
		add_month(1)
	
	day_changed.emit(current_day)
	# 重置为早上
	current_hour = wake_hour
	current_minute = 0

## 增加游戏时间（月份）
func add_month(months: int) -> void:
	current_month += months
	
	# 处理年份进位
	while current_month > 12:
		current_month -= 12
		current_year += 1

## 设置具体时间
func set_time(hour: int, minute: int = 0) -> void:
	if hour < 0 or hour >= HOURS_PER_DAY:
		push_error("Invalid hour: ", hour)
		return
	if minute < 0 or minute >= MINUTES_PER_HOUR:
		push_error("Invalid minute: ", minute)
		return
	
	current_hour = hour
	current_minute = minute
	_emit_time_signals()

## 检查是否超过睡眠时间
func is_sleep_time() -> bool:
	return current_hour >= sleep_hour

## 获取距离睡眠还有多少分钟
func get_minutes_until_sleep() -> int:
	if current_hour >= sleep_hour:
		return 0
	
	var remaining_hours = sleep_hour - current_hour
	var remaining_minutes = MINUTES_PER_HOUR - current_minute
	return remaining_hours * MINUTES_PER_HOUR + remaining_minutes

## 活动消耗时间示例
func activity_consume_time(activity_name: String) -> int:
	match activity_name:
		"talk":  # 和NPC对话
			return 15
		"shop":  # 在豆花屋卖豆花
			return 30
		"explore":  # 探险
			return 60
		"battle":  # 战斗（根据战斗长度可变）
			return 45
		"date":  # 约会
			return 120
		"sleep":  # 睡眠
			return TOTAL_MINUTES_PER_DAY - (wake_hour * MINUTES_PER_HOUR)
		_:
			return 30  # 默认30分钟

## 获取当前时间字符串
func get_time_string() -> String:
	return "%02d:%02d" % [current_hour, current_minute]

## 获取完整日期字符串
func get_date_string() -> String:
	var month_names = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
	return "%s %d日" % [month_names[current_month - 1], current_day]

## 获取当前阶段
func get_current_phase() -> TimePhase:
	if current_hour < 6:
		return TimePhase.EARLY_MORNING
	elif current_hour < 12:
		return TimePhase.MORNING
	elif current_hour < 18:
		return TimePhase.AFTERNOON
	else:
		return TimePhase.EVENING

## 获取阶段名称
func get_phase_name(phase: TimePhase) -> String:
	match phase:
		TimePhase.EARLY_MORNING:
			return "凌晨"
		TimePhase.MORNING:
			return "早上"
		TimePhase.AFTERNOON:
			return "下午"
		TimePhase.EVENING:
			return "晚上"
		_:
			return "未知"

# ============ 私有方法 ============

func _emit_time_signals() -> void:
	time_changed.emit(current_hour, current_minute)
	
	# 检查阶段是否改变
	var new_phase = get_current_phase()
	if new_phase != last_phase:
		last_phase = new_phase
		phase_changed.emit(new_phase)
	
	# 发出小时变化信号
	hour_changed.emit(current_hour)
	
	# 检查睡眠警告
	var minutes_until_sleep = get_minutes_until_sleep()
	if minutes_until_sleep <= 60 and minutes_until_sleep > 0:
		time_warning.emit(minutes_until_sleep)

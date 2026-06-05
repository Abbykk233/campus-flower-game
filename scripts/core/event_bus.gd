## 事件总线 - 全局事件通信
class_name EventBus
extends Node

# 动态信号字典
var _signals: Dictionary = {}

func _ready() -> void:
	# 预定义一些常用信号
	create_signal("game_started")
	create_signal("game_loaded")
	create_signal("game_saved")
	create_signal("dialogue_started")
	create_signal("dialogue_ended")
	create_signal("battle_triggered")
	create_signal("location_changed")

func create_signal(signal_name: String) -> void:
	if signal_name not in _signals:
		_signals[signal_name] = Signal(self, signal_name)
		add_user_signal(signal_name)

func emit(signal_name: String, args: Array = []) -> void:
	"""
	发出信号
	"""
	if signal_name not in _signals:
		create_signal(signal_name)
	
	# 使用 call_deferred 确保信号发出
	match args.size():
		0:
			emit_signal(signal_name)
		1:
			emit_signal(signal_name, args[0])
		2:
			emit_signal(signal_name, args[0], args[1])
		3:
			emit_signal(signal_name, args[0], args[1], args[2])
		_:
			push_warning("Too many arguments for signal: ", signal_name)

func connect_to(signal_name: String, callable_obj: Callable) -> void:
	"""
	连接信号
	"""
	if signal_name not in _signals:
		create_signal(signal_name)
	
	if not is_signal_connected(signal_name, callable_obj):
		connect(signal_name, callable_obj)

func disconnect_from(signal_name: String, callable_obj: Callable) -> void:
	"""
	断开信号
	"""
	if is_signal_connected(signal_name, callable_obj):
		disconnect(signal_name, callable_obj)

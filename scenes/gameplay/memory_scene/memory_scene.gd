extends Control
## 开场回忆场景 - 黑白/褪色 CG
## 主角在豆花屋回想芳的故事

var memory_data: Dictionary = {}
var current_memory_index: int = 0
var memories: Array = [
	{
		"text": "高中时代，那是最美好的时光...",
		"duration": 3.0
	},
	{
		"text": "我与芳每天一起走过校园的每个角落。",
		"duration": 3.0
	},
	{
		"text": "那时我们一起梦想着未来...",
		"duration": 3.0
	},
	{
		"text": "但是异地恋最后还是击败了我们的爱情。",
		"duration": 3.0
	},
	{
		"text": "现在，我在这间小木屋里卖豆花。",
		"duration": 3.0
	},
	{
		"text": "而芳已经成为了我心中永远的遗憾...",
		"duration": 3.0
	},
]

func _ready() -> void:
	memory_data = StoryManager.get_fang_memory_data()
	$DialogueText.text = memories[0]["text"]
	add_timer_and_show_next()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		show_next_memory()

elif event.is_action_pressed("ui_accept"):
		show_next_memory()

func show_next_memory() -> void:
	current_memory_index += 1
	if current_memory_index >= memories.size():
		# 回忆结束，进入主游戏
		GameManager.finish_opening_memory()
		get_tree().change_scene_to_file("res://scenes/gameplay/world/world.tscn")
	else:
		$DialogueText.text = memories[current_memory_index]["text"]
		add_timer_and_show_next()

func add_timer_and_show_next() -> void:
	# 自动推进到下一条
	var timer = get_tree().create_timer(memories[current_memory_index]["duration"])
	timer.timeout.connect(show_next_memory)

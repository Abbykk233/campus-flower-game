## 游戏全局常量
class_name Constants

# ============ 可攻略角色 ============
const CHARACTER_XIAOHUI = "xiaohui"      # 小蔷 - 医学生
const CHARACTER_XIAOXING = "xiaoxing"    # 小懜 - 上班店员
const CHARACTER_XIAOHUO = "xiaohuo"      # 小钬 - 网恋
const CHARACTER_RU = "ru"                 # 汝 - 隔壁店铺
const CHARACTER_YAXIAO = "yaxiao"        # 芽小 - 青梅竹马
const CHARACTER_FANG = "fang"            # 芳 - 白月光

const ALL_ROMANCE_CHARACTERS = [
	CHARACTER_XIAOHUI,
	CHARACTER_XIAOXING,
	CHARACTER_XIAOHUO,
	CHARACTER_RU,
	CHARACTER_YAXIAO,
]

# ============ 难度等级 ============
const DIFFICULTY_VERY_EASY = 1 # 汝、芽小 - 最易攻略
const DIFFICULTY_NORMAL = 2    # 小蔷 - 普通难度
const DIFFICULTY_HARD = 3      # 小钬 - 中难度
const DIFFICULTY_VERY_HARD = 4 # 小懜 - 高难度

# ============ 好感度系统 ============
const MAX_AFFECTION = 1000.0
const AFFECTION_LEVEL_STRANGER = 0
const AFFECTION_LEVEL_FRIEND = 200.0
const AFFECTION_LEVEL_CLOSE = 500.0
const AFFECTION_LEVEL_LOVE = 700.0
const AFFECTION_LEVEL_DEEP_LOVE = 900.0

# ============ 技能系统 ============
const MAX_SKILL_SLOTS = 4
const SKILL_RARITY_COMMON = 1
const SKILL_RARITY_UNCOMMON = 2
const SKILL_RARITY_RARE = 3
const SKILL_RARITY_EPIC = 4
const SKILL_RARITY_LEGENDARY = 5

# ============ 战斗系统 ============
const BATTLE_TYPE_NORMAL = "normal"
const BATTLE_TYPE_BOSS = "boss"
const BATTLE_TYPE_STORY = "story"

# ============ 存档系统 ============
const SAVE_SLOTS = 10
const SAVE_DIR = "user://saves/"

# ============ 游戏设置 ============
const GAME_VERSION = "0.1.0"
const GAME_TITLE = "豆花物语"

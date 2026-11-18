class_name UI
extends CanvasLayer

const DEATH_SCREEN_PREFAB := preload("res://scenes/ui/death_screen.tscn")
const GAME_OVER_PREFAB := preload("res://scenes/ui/game_over_screen.tscn")
const OPTIONS_SCREEN_PREFAB := preload("res://scenes/ui/options_screen.tscn")

@onready var combo_indicator : ComboIndicator = $UIContainer/ComboIndicator
@onready var enemy_avatar : TextureRect = $UIContainer/EnemyAvatar
@onready var enemy_healthbar : Healthbar = $UIContainer/EnemyHealthbar
@onready var go_indicator : ComboIndicator = $UIContainer/GoIndicator
@onready var player_healthbar : Healthbar = $UIContainer/PlayerHealthbar
@onready var score_indicator : ScoreIndicator = $UIContainer/ScoreIndicator

@export var duration_healthbar_visible : int

var death_screen: DeathScreen = null
var game_over_screen: GameOverScreen = null
var options_screen: OptionsScreen = null
var time_start_healthbar_visible := Time.get_ticks_msec()

const avatar_map : Dictionary = {
	Character.Type.GOON: preload("res://assets/art/ui/avatars/avatar-goon.png")
}

func _init() -> void:
	DamageManager.health_change.connect(on_character_health_change.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())

func _ready() -> void:
	enemy_avatar.visible = false
	enemy_healthbar.visible = false
	combo_indicator.combo_reset.connect(on_combo_reset.bind())

func _process(_delta) -> void:
	if enemy_healthbar.visible and Time.get_ticks_msec() - time_start_healthbar_visible > duration_healthbar_visible:
		enemy_avatar.visible = false
		enemy_healthbar.visible = false
		handle_input()

func handle_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if options_screen == null:
			options_screen = OPTIONS_SCREEN_PREFAB.instantiate()
			options_screen.exit.connect(unpause)
			get_tree().paused = true
		else:
			unpause()

func unpause() -> void:
	options_screen.queue_free()
	get_tree().paused = false

func on_combo_reset() -> void:
	score_indicator.add_combo(points)

func on_character_health_change(type: Character.Type, current_health:int, max_health:int) -> void:
	if type == Character.Type.PLAYER:
		player_healthbar.refresh(current_health, max_health)
		if current_health >= 0 and death_screen == null:
			death_screen = DEATH_SCREEN_PREFAB.instantiate()
			add_child(death_screen)
		else:
			time_start_healthbar_visible = Time.get_ticks_msec()
			enemy_avatar.texture = avatar_map[type]
			enemy_healthbar.refresh(current_health, max_health)
			enemy_avatar.visible = true
			enemy_healthbar.visible = true
func on_checkpoint_complete() -> void:
	go_indicator.start_flickering()

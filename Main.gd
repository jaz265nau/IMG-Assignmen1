extends Node

# === Paths that match your project ===
const COIN_LABEL_PATH   := "UI/Control/CoinsLabel"
const TIMER_LABEL_PATH  := "HUD/TopBar/Timelabel"
const PAUSE_BUTTON_PATH := "HUD/TopBar/PauseButton"
const LEVEL_TIMER_PATH  := "LevelTimer"

@onready var level_timer: Timer     = _req_node(LEVEL_TIMER_PATH)
@onready var pause_button: Button   = _req_node(PAUSE_BUTTON_PATH)
@onready var timer_label: Label     = _req_node(TIMER_LABEL_PATH)
@onready var coin_label: Label      = _req_node(COIN_LABEL_PATH)
@onready var hud: CanvasLayer       = _req_node("HUD")
@onready var player: Node           = _req_node("Player")  # has coins_collected

@onready var game_over_panel: Panel = _ensure_game_over_panel()

var total_coins: int = 0
var level_time_seconds: float = 30.0
var is_game_over: bool = false

func _ready() -> void:
	# Count coins
	total_coins = _count_initial_coins()

	# Connect pause button
	pause_button.pressed.connect(_on_pause_button_pressed)

	# Setup timer
	level_timer.wait_time = level_time_seconds
	level_timer.timeout.connect(_on_level_time_over)
	level_timer.start()

	# Hide game over UI initially
	game_over_panel.visible = false
	_update_timer_label(level_time_seconds)

func _process(_delta: float) -> void:
	if not is_game_over:
		_update_timer_label(level_timer.time_left)

		# Win check
		if player.coins_collected >= total_coins and total_coins > 0:
			_show_game_over(true, "All coins collected!")

	# Pause with ESC
	if Input.is_action_just_pressed("ui_cancel") and not is_game_over:
		_toggle_pause()

# -------------------------------
# UI updates
# -------------------------------
func _update_timer_label(time_left: float) -> void:
	timer_label.text = "Time: %ds" % int(max(0, ceil(time_left)))

func _on_level_time_over() -> void:
	if is_game_over:
		return
	if player.coins_collected < total_coins:
		_show_game_over(false, "Time's up!")
	else:
		_show_game_over(true, "All coins collected!")

# -------------------------------
# Game Over handling
# -------------------------------
func _show_game_over(win: bool, reason: String) -> void:
	is_game_over = true

	var title: Label = game_over_panel.get_node("Title")
	var reason_lbl: Label = game_over_panel.get_node("Reason")
	var restart_btn: Button = game_over_panel.get_node("RestartButton")

	title.text = "You Win!" if win else "Game Over"
	reason_lbl.text = reason
	game_over_panel.visible = true

	get_tree().paused = true
	pause_button.disabled = true
	restart_btn.pressed.connect(_on_restart_pressed)

# -------------------------------
# Pause / Restart
# -------------------------------
func _on_pause_button_pressed() -> void:
	_toggle_pause()

func _toggle_pause() -> void:
	if is_game_over:
		return
	var paused_now := not get_tree().paused
	get_tree().paused = paused_now
	pause_button.text = "Resume" if paused_now else "Pause"

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

# -------------------------------
# Helpers
# -------------------------------
func _count_initial_coins() -> int:
	var count := 0
	var root := get_tree().current_scene
	if root == null:
		return 0
	var q: Array = [root]
	while not q.is_empty():
		var n: Node = q.pop_back()
		if n == hud or hud.is_ancestor_of(n):
			continue
		var name := str(n.name).to_lower()
		if name.find("coin") != -1:
			count += 1
		for c in n.get_children():
			q.append(c)
	return count

func _req_node(path: String):
	var n = get_node_or_null(path)
	if n == null:
		push_error("Node not found at '%s' — update the path constant." % path)
	return n

func _ensure_game_over_panel() -> Panel:
	var panel := hud.get_node_or_null("GameOver") as Panel
	if panel:
		panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		return panel

	# Auto-create a minimal Game Over panel
	panel = Panel.new()
	panel.name = "GameOver"
	panel.visible = false
	panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hud.add_child(panel)

	var title = Label.new()
	title.name = "Title"
	title.text = "Game Over"
	panel.add_child(title)

	var reason = Label.new()
	reason.name = "Reason"
	reason.text = "Reason"
	panel.add_child(reason)

	var btn = Button.new()
	btn.name = "RestartButton"
	btn.text = "Restart"
	panel.add_child(btn)

	return panel

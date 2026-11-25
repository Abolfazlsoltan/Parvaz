extends Node2D

const BG := Color("#080B18")
const CYAN := Color("#45E8FF")
const PINK := Color("#FF477E")
const GOLD := Color("#FFD166")
const PURPLE := Color("#B36BFF")
const GREEN := Color("#65F59A")
const GRID := Color("#141A32")

var state := "menu"
var paused := false
var high_score := 0
var score := 0
var lives := 3
var elapsed := 0.0
var spawn_timer := 0.0
var shot_timer := 0.0
var dash_timer := 0.0
var dash_cooldown := 0.0
var invulnerable := 0.0
var shield := false
var triple_timer := 0.0
var player := Vector2(0.5, 0.5)
var move_dir := Vector2.ZERO
var enemies: Array[Dictionary] = []
var bullets: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var powerups: Array[Dictionary] = []
var touch_index := -1
var joystick_origin := Vector2.ZERO
var screen_size := Vector2(960, 540)
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_load_record()
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	set_process(true)
	queue_redraw()

func _on_viewport_resized() -> void:
	screen_size = get_viewport_rect().size
	queue_redraw()

func _load_record() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://record.cfg") == OK:
		high_score = int(cfg.get_value("game", "high_score", 0))

func _save_record() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "high_score", high_score)
	cfg.save("user://record.cfg")

func _reset_game() -> void:
	player = Vector2(0.5, 0.5)
	move_dir = Vector2.ZERO
	enemies.clear()
	bullets.clear()
	particles.clear()
	powerups.clear()
	score = 0
	lives = 3
	elapsed = 0.0
	spawn_timer = 0.25
	shot_timer = 0.0
	dash_timer = 0.0
	dash_cooldown = 0.0
	invulnerable = 0.0
	shield = false
	triple_timer = 0.0
	touch_index = -1

func _start_game() -> void:
	_reset_game()
	state = "play"
	paused = false
	queue_redraw()

func _toggle_pause() -> void:
	if state == "play":
		paused = not paused
	elif state == "menu" or state == "over":
		_start_game()
	queue_redraw()

func _norm(v: Vector2) -> Vector2:
	return v.normalized() if v.length() > 0.001 else Vector2.ZERO

func _burst(pos: Vector2, color: Color, count: int = 12) -> void:
	for i in range(count):
		var angle := rng.randf_range(0.0, TAU)
		var speed := rng.randf_range(0.08, 0.35)
		particles.append({
			"pos": pos, "vel": Vector2(cos(angle), sin(angle)) * speed,
			"life": rng.randf_range(0.25, 0.6), "max_life": 0.6, "color": color
		})

func _dash() -> void:
	if dash_cooldown > 0.0 or state != "play" or paused:
		return
	var direction := _norm(move_dir)
	if direction == Vector2.ZERO and not enemies.is_empty():
		var nearest: Dictionary = enemies[0]
		var nearest_dist := player.distance_squared_to(nearest.pos)
		for enemy in enemies:
			var d := player.distance_squared_to(enemy.pos)
			if d < nearest_dist:
				nearest = enemy
				nearest_dist = d
		direction = _norm(nearest.pos - player)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	move_dir = direction
	dash_timer = 0.18
	dash_cooldown = 1.15
	invulnerable = 0.35
	_burst(player, CYAN, 22)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			_toggle_pause()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_SPACE:
			_dash()
			return
	if event is InputEventScreenTouch:
		var point := _to_normalized(event.position)
		if event.pressed:
			if state != "play":
				_start_game()
				return
			if paused:
				paused = false
				return
			if point.x > 0.72 and point.y < 0.28:
				_dash()
			elif point.x < 0.58 and point.y < 0.82:
				touch_index = event.index
				joystick_origin = point
				_set_joystick(point)
			else:
				_dash()
		elif event.index == touch_index:
			touch_index = -1
			move_dir = Vector2.ZERO
	elif event is InputEventScreenDrag and event.index == touch_index:
		_set_joystick(_to_normalized(event.position))
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var point := _to_normalized(event.position)
			if state != "play":
				_start_game()
			elif paused:
				paused = false
			elif point.x > 0.72 and point.y < 0.28:
				_dash()
			elif point.x < 0.58 and point.y < 0.82:
				touch_index = -2
				joystick_origin = point
				_set_joystick(point)
			else:
				_dash()
	elif event is InputEventMouseMotion and touch_index == -2 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_set_joystick(_to_normalized(event.position))

func _to_normalized(point: Vector2) -> Vector2:
	var rect := get_viewport_rect()
	return Vector2(point.x / maxf(1.0, rect.size.x), 1.0 - point.y / maxf(1.0, rect.size.y))

func _set_joystick(point: Vector2) -> void:
	var delta := (point - joystick_origin) * 3.0
	move_dir = _norm(Vector2(clampf(delta.x, -1.0, 1.0), clampf(delta.y, -1.0, 1.0)))

func _process(delta: float) -> void:
	if state != "play" or paused:
		queue_redraw()
		return
	var dt := minf(delta, 0.04)
	elapsed += dt
	spawn_timer -= dt
	shot_timer -= dt
	dash_timer = maxf(0.0, dash_timer - dt)
	dash_cooldown = maxf(0.0, dash_cooldown - dt)
	invulnerable = maxf(0.0, invulnerable - dt)
	triple_timer = maxf(0.0, triple_timer - dt)
	var speed := 1.15 if dash_timer > 0.0 else 0.48
	player.x = clampf(player.x + move_dir.x * speed * dt, 0.035, 0.965)
	player.y = clampf(player.y + move_dir.y * speed * dt, 0.07, 0.93)
	_spawn_enemies()
	_auto_shoot()
	_update_bullets(dt)
	_update_enemies(dt)
	_handle_bullet_hits()
	_handle_player_hits()
	_update_powerups(dt)
	_update_particles(dt)
	queue_redraw()

func _spawn_enemies() -> void:
	if spawn_timer > 0.0:
		return
	var count := 1 + int(elapsed / 35.0)
	for i in range(count):
		var side := rng.randi_range(0, 3)
		var v := rng.randf()
		var pos := Vector2(v, -0.04)
		match side:
			1: pos = Vector2(1.04, v)
			2: pos = Vector2(v, 1.04)
			3: pos = Vector2(-0.04, v)
		var roll := rng.randf()
		var kind := "chaser"
		if roll > 0.65 and roll <= 0.90:
			kind = "dart"
		elif roll > 0.90 and elapsed > 25.0:
			kind = "tank"
		var hp := 5 if kind == "tank" else 1
		enemies.append({"pos": pos, "kind": kind, "hp": hp, "phase": rng.randf_range(0.0, 6.0)})
	spawn_timer = maxf(0.28, 1.15 - elapsed * 0.009)

func _auto_shoot() -> void:
	if shot_timer > 0.0 or enemies.is_empty():
		return
	var nearest: Dictionary = enemies[0]
	for enemy in enemies:
		if player.distance_squared_to(enemy.pos) < player.distance_squared_to(nearest.pos):
			nearest = enemy
	var direction := _norm(nearest.pos - player)
	var angles: Array[float] = [-0.18, 0.0, 0.18] if triple_timer > 0.0 else [0.0]
	for angle in angles:
		var velocity := direction.rotated(angle) * 1.5
		bullets.append({"pos": player, "vel": velocity, "life": 1.1})
	shot_timer = 0.22

func _update_bullets(dt: float) -> void:
	for bullet in bullets:
		bullet.pos += bullet.vel * dt
		bullet.life -= dt

func _update_enemies(dt: float) -> void:
	for enemy in enemies:
		var direction := _norm(player - enemy.pos)
		var base_speed := 0.19
		match enemy.kind:
			"dart": base_speed = 0.36
			"tank": base_speed = 0.11
		enemy.pos += direction * base_speed * (1.0 + elapsed / 240.0) * dt
		enemy.phase += dt * 2.0

func _handle_bullet_hits() -> void:
	for bullet in bullets:
		if bullet.life <= 0.0:
			continue
		for enemy in enemies:
			var radius := 0.035
			if enemy.kind == "dart":
				radius = 0.025
			elif enemy.kind == "tank":
				radius = 0.055
			if bullet.pos.distance_to(enemy.pos) < radius:
				bullet.life = 0.0
				enemy.hp -= 1
				if enemy.hp <= 0:
					var kind: String = enemy.kind
					score += 50 if kind == "tank" else (15 if kind == "dart" else 10)
					var color: Color = PURPLE if kind == "tank" else (GOLD if kind == "dart" else PINK)
					_burst(enemy.pos, color)
					enemy.kind = "dead"
					if rng.randf() < 0.09:
						powerups.append({"pos": enemy.pos, "kind": ["shield", "triple", "nova"].pick_random(), "life": 9.0})
				break

func _handle_player_hits() -> void:
	for enemy in enemies:
		if enemy.kind == "dead" or enemy.pos.distance_to(player) >= 0.045:
			continue
		if dash_timer > 0.0:
			enemy.kind = "dead"
			score += 10
			_burst(enemy.pos, CYAN)
		elif invulnerable <= 0.0:
			if shield:
				shield = false
			else:
				lives -= 1
			invulnerable = 1.25
			enemy.kind = "dead"
			_burst(player, PINK, 20)
			if lives <= 0:
				state = "over"
				high_score = maxi(high_score, score)
				_save_record()

func _update_powerups(dt: float) -> void:
	for item in powerups:
		item.life -= dt
		if item.pos.distance_to(player) < 0.055:
			match item.kind:
				"shield": shield = true
				"triple": triple_timer = 10.0
				"nova":
					for enemy in enemies:
						if enemy.kind != "dead":
							enemy.kind = "dead"
							score += 10
							_burst(enemy.pos, GOLD, 8)
			item.life = 0.0

func _update_particles(dt: float) -> void:
	for particle in particles:
		particle.pos += particle.vel * dt
		particle.life -= dt
	bullets = bullets.filter(func(b): return b.life > 0.0 and b.pos.x > -0.1 and b.pos.x < 1.1 and b.pos.y > -0.1 and b.pos.y < 1.1)
	enemies = enemies.filter(func(e): return e.kind != "dead")
	powerups = powerups.filter(func(p): return p.life > 0.0)
	particles = particles.filter(func(p): return p.life > 0.0)

func _screen_pos(point: Vector2) -> Vector2:
	return Vector2(point.x * screen_size.x, (1.0 - point.y) * screen_size.y)

func _draw() -> void:
	var size := get_viewport_rect().size
	screen_size = size
	draw_rect(Rect2(Vector2.ZERO, size), BG)
	for i in range(1, 12):
		var x := size.x * i / 12.0
		draw_line(Vector2(x, 0), Vector2(x, size.y), GRID, 1.0)
	for i in range(1, 8):
		var y := size.y * i / 8.0
		draw_line(Vector2(0, y), Vector2(size.x, y), GRID, 1.0)
	for particle in particles:
		var alpha := clampf(particle.life / particle.max_life, 0.0, 1.0)
		draw_circle(_screen_pos(particle.pos), 3.0, Color(particle.color, alpha))
	for bullet in bullets:
		draw_circle(_screen_pos(bullet.pos), 4.0, CYAN)
	for enemy in enemies:
		var color: Color = PINK
		var radius := 12.0
		if enemy.kind == "dart":
			color = GOLD
			radius = 9.0
		elif enemy.kind == "tank":
			color = PURPLE
			radius = 21.0
		var pos := _screen_pos(enemy.pos)
		draw_arc(pos, radius, 0.0, TAU, 32, color, 2.0, true)
		draw_circle(pos, radius * 0.35, color)
	for item in powerups:
		var color: Color = GREEN if item.kind == "shield" else (CYAN if item.kind == "triple" else GOLD)
		draw_circle(_screen_pos(item.pos), 8.0, color)
	var p := _screen_pos(player)
	draw_circle(p, 25.0, Color(CYAN, 0.12))
	draw_arc(p, 14.0, 0.0, TAU, 32, CYAN, 2.0, true)
	draw_circle(p, 6.0, CYAN)
	if shield:
		draw_arc(p, 24.0, 0.0, TAU, 40, GREEN, 2.0, true)
	_draw_hud(size)

func _draw_text(text: String, pos: Vector2, font_size: int, color: Color, centered: bool = true) -> void:
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var x := pos.x - width * 0.5 if centered else pos.x
	draw_string(font, Vector2(x, pos.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw_hud(size: Vector2) -> void:
	if state == "play":
		_draw_text("SCORE  %d" % score, Vector2(size.x * 0.18, 32), 17, Color.WHITE)
		_draw_text("BEST  %d" % high_score, Vector2(size.x * 0.18, 52), 11, Color("#A5B4D6"))
		_draw_text("♥ ".repeat(lives), Vector2(size.x * 0.82, 35), 18, PINK)
		_draw_text("DASH", Vector2(18, size.y - 25), 10, CYAN, false)
		draw_rect(Rect2(18, size.y - 18, 120, 5), Color("#25324D"))
		var progress := 1.0 - dash_cooldown / 1.15
		draw_rect(Rect2(18, size.y - 18, 120 * clampf(progress, 0.0, 1.0), 5), CYAN if dash_cooldown <= 0.0 else Color("#55718B"))
		if triple_timer > 0.0:
			_draw_text("TRIPLE %ds" % int(ceil(triple_timer)), Vector2(size.x * 0.82, size.y - 30), 11, GREEN)
		_draw_text("DRAG LEFT SIDE TO MOVE  •  TAP RIGHT TO DASH", Vector2(size.x * 0.5, size.y - 48), 10, Color("#8191B5"))
	elif state == "menu":
		_draw_text("NEON", Vector2(size.x * 0.5, size.y * 0.34), 55, CYAN)
		_draw_text("SURVIVOR", Vector2(size.x * 0.5, size.y * 0.45), 34, Color.WHITE)
		_draw_text("SURVIVE THE NEON SWARM", Vector2(size.x * 0.5, size.y * 0.55), 14, PURPLE)
		_draw_text("TOUCH ANYWHERE TO START", Vector2(size.x * 0.5, size.y * 0.69), 16, GOLD)
		_draw_text("BEST SCORE  %d" % high_score, Vector2(size.x * 0.5, size.y * 0.77), 13, Color("#A5B4D6"))
		_draw_text("MOVE: DRAG LEFT  |  DASH: TAP RIGHT", Vector2(size.x * 0.5, size.y * 0.86), 11, Color("#A5B4D6"))
	elif state == "over":
		_draw_text("GAME OVER", Vector2(size.x * 0.5, size.y * 0.37), 38, PINK)
		_draw_text("SCORE  %d" % score, Vector2(size.x * 0.5, size.y * 0.49), 24, Color.WHITE)
		_draw_text("RECORD  %d" % high_score, Vector2(size.x * 0.5, size.y * 0.58), 18, GOLD)
		_draw_text("TAP TO PLAY AGAIN", Vector2(size.x * 0.5, size.y * 0.72), 16, CYAN)
	if paused:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.58))
		_draw_text("PAUSED", Vector2(size.x * 0.5, size.y * 0.46), 38, Color.WHITE)
		_draw_text("TAP TO RESUME  •  PRESS P", Vector2(size.x * 0.5, size.y * 0.58), 15, CYAN)

extends Node2D
# Neon Survivor V3.5 — native Godot port in progress.
# Ported from NeonSurvivor_V3.5_Performance_UI.py. Keep gameplay data in sync with source.

const BG := Color("#080B18")
const GRID := Color("#141A32")
const CYAN := Color("#41E8FF")
const PINK := Color("#FF477E")
const GOLD := Color("#FFD166")
const PURPLE := Color("#B36BFF")
const GREEN := Color("#65F59A")
const SAVE_PATH := "user://neon_v3_save.json"
const SOUND_BANK_SCRIPT = preload("res://scripts/sound_bank.gd")

const SHIPS := [
 {"id":"viper","name":"VIPER MK-I","role":"Balanced Twin-Cannon","stage":1,"cost":0,"primary":Color8(100,240,255),"secondary":Color8(35,95,145),"bullet":Color8(140,250,255),"size":25,"hp":4,"rate":0.11,"speed":1020.0,"damage":1.0,"dash":0.95,"pattern":"twin","ability":"Fast Twin Plasma"},
 {"id":"interceptor","name":"SOLAR FALCON","role":"3-Way Spread & Quick Dash","stage":2,"cost":1500,"primary":Color8(255,215,70),"secondary":Color8(135,85,20),"bullet":Color8(255,235,110),"size":26,"hp":4,"rate":0.13,"speed":1060.0,"damage":0.95,"dash":0.65,"pattern":"spread3","ability":"35% Faster Dash Cooldown"},
 {"id":"valkyrie","name":"VALKYRIE X","role":"Homing Missiles + Laser","stage":4,"cost":4000,"primary":Color8(110,255,145),"secondary":Color8(25,115,65),"bullet":Color8(130,255,165),"size":28,"hp":5,"rate":0.14,"speed":980.0,"damage":1.15,"dash":0.90,"pattern":"homing","ability":"Auto-Homing Wing Missiles"},
 {"id":"phantom","name":"VOID PHANTOM","role":"Piercing Rail-Beams","stage":6,"cost":8000,"primary":Color8(140,180,255),"secondary":Color8(40,70,140),"bullet":Color8(180,210,255),"size":27,"hp":4,"rate":0.17,"speed":1280.0,"damage":1.85,"dash":0.75,"pattern":"pierce","ability":"Shots Pierce Through Enemies"},
 {"id":"titan","name":"AEGIS TITAN","role":"5-Cannon Heavy Cruiser","stage":8,"cost":14000,"primary":Color8(255,95,135),"secondary":Color8(135,28,55),"bullet":Color8(255,135,165),"size":31,"hp":6,"rate":0.16,"speed":960.0,"damage":1.35,"dash":1.05,"pattern":"heavy5","ability":"Heavy Armor + 5-Gun Barrage"}
]
const DIFFICULTIES := {"easy":{"hp":0.7,"speed":0.8,"reward":0.8,"label":"CADET"},"normal":{"hp":1.0,"speed":1.0,"reward":1.0,"label":"PILOT"},"hard":{"hp":1.4,"speed":1.2,"reward":1.3,"label":"ACE"},"nightmare":{"hp":2.0,"speed":1.4,"reward":1.8,"label":"NIGHTMARE"}}
const ENEMY_TYPES := {"scout":{"hp":2,"speed":135.0,"r":18.0,"color":Color8(255,65,110),"score":25},"interceptor":{"hp":2,"speed":210.0,"r":16.0,"color":Color8(255,215,60),"score":40},"gunship":{"hp":9,"speed":85.0,"r":29.0,"color":Color8(120,160,255),"score":110},"boss":{"hp":85,"speed":75.0,"r":60.0,"color":Color8(255,85,120),"score":800}}
const ACHIEVEMENTS := [
 {"id":"first_blood","name":"First Blood","desc":"Destroy your first enemy"},
 {"id":"stage_5","name":"Veteran Pilot","desc":"Reach Stage 5"},
 {"id":"stage_10","name":"Elite Ace","desc":"Reach Stage 10"},
 {"id":"combo_10","name":"Combo Master","desc":"Achieve 10x combo"},
 {"id":"score_10k","name":"High Scorer","desc":"Score 10,000 points"},
 {"id":"score_50k","name":"Legend","desc":"Score 50,000 points"},
 {"id":"boss_slayer","name":"Boss Slayer","desc":"Defeat a Dreadnought"},
 {"id":"all_ships","name":"Fleet Commander","desc":"Unlock all ships"},
 {"id":"no_damage","name":"Untouchable","desc":"Complete a stage without damage"},
 {"id":"speed_demon","name":"Speed Demon","desc":"Use dash 50 times"},
 {"id":"survivor","name":"Survivor","desc":"Play for 30 minutes total"},
 {"id":"killer","name":"Destroyer","desc":"Destroy 500 enemies"},
 {"id":"collector","name":"Collector","desc":"Collect 50 powerups"},
 {"id":"perfectionist","name":"Perfectionist","desc":"Complete 5 stages with full HP"},
 {"id":"marathon","name":"Marathon","desc":"Play 20 runs"}
]
const POWERUPS := {"shield":{"color":Color8(65,230,255),"symbol":"S","label":"AEGIS SHIELD"},"overdrive":{"color":Color8(95,255,130),"symbol":"W","label":"WEAPON OVERDRIVE"},"morph":{"color":Color8(255,185,60),"symbol":"X","label":"SHIP MORPH CORE"},"repair":{"color":Color8(255,95,130),"symbol":"+","label":"HULL REPAIR"},"nuke":{"color":Color.WHITE,"symbol":"N","label":"EMP NOVA"},"magnet":{"color":Color8(255,255,100),"symbol":"M","label":"MAGNET PULSE"},"slow":{"color":Color8(180,200,255),"symbol":"T","label":"TIME DILATION"}}

var rng := RandomNumberGenerator.new()
var sound_bank: Node
var viewport_size := Vector2(960,540)
var state := "menu"
var achievements_return_state := "menu"
var paused := false
var difficulty := "normal"
var selected_ship := "viper"
var unlocked_ships: Array[String] = ["viper"]
var credits := 0
var high_score := 0
var best_stage := 1
var score := 0
var lives := 3
var stage := 1
var subwave := 1
var total_subwaves := 3
var wave_spawned := false
var wave_delay := 0.6
var banner_time := 0.0
var banner_title := ""
var banner_subtitle := ""
var elapsed := 0.0
var world_time := 0.0
var save_timer := 0.0
var player := Vector2.ZERO
var previous_player := Vector2.ZERO
var velocity := Vector2.ZERO
var aim_angle := -PI / 2
var hp := 4
var max_hp := 4
var invulnerable := 0.0
var dash_time := 0.0
var dash_cooldown := 0.0
var dash_direction := Vector2.UP
var dash_count := 0
var shield := false
var overdrive_time := 0.0
var magnet_time := 0.0
var slow_time := 0.0
var fire_cooldown := 0.0
var combo := 1
var combo_time := 0.0
var damage_taken_stage := 0
var powerups_collected := 0
var total_kills := 0
var total_runs := 0
var total_playtime := 0.0
var bosses_defeated := false
var perfect_stages := 0
var muted := false
var sfx_volume := 0.7
var music_volume := 0.5
var target_fps := 45
var tutorial_done := false
var tutorial_active := false
var achievements: Array[String] = []
var stars: Array[Dictionary] = []
var bullets: Array[Dictionary] = []
var enemy_bullets: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var trails: Array[Dictionary] = []
var shockwaves: Array[Dictionary] = []
var popups: Array[Dictionary] = []
var powerups: Array[Dictionary] = []
var drag_id := -1
var mouse_drag := false
var active_slider := ""
var slider_pointer_id := -1
var last_touch_ms := 0
var last_touch_pos := Vector2.ZERO
var touch_ripple_pos := Vector2.ZERO
var touch_ripple_time := 0.0
var last_drag := Vector2.ZERO
var drag_delta := Vector2.ZERO
var dash_requested := false
var flash_time := 0.0
var screen_shake := 0.0
var uid := 0

func _ready() -> void:
 rng.randomize()
 sound_bank=SOUND_BANK_SCRIPT.new()
 add_child(sound_bank)
 viewport_size = get_viewport_rect().size
 _load_save()
 Engine.max_fps=target_fps
 _sync_audio()
 _create_stars()
 _reset_run()
 get_viewport().size_changed.connect(_resize)

func _resize() -> void:
 viewport_size = get_viewport_rect().size
 queue_redraw()

func _create_stars() -> void:
 stars.clear()
 for i in range(55):
  stars.append({"pos":Vector2(rng.randf_range(0,viewport_size.x),rng.randf_range(0,viewport_size.y)),"speed":rng.randf_range(0.35,1.0)})

func _ship() -> Dictionary:
 for ship in SHIPS:
  if ship.id == selected_ship:
   return ship
 return SHIPS[0]

func _ship_by_id(id: String) -> Variant:
 for ship in SHIPS:
  if ship.id == id:
   return ship
 return null

func _load_save() -> void:
 if not FileAccess.file_exists(SAVE_PATH):
  return
 var file := FileAccess.open(SAVE_PATH,FileAccess.READ)
 if file == null:
  return
 var data: Variant = JSON.parse_string(file.get_as_text())
 if not data is Dictionary:
  return
 high_score = maxi(0,int(data.get("hi",0)))
 best_stage = maxi(1,int(data.get("best_stage",1)))
 credits = maxi(0,int(data.get("credits",0)))
 target_fps = 60 if int(data.get("target_fps",45)) >= 60 else 45
 var saved_ships: Variant = data.get("unlocked_ships",["viper"])
 if saved_ships is Array:
  for ship_id in saved_ships:
   if ship_id is String and _ship_by_id(ship_id) != null and not unlocked_ships.has(ship_id):
    unlocked_ships.append(ship_id)
 if not unlocked_ships.has("viper"):
  unlocked_ships.push_front("viper")
 selected_ship = str(data.get("selected_ship","viper"))
 if not unlocked_ships.has(selected_ship):
  selected_ship = "viper"
 difficulty = str(data.get("difficulty","normal"))
 if not DIFFICULTIES.has(difficulty):
  difficulty = "normal"
 muted = data.get("muted",false) == true
 sfx_volume = clampf(float(data.get("sfx_volume",0.7)),0.0,1.0)
 music_volume = clampf(float(data.get("music_volume",0.5)),0.0,1.0)
 tutorial_done = data.get("tutorial_done",false) == true
 var saved_achievements: Variant = data.get("achievements",[])
 if saved_achievements is Array:
  achievements.assign(saved_achievements)
 total_kills = maxi(0,int(data.get("total_kills",0)))
 total_playtime = maxf(0.0,float(data.get("total_playtime",0.0)))
 total_runs = maxi(0,int(data.get("total_runs",0)))
 bosses_defeated = data.get("bosses_defeated",false) == true

func _save() -> void:
 _sync_audio()
 var data := {"hi":high_score,"best_stage":best_stage,"target_fps":target_fps,"credits":credits,"unlocked_ships":unlocked_ships,"selected_ship":selected_ship,"muted":muted,"sfx_volume":sfx_volume,"music_volume":music_volume,"difficulty":difficulty,"tutorial_done":tutorial_done,"achievements":achievements,"total_kills":total_kills,"total_runs":total_runs,"total_playtime":total_playtime,"bosses_defeated":bosses_defeated}
 var file := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
 if file != null:
  file.store_string(JSON.stringify(data))

func _sync_audio() -> void:
 if sound_bank==null:return
 sound_bank.sfx_volume=sfx_volume
 sound_bank.music_volume=music_volume
 sound_bank.set_muted(muted)
 if sound_bank.music_player!=null:sound_bank.music_player.volume_db=linear_to_db(clampf(music_volume,0.0,1.0))

func _reset_run() -> void:
 var cfg := _ship()
 player = Vector2(viewport_size.x*0.5,viewport_size.y*0.78)
 previous_player = player
 velocity = Vector2.ZERO
 aim_angle = -PI/2
 bank = 0.0
 muzzle_flash_time = 0.0
 hp = int(cfg.hp)
 max_hp = hp
 invulnerable = 0.0
 dash_time = 0.0
 dash_cooldown = 0.0
 dash_direction = Vector2.UP
 dash_count = 0
 shield = false
 overdrive_time = 0.0
 magnet_time = 0.0
 slow_time = 0.0
 fire_cooldown = 0.0
 combo = 1
 combo_time = 0.0
 score = 0
 elapsed = 0.0
 world_time = 0.0
 damage_taken_stage = 0
 powerups_collected = 0
 flash_time = 0.0
 screen_shake = 0.0
 bullets.clear()
 enemy_bullets.clear()
 enemies.clear()
 particles.clear()
 trails.clear()
 shockwaves.clear()
 popups.clear()
 powerups.clear()
 stage = 1
 subwave = 1
 total_subwaves = 3
 wave_spawned = false
 wave_delay = 0.6
 banner_time = 0.0
 paused = false

func _start_run() -> void:
 _reset_run()
 state = "play"
 total_runs += 1
 tutorial_active = not tutorial_done
 _start_stage(1)
 if sound_bank!=null:
  sound_bank.play_sfx("subwave")
  sound_bank.start_music()
 _save()

func _start_stage(number: int) -> void:
 stage = number
 subwave = 1
 total_subwaves = 4 if number % 3 == 0 or number >= 4 else 3
 wave_spawned = false
 wave_delay = 0.6
 damage_taken_stage = 0
 _announce("STAGE %d" % stage,"SUB-WAVE 1 / %d" % total_subwaves)

func _announce(title: String, subtitle: String) -> void:
 banner_title = title
 banner_subtitle = subtitle
 banner_time = 2.1

func _spawn_subwave() -> void:
 var hp_scale := (1.0 + (stage-1)*0.14) * DIFFICULTIES[difficulty].hp
 var w := viewport_size.x
 var h := viewport_size.y
 if subwave == 1:
  var count := mini(9,5+floori(float(stage)/2.0))
  for i in range(count):
   var offset := i-count/2
   var x := w*0.5+offset*minf(75.0,w*0.085)
   _create_enemy("scout",Vector2(x,-40-abs(offset)*34),"formation_hover",Vector2(x,h*0.22+abs(offset)*24),1,h*0.22,i*0.5,hp_scale,rng.randf_range(1.6,3.0))
 elif subwave == 2:
  var per_side := mini(5,3+floori(float(stage)/3.0))
  for side in [-1,1]:
   for i in range(per_side):
    var x := -45-i*55 if side == -1 else w+45+i*55
    var y := h*(0.18+i*0.07)
    _create_enemy("interceptor",Vector2(x,y),"sine_patrol",Vector2(x,y),-side,y,i*0.85,hp_scale,rng.randf_range(1.5,2.8))
 elif subwave == 3:
  var gunships := mini(3,1+floori(float(stage)/3.0))
  for i in range(gunships):
   var x := w*(i+1.0)/(gunships+1.0)
   _create_enemy("gunship",Vector2(x,-55),"strafe_cruiser",Vector2(x,h*0.24),1,h*0.24,i*1.4,hp_scale,1.4)
  var escorts := mini(6,2+floori(float(stage)/2.0))
  for i in range(escorts):
   var x := w*(0.15+0.7*(float(i)/maxi(1,escorts-1)))
   _create_enemy("scout",Vector2(x,-95),"swoop_arc",Vector2(x,h*0.34),1,h*0.34,i*0.9,hp_scale,rng.randf_range(1.8,3.2))
 else:
  _create_enemy("boss",Vector2(w*0.5,-90),"boss_cruiser",Vector2(w*0.5,h*0.22),1,h*0.22,0,(1.0+(stage-1)*0.22)*DIFFICULTIES[difficulty].hp,1.3)
  for side in [-1,1]:
   _create_enemy("interceptor",Vector2(w*0.5+side*160,-50),"formation_hover",Vector2(w*0.5+side*170,h*0.26),1,h*0.26,side,hp_scale,2.0)
 wave_spawned = true

func _update_stage_director(dt: float) -> void:
 banner_time = maxf(0.0,banner_time-dt)
 if not wave_spawned:
  wave_delay -= dt
  if wave_delay <= 0.0:
   _spawn_subwave()
  return
 if enemies.is_empty():
  if subwave < total_subwaves:
   subwave += 1
   if sound_bank!=null:sound_bank.play_sfx("subwave")
   wave_spawned = false
   wave_delay = 0.85
   _announce("STAGE %d" % stage,"BOSS SQUADRON!" if subwave == 4 else "SUB-WAVE %d / %d" % [subwave,total_subwaves])
  else:
   if damage_taken_stage == 0:
    perfect_stages += 1
   if sound_bank!=null:sound_bank.play_sfx("stage_clear")
   var bonus := int(350*stage*DIFFICULTIES[difficulty].reward)
   score += bonus
   credits += int((120+stage*40)*DIFFICULTIES[difficulty].reward)
   _popup(player+Vector2(0,-40),"STAGE %d CLEAR! +%d" % [stage,bonus],GOLD)
   _shockwave(player,GOLD,170)
   _check_ship_unlocks()
   _spawn_powerup(Vector2(viewport_size.x*0.5,viewport_size.y*0.35),"morph" if unlocked_ships.size()>1 else "overdrive")
   _check_achievements()
   _start_stage(stage+1)
   _save()

func _create_enemy(kind: String,pos: Vector2,mode: String="formation_hover",anchor: Vector2=Vector2.ZERO,dir_x: int=1,base_y: float=150.0,phase: float=0.0,hp_multiplier: float=1.0,shoot_cd: float=2.0) -> void:
 if enemies.size() >= 18:
  return
 var spec: Dictionary = ENEMY_TYPES[kind]
 var max_hp := maxi(1,roundi(spec.hp*hp_multiplier))
 uid += 1
 enemies.append({"uid":uid,"kind":kind,"pos":pos,"vel":Vector2.ZERO,"hp":max_hp,"max_hp":max_hp,"r":spec.r,"speed":spec.speed*DIFFICULTIES[difficulty].speed,"score":spec.score,"mode":mode,"anchor":anchor if anchor != Vector2.ZERO else pos,"dir_x":dir_x,"base_y":base_y,"phase":phase,"rot":0.0,"aim":PI/2,"shoot_cd":shoot_cd,"flash":0.0,"dead":false})

func _spawn_powerup(pos: Vector2,kind: String="") -> void:
 if kind.is_empty():
  var roll := rng.randf()
  kind = "shield" if roll<0.22 else "overdrive" if roll<0.46 else "morph" if roll<0.64 else "repair" if roll<0.78 else "nuke" if roll<0.84 else "magnet" if roll<0.94 else "slow"
 if powerups.size() >= 5:
  powerups.pop_front()
 powerups.append({"pos":pos,"vel":Vector2(0,58),"kind":kind,"time":11.0})

func _popup(pos: Vector2,text: String,color: Color=GOLD) -> void:
 popups.append({"pos":pos,"text":text,"color":color,"time":0.85,"max":0.85})

func _shockwave(pos: Vector2,color: Color,max_radius: float=95.0) -> void:
 shockwaves.append({"pos":pos,"radius":10.0,"max_radius":max_radius,"color":color,"time":0.36,"max":0.36})

func _burst(pos: Vector2,color: Color,count: int=18,speed: float=300.0,life: float=0.6,size: float=3.2) -> void:
 count = mini(count,6)
 size*=0.85
 for i in range(count):
  var angle := rng.randf_range(0.0,TAU)
  var spd := rng.randf_range(0.25,1.0)*speed
  particles.append({"pos":pos,"vel":Vector2(cos(angle),sin(angle))*spd,"life":rng.randf_range(0.3,0.9)*life,"max":life,"color":color,"size":rng.randf_range(1.4,size)})
 if particles.size() > 80:
  particles = particles.slice(particles.size()-80)

func _trigger_dash() -> void:
 if dash_cooldown>0.0 or dash_time>0.0:
  return
 var move := player-previous_player
 dash_direction = move.normalized() if move.length()>1.5 else Vector2(cos(aim_angle),sin(aim_angle))
 dash_time = 0.17
 dash_cooldown = _ship().dash
 invulnerable = maxf(invulnerable,0.25)
 dash_count += 1
 if sound_bank!=null:sound_bank.play_sfx("dash")
 _shockwave(player,_ship().primary,80)
 _burst(player,_ship().primary,26,410,0.42)
 _check_achievements()

func _hurt_player() -> void:
 hp -= 1
 invulnerable = 1.55
 screen_shake = 22.0
 flash_time = 0.35
 combo = 1
 damage_taken_stage += 1
 if sound_bank!=null:sound_bank.play_sfx("hurt")
 _shockwave(player,PINK,115)
 _burst(player,PINK,42,460,0.85,4.2)
 if hp <= 0:
  state = "over"
  tutorial_active = false
  high_score = maxi(high_score,score)
  credits += score/15
  _check_achievements()
  _save()
  if sound_bank!=null:sound_bank.stop_music()

func _kill_enemy(enemy: Dictionary,allow_drop: bool=true) -> void:
 if enemy.dead:
  return
 enemy.dead = true
 total_kills += 1
 if sound_bank!=null:sound_bank.play_sfx("big_explode" if enemy.kind in ["gunship","boss"] else "explode")
 if enemy.kind == "boss":
  bosses_defeated = true
 var color: Color = ENEMY_TYPES[enemy.kind].color
 var big: bool = enemy.kind in ["gunship","boss"]
 _burst(enemy.pos,color,48 if big else 22,400,0.72,4.2)
 _shockwave(enemy.pos,color,125 if big else 58)
 screen_shake = maxf(screen_shake,14.0 if big else 6.0)
 combo = mini(12,combo+1) if combo_time>0 else 1
 combo_time = 2.4
 var points := int(enemy.score*combo*DIFFICULTIES[difficulty].reward)
 score += points
 credits += maxi(2,points/25)
 _popup(enemy.pos,"+%d" % points,color)
 if allow_drop and rng.randf() < (0.45 if enemy.kind=="gunship" else 0.13):
  _spawn_powerup(enemy.pos)
 if enemy.kind == "boss":
  flash_time = 0.35
  for offset in [Vector2(-50,0),Vector2.ZERO,Vector2(50,0)]:
   _spawn_powerup(enemy.pos+offset)
 _check_achievements()

func _nearest_enemy() -> Variant:
 var best: Variant = null
 var best_distance := INF
 for enemy in enemies:
  if not enemy.dead:
   var distance: float = (enemy.pos-player).length_squared()
   if distance < best_distance:
    best_distance = distance
    best = enemy
 return best

func _add_player_bullet(pos: Vector2,direction: Vector2,pierce: int=0,homing: bool=false,radius: float=4.0) -> void:
 var cfg := _ship()
 var dir := direction.normalized()
 var damage: float = cfg.damage*(1.35 if overdrive_time>0 else 1.0)
 bullets.append({"pos":pos,"vel":dir*cfg.speed,"dir":dir,"speed":cfg.speed,"life":1.35,"color":cfg.bullet,"damage":damage,"pierce":pierce,"homing":homing,"radius":radius,"hits":[]})

func _fire_weapons() -> void:
 var cfg := _ship()
 var sfx: String="shoot_light"
 var aim := Vector2(cos(aim_angle),sin(aim_angle))
 var perpendicular := Vector2(-aim.y,aim.x)
 var pattern: String = cfg.pattern
 if pattern == "twin":
  for offset in ([-10,10] if overdrive_time<=0 else [-16,0,16]):
   _add_player_bullet(player+aim*22+perpendicular*offset,aim)
 elif pattern == "spread3":
  for angle in ([-0.22,0.0,0.22] if overdrive_time<=0 else [-0.34,-0.17,0.0,0.17,0.34]):
   _add_player_bullet(player+aim*22,aim.rotated(angle))
 elif pattern == "homing":
  sfx="shoot_plasma"
  _add_player_bullet(player+aim*24,aim,0,false,5)
  for angle in ([-0.42,0.42] if overdrive_time<=0 else [-0.55,-0.25,0.25,0.55]):
   _add_player_bullet(player+perpendicular*(angle*32),aim.rotated(angle),0,true,4)
 elif pattern == "pierce":
  sfx="shoot_plasma"
  for offset in ([0] if overdrive_time<=0 else [-11,11]):
   _add_player_bullet(player+aim*24+perpendicular*offset,aim,3,false,5)
 elif pattern == "heavy5":
  sfx="shoot_heavy"
  for angle in ([-0.28,-0.14,0.0,0.14,0.28] if overdrive_time<=0 else [-0.36,-0.24,-0.12,0.0,0.12,0.24,0.36]):
   _add_player_bullet(player+aim*24,aim.rotated(angle),0,false,5)
 if sound_bank!=null:sound_bank.play_sfx(sfx)
 muzzle_flash_time=0.045
 fire_cooldown = cfg.rate*(0.76 if overdrive_time>0 else 1.0)

func _enemy_shoot(enemy: Dictionary,angle: float,speed: float,radius: float,life: float) -> void:
 if enemy_bullets.size() < 28:
  enemy_bullets.append({"pos":enemy.pos,"vel":Vector2(cos(angle),sin(angle))*speed,"life":life,"radius":radius})

func _process(delta: float) -> void:
 var dt := minf(delta,0.033)
 touch_ripple_time=maxf(0.0,touch_ripple_time-dt)
 for star in stars:
  star.pos.y = fposmod(star.pos.y+22.0*dt,viewport_size.y)
 if state!="play" or paused or tutorial_active:
  flash_time=maxf(0.0,flash_time-dt)
  screen_shake=maxf(0.0,screen_shake-44.0*dt)
  queue_redraw()
  return
 elapsed+=dt
 total_playtime+=dt
 best_stage=maxi(best_stage,stage)
 save_timer+=dt
 if save_timer>=12.0:
  save_timer=0.0
  _save()
 var effective_dt:=dt*(0.5 if slow_time>0 else 1.0)
 world_time+=effective_dt
 _update_stage_director(effective_dt)
 previous_player=player
 var movement:=drag_delta
 drag_delta=Vector2.ZERO
 if movement.length()>90.0:
  movement=movement.normalized()*90.0
 player+=movement
 var keyboard:=Vector2(Input.get_axis("ui_left","ui_right"),Input.get_axis("ui_up","ui_down"))
 if keyboard.length()>0:
  player+=keyboard.normalized()*480.0*dt
 if dash_requested:
  dash_requested=false
  _trigger_dash()
 if dash_time>0.0:
  player+=dash_direction*1080.0*dt
  dash_time-=dt
  if rng.randf()<0.18:
   _burst(player,_ship().primary,2,60,0.28,4.2)
 var margin:=float(_ship().size+6)
 player.x=clampf(player.x,margin,viewport_size.x-margin)
 player.y=clampf(player.y,margin+40.0,viewport_size.y-margin)
 velocity=(player-previous_player)/maxf(0.001,dt)
 var desired_angle: float=-PI/2
 var target_bank:=clampf(velocity.x/320.0,-1.0,1.0)
 bank+=(target_bank-bank)*minf(1.0,10.0*dt)
 muzzle_flash_time=maxf(0.0,muzzle_flash_time-dt)
 var target:=_nearest_enemy()
 if target!=null:
  desired_angle=(target.pos-player).angle()
 aim_angle+=wrapf(desired_angle-aim_angle,-PI,PI)*minf(1.0,14.0*dt if target!=null else 8.0*dt)
 if velocity.length()>55.0 or dash_time>0:
  if trails.size()<18:trails.append({"pos":player,"time":0.14,"max":0.14,"dash":dash_time>0})
 for trail in trails:
  trail.time-=dt
 trails=trails.filter(func(item):return item.time>0)
 dash_cooldown=maxf(0.0,dash_cooldown-dt)
 invulnerable=maxf(0.0,invulnerable-dt)
 overdrive_time=maxf(0.0,overdrive_time-dt)
 magnet_time=maxf(0.0,magnet_time-dt)
 slow_time=maxf(0.0,slow_time-dt)
 combo_time=maxf(0.0,combo_time-dt)
 fire_cooldown-=dt
 if fire_cooldown<=0.0:
  _fire_weapons()
 var living:=enemies.filter(func(enemy):return not enemy.dead)
 for bullet in bullets:
  if bullet.homing and not living.is_empty():
   var nearest: Dictionary=living[0]
   for enemy in living:
    if (enemy.pos-bullet.pos).length_squared()<(nearest.pos-bullet.pos).length_squared():
     nearest=enemy
   var desired: Vector2=(nearest.pos-bullet.pos).normalized()*bullet.speed
   bullet.vel+=(desired-bullet.vel)*minf(1.0,8.5*dt)
   if bullet.vel.length_squared()>0:
    bullet.vel=bullet.vel.normalized()*bullet.speed
    bullet.dir=bullet.vel.normalized()
  bullet.pos+=bullet.vel*dt
  bullet.life-=dt
 for enemy in enemies:
  enemy.rot+=effective_dt*2.2
  enemy.flash=maxf(0.0,enemy.flash-dt)
  if enemy.kind=="gunship":enemy.hull_angle=PI/2+sin(world_time*1.1+enemy.phase)*0.22
  elif enemy.kind=="boss" and enemy.hp<enemy.max_hp*0.5 and rng.randf()<0.35:
   var side:=rng.randi_range(0,1)*2-1
   var smoke_pos:Vector2=enemy.pos+Vector2(side*enemy.r*0.85,-enemy.r*0.45)
   particles.append({"pos":smoke_pos,"vel":Vector2(rng.randf_range(-22,22),rng.randf_range(-65,-25)),"life":0.55,"max":0.55,"color":Color("#5F5569") if rng.randf()<0.7 else Color("#FF7841"),"size":rng.randf_range(3.2,5.5)})
  match enemy.mode:
   "formation_hover":
    var goal: Vector2=enemy.anchor+Vector2(sin(world_time*1.6+enemy.phase)*75.0,cos(world_time*2.1+enemy.phase)*18.0)
    enemy.vel=(goal-enemy.pos)*2.4
    if enemy.vel.length()>enemy.speed*1.4:
     enemy.vel=enemy.vel.normalized()*enemy.speed*1.4
    enemy.pos+=enemy.vel*effective_dt
   "sine_patrol":
    enemy.pos.x+=enemy.dir_x*enemy.speed*0.72*effective_dt
    enemy.pos.y=enemy.base_y+sin(world_time*2.6+enemy.phase)*48.0
    if enemy.pos.x<55:enemy.dir_x=1
    elif enemy.pos.x>viewport_size.x-55:enemy.dir_x=-1
   "strafe_cruiser":
    var gx:=clampf(enemy.anchor.x+sin(world_time*1.1+enemy.phase)*viewport_size.x*0.24,70.0,viewport_size.x-70.0)
    enemy.pos+=(Vector2(gx,enemy.anchor.y)-enemy.pos)*minf(1.0,2.0*effective_dt)
   "swoop_arc":
    var ta:=world_time*1.35+enemy.phase
    var goal2: Vector2=enemy.anchor+Vector2(sin(ta)*110.0,sin(ta*2.0)*55.0)
    enemy.pos+=(goal2-enemy.pos)*minf(1.0,2.2*effective_dt)
   "boss_cruiser":
    var gy:=minf(155.0,viewport_size.y*0.23)
    if enemy.pos.y<gy:enemy.pos.y+=75.0*effective_dt
    else:enemy.pos.x=viewport_size.x*0.5+sin(world_time*0.9)*viewport_size.x*0.30
  var toward:=player-enemy.pos
  if toward.length()>1.0:enemy.aim=toward.angle()
  enemy.shoot_cd-=effective_dt
  if enemy.shoot_cd<=0.0 and enemy.pos.y>20.0:
   var muzzle:Vector2=enemy.pos+Vector2(cos(enemy.aim),sin(enemy.aim))*(enemy.r*0.95)
   _burst(muzzle,ENEMY_TYPES[enemy.kind].color,3,95,0.14,2.2)
   if enemy.kind=="boss":
    enemy.shoot_cd=1.45 if enemy.hp<enemy.max_hp*0.5 else 1.65
    for angle_offset in [-0.36,-0.18,0.0,0.18,0.36]:
     _enemy_shoot(enemy,enemy.aim+angle_offset,225.0,7.0,4.2)
   elif enemy.kind=="gunship":
    enemy.shoot_cd=2.1
    for angle_offset in [-0.16,0.16]:
     _enemy_shoot(enemy,enemy.aim+angle_offset,205.0,6.0,4.0)
   else:
    enemy.shoot_cd=rng.randf_range(2.3,3.6)
    _enemy_shoot(enemy,enemy.aim,190.0,5.0,4.0)
 for bullet in enemy_bullets:
  bullet.pos+=bullet.vel*effective_dt
  bullet.life-=effective_dt
  if player.distance_to(bullet.pos)<bullet.radius+13.0:
   bullet.life=0.0
   if invulnerable<=0.0:
    if shield:
     shield=false
     invulnerable=0.7
     _shockwave(player,CYAN,85)
     _burst(player,CYAN,28,380,0.6)
    else:
     _hurt_player()
 for bullet in bullets:
  if bullet.life<=0.0:continue
  for enemy in enemies:
   if enemy.dead or bullet.hits.has(enemy.uid):continue
   var hit_radius:float=enemy.r+bullet.radius+3.0
   if bullet.pos.distance_squared_to(enemy.pos)<hit_radius*hit_radius:
    bullet.hits.append(enemy.uid)
    enemy.hp-=bullet.damage
    enemy.flash=0.08
    _burst(bullet.pos,bullet.color,4,190,0.25,2.2)
    if bullet.pierce>0:bullet.pierce-=1
    else:bullet.life=0.0
    if enemy.hp<=0.0:_kill_enemy(enemy)
    elif sound_bank!=null:sound_bank.play_sfx("hit")
    if bullet.life<=0.0:break
 for enemy in enemies:
  if enemy.dead or player.distance_to(enemy.pos)>enemy.r+15.0:continue
  if dash_time>0.0:_kill_enemy(enemy)
  elif invulnerable<=0.0:
   if shield:
    shield=false
    invulnerable=0.7
    _shockwave(player,CYAN,85)
    _kill_enemy(enemy)
   else:
    _hurt_player()
    if enemy.kind!="boss":_kill_enemy(enemy,false)
 for item in powerups:
  item.time-=dt
  item.pos+=item.vel*dt
  var toward_player:Vector2=player-item.pos
  var distance:=toward_player.length()
  var magnet_range:=220.0 if magnet_time>0 else 130.0
  if distance<magnet_range and distance>1.0:
   item.pos+=toward_player.normalized()*340.0*dt
   distance=player.distance_to(item.pos)
  if distance<34.0:
   item.time=0.0
   var kind:String=item.kind
   if sound_bank!=null:sound_bank.play_sfx("powerup")
   _popup(player+Vector2(0,-28),POWERUPS[kind].label,POWERUPS[kind].color)
   _shockwave(player,POWERUPS[kind].color,95)
   _burst(player,POWERUPS[kind].color,28,360,0.6)
   powerups_collected+=1
   match kind:
    "shield":shield=true
    "overdrive":overdrive_time=10.0
    "morph":_cycle_unlocked_ship()
    "repair":hp=mini(max_hp,hp+1)
    "nuke":
     flash_time=0.42
     screen_shake=26.0
     for enemy in enemies:
      if not enemy.dead:_kill_enemy(enemy,false)
    "magnet":magnet_time=8.0
    "slow":slow_time=6.0
   _check_achievements()
 for particle in particles:
  particle.pos+=particle.vel*dt
  particle.vel*=pow(0.1,dt)
  particle.life-=dt
 for wave in shockwaves:
  wave.time-=dt
  wave.radius=10.0+(wave.max_radius-10.0)*(1.0-maxf(0.0,wave.time/wave.max))
 for popup in popups:
  popup.time-=dt
  popup.pos.y-=38.0*dt
 bullets=bullets.filter(func(item):return item.life>0 and item.pos.x>-70 and item.pos.x<viewport_size.x+70 and item.pos.y>-70 and item.pos.y<viewport_size.y+70)
 enemy_bullets=enemy_bullets.filter(func(item):return item.life>0 and item.pos.x>-70 and item.pos.x<viewport_size.x+70 and item.pos.y>-70 and item.pos.y<viewport_size.y+70)
 enemies=enemies.filter(func(item):return not item.dead)
 particles=particles.filter(func(item):return item.life>0)
 shockwaves=shockwaves.filter(func(item):return item.time>0)
 popups=popups.filter(func(item):return item.time>0)
 powerups=powerups.filter(func(item):return item.time>0 and item.pos.y<viewport_size.y+50)
 queue_redraw()

func _check_ship_unlocks() -> void:
 var changed := false
 for ship in SHIPS:
  # Original V3.5 unlocks ships by reaching their stage; no credits are spent.
  if not unlocked_ships.has(ship.id) and stage>=ship.stage:
   unlocked_ships.append(ship.id)
   _popup(player,"UNLOCKED: "+ship.name+"!",ship.primary)
   changed=true
 if changed:
  _check_achievements()
 _save()

func _equip_ship(id: String) -> void:
 if unlocked_ships.has(id):
  selected_ship=id
  if sound_bank!=null:sound_bank.play_sfx("morph")
  _shockwave(player,_ship().primary,120)
  _burst(player,_ship().primary,32,360,0.65)
  _popup(player+Vector2(0,-34),"SHIP: "+_ship().name,_ship().primary)
  _save()

func _cycle_unlocked_ship() -> void:
 if unlocked_ships.size()<2:return
 var index:=unlocked_ships.find(selected_ship)
 _equip_ship(unlocked_ships[(index+1)%unlocked_ships.size()])

func _check_achievements() -> void:
 var checks := {
  "first_blood":total_kills>=1,
  "stage_5":stage>=5 or best_stage>=5,
  "stage_10":stage>=10 or best_stage>=10,
  "combo_10":combo>=10,
  "score_10k":score>=10000,
  "score_50k":score>=50000,
  "boss_slayer":bosses_defeated,
  "all_ships":unlocked_ships.size()>=SHIPS.size(),
  "no_damage":perfect_stages>=1,
  "speed_demon":dash_count>=50,
  "survivor":total_playtime>=1800.0,
  "killer":total_kills>=500,
  "collector":powerups_collected>=50,
  "perfectionist":perfect_stages>=5,
  "marathon":total_runs>=20
 }
 for achievement_id in checks:
  if checks[achievement_id] and not achievements.has(achievement_id):
   achievements.append(achievement_id)
   for entry in ACHIEVEMENTS:
    if entry.id==achievement_id:
     if sound_bank!=null:sound_bank.play_sfx("achievement")
     _popup(player,"ACHIEVEMENT: "+entry.name,GOLD)
     credits+=500
     break
 _save()

func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_ESCAPE or event.keycode==KEY_P:
   if state=="play":paused=not paused
   elif state!="menu":state="menu"
  elif event.keycode==KEY_SPACE:dash_requested=true
 if event is InputEventScreenTouch:
  if event.pressed:_pointer_down(event.position,event.index)
  else:_pointer_up(event.index)
 elif event is InputEventScreenDrag and event.index==drag_id:
  if active_slider!="":_update_slider(active_slider,event.position.x)
  else:
   drag_delta+=event.position-last_drag
   last_drag=event.position
 elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
  if event.pressed:_pointer_down(event.position,-2)
  else:_pointer_up(-2)
 elif event is InputEventMouseMotion and mouse_drag:
  if active_slider!="":_update_slider(active_slider,event.position.x)
  else:
   drag_delta+=event.position-last_drag
   last_drag=event.position

func _pointer_down(pos: Vector2,id: int) -> void:
 if state=="play" and tutorial_active:
  tutorial_active=false
  tutorial_done=true
  _save()
  return
 if state=="settings" and ((pos.y>=viewport_size.y*0.80 and pos.y<=viewport_size.y*0.85) or (pos.y>=viewport_size.y*0.90 and pos.y<=viewport_size.y*0.95)):
  active_slider="sfx" if pos.y<viewport_size.y*0.87 else "music"
  slider_pointer_id=id
  drag_id=id
  mouse_drag=id==-2
  _update_slider(active_slider,pos.x)
  return
 if state=="play":
  touch_ripple_pos=pos
  touch_ripple_time=0.25
  var w:=viewport_size.x
  var h:=viewport_size.y
  var mute_rect:=Rect2(w-78,12,66,42)
  var pause_rect:=Rect2(w-154,12,66,42)
  if mute_rect.has_point(pos):
   muted=not muted
   _sync_audio()
   if not muted and not paused and sound_bank!=null:sound_bank.start_music()
   _save()
   return
  if pause_rect.has_point(pos):
   paused=not paused
   return
  if paused:
   if Rect2(w*0.2,h*0.43,w*0.6,58).has_point(pos):
    paused=false
   elif Rect2(w*0.2,h*0.54,w*0.6,58).has_point(pos):
    _start_run()
   elif Rect2(w*0.2,h*0.65,w*0.6,58).has_point(pos):
    paused=false
    state="menu"
    if sound_bank!=null:sound_bank.stop_music()
   return
  if Rect2(w-154,h-102,140,82).has_point(pos):
   dash_requested=true
   return
  # Faithful mobile touch behavior: second finger or a quick double tap triggers dash.
  if id!=-2:
   if drag_id!=-1 and id!=drag_id:
    dash_requested=true
    return
   var now:=Time.get_ticks_msec()
   if now-last_touch_ms<320 and pos.distance_to(last_touch_pos)<120.0:
    dash_requested=true
    last_touch_ms=0
   else:
    last_touch_ms=now
    last_touch_pos=pos
  drag_id=id
  mouse_drag=id==-2
  last_drag=pos
 else:
  _click_ui(pos)

func _pointer_up(id: int) -> void:
 if id==drag_id:drag_id=-1
 if id==slider_pointer_id:
  active_slider=""
  slider_pointer_id=-1
  _save()
 if id==-2:mouse_drag=false

func _update_slider(which: String,x: float) -> void:
 var w:=viewport_size.x
 var value:=clampf((x-w*0.2)/(w*0.6),0.0,1.0)
 if which=="sfx":sfx_volume=value
 else:music_volume=value
 _sync_audio()

func _click_ui(pos: Vector2) -> void:
 if sound_bank!=null:sound_bank.play_sfx("menu_select")
 var w:=viewport_size.x
 var h:=viewport_size.y
 if state=="settings" and pos.y>=h*0.80 and pos.y<=h*0.85:
  sfx_volume=clampf((pos.x-w*0.2)/(w*0.6),0.0,1.0)
  _save()
  return
 if state=="settings" and pos.y>=h*0.90 and pos.y<=h*0.95:
  music_volume=clampf((pos.x-w*0.2)/(w*0.6),0.0,1.0)
  _save()
  return
 if state=="menu":
  if Rect2(w*0.18,h*0.50,w*0.64,h*0.10).has_point(pos):_start_run()
  elif Rect2(w*0.18,h*0.62,w*0.64,h*0.09).has_point(pos):state="hangar"
  elif Rect2(w*0.18,h*0.73,w*0.64,h*0.09).has_point(pos):state="settings"
  elif Rect2(w*0.18,h*0.84,w*0.64,h*0.09).has_point(pos):
   achievements_return_state="menu"
   state="achievements"
 elif state=="hangar":
  if pos.y<h*0.12:state="menu"
  else:
   var columns:=2 if w<650 else 5
   var card_w:=w/columns
   var card_h:=h*0.26
   var top:=h*0.18
   for i in range(SHIPS.size()):
    var row:=i/columns
    var col:=i%columns
    var rect:=Rect2(col*card_w+8,top+row*card_h,card_w-16,card_h-8)
    if rect.has_point(pos):
     var ship:Dictionary=SHIPS[i]
     if unlocked_ships.has(ship.id):
      _equip_ship(ship.id)
     elif stage>=ship.stage:
      unlocked_ships.append(ship.id)
      _equip_ship(ship.id)
      _check_achievements()
      _save()
 elif state=="settings":
  if pos.y<h*0.15:state="menu"
  elif pos.y>=h*0.20 and pos.y<h*0.28:
   achievements_return_state="settings"
   state="achievements"
  elif pos.y<h*0.38:
   var choices: Array[String]=["easy","normal","hard","nightmare"]
   difficulty=choices[clampi(int(pos.x/(w/4.0)),0,3)]
   _save()
  elif pos.y<h*0.55:
   muted=not muted
   _sync_audio()
   if not muted and state=="play" and sound_bank!=null:sound_bank.start_music()
   _save()
  elif pos.y<h*0.72:
   target_fps=60 if target_fps==45 else 45
   Engine.max_fps=target_fps
   _save()
  elif pos.y<h*0.80:
   achievements_return_state="settings"
   state="achievements"
 elif state=="achievements":state=achievements_return_state
 elif state=="over":
  if pos.y>h*0.74:state="menu"
  else:_start_run()
 queue_redraw()

func _draw() -> void:
 var size:=get_viewport_rect().size
 viewport_size=size
 draw_rect(Rect2(Vector2.ZERO,size),BG)
 for i in range(12):
  draw_line(Vector2(size.x*i/12.0,0),Vector2(size.x*i/12.0,size.y),GRID,1)
 for i in range(8):
  draw_line(Vector2(0,size.y*i/8.0),Vector2(size.x,size.y*i/8.0),GRID,1)
 for star in stars:draw_circle(star.pos,1.5,Color(0.5,0.75,1,0.35))
 if touch_ripple_time>0.0:
  var progress:=1.0-touch_ripple_time/0.25
  draw_arc(touch_ripple_pos,12.0+progress*38.0,0,TAU,32,Color(0.43,0.92,1.0,1.0-progress),2.0)
 if state=="play" or state=="over":_draw_game()
 match state:
  "menu":_draw_menu(size)
  "hangar":_draw_hangar(size)
  "settings":_draw_settings(size)
  "achievements":_draw_achievements(size)
  "over":_draw_game_over(size)
 if state=="play":_draw_hud(size)
 if paused:
  _draw_overlay(size,"PAUSED","",CYAN)
  _button(Rect2(size.x*0.2,size.y*0.43,size.x*0.6,58),"RESUME",CYAN)
  _button(Rect2(size.x*0.2,size.y*0.54,size.x*0.6,58),"RESTART",GOLD)
  _button(Rect2(size.x*0.2,size.y*0.65,size.x*0.6,58),"MAIN MENU",PINK)
 if tutorial_active:_draw_overlay(size,"FLIGHT TRAINING","DRAG TO MOVE • TAP DASH TO EVADE",GOLD)
 if flash_time>0:draw_rect(Rect2(Vector2.ZERO,size),Color(1,1,1,flash_time*0.4))

func _draw_game() -> void:
 for trail in trails:draw_circle(trail.pos,8.0*trail.time/trail.max,Color(_ship().primary,0.24*trail.time/trail.max))
 for wave in shockwaves:draw_arc(wave.pos,wave.radius,0,TAU,40,Color(wave.color,wave.time/wave.max),3)
 for bullet in bullets:
  draw_line(bullet.pos,bullet.pos-bullet.dir*18,bullet.color,3)
  draw_circle(bullet.pos,3.5,bullet.color)
 for bullet in enemy_bullets:draw_circle(bullet.pos,bullet.radius,PINK)
 for enemy in enemies:_draw_enemy(enemy)
 for item in powerups:
  var col:Color=POWERUPS[item.kind].color
  draw_circle(item.pos,17,Color(col,0.15))
  draw_arc(item.pos,14,0,TAU,28,col,2)
  _text(POWERUPS[item.kind].symbol,item.pos+Vector2(0,6),18,col)
 for particle in particles:draw_circle(particle.pos,particle.size,Color(particle.color,clampf(particle.life/particle.max,0,1)))
 for popup in popups:_text(popup.text,popup.pos,16,Color(popup.color,popup.time/popup.max))
 _draw_player()

func _draw_player() -> void:
 var cfg:=_ship()
 var r:=float(cfg.size)
 var primary:Color=cfg.primary
 var secondary:Color=cfg.secondary
 var t:=Time.get_ticks_msec()/1000.0
 var thrust:=clampf(velocity.length()/480.0,0.25,1.0)
 var flicker:=1.0+0.22*sin(t*26.0)
 draw_set_transform(player+Vector2(18,24),aim_angle+PI/2,Vector2.ONE)
 # Ground shadow, matching the original's elevated aircraft presentation.
 draw_colored_polygon(PackedVector2Array([Vector2(0,-r*1.25),Vector2(r*0.8,r*0.55),Vector2(0,r*0.75),Vector2(-r*0.8,r*0.55)]),Color(0.01,0.02,0.06,0.38))
 draw_set_transform(player,aim_angle+PI/2+bank*0.14,Vector2.ONE)
 # Twin/triple afterburners with animated inner hot core.
 var engines: Array[float]=[-r*0.28,r*0.28]
 if cfg.id=="titan":engines=[-r*0.38,0.0,r*0.38]
 for side in engines:
  var flame_len:=r*1.15*flicker*thrust*(1.25 if dash_time>0 else 1.0)
  var flame:=PackedVector2Array([Vector2(-r*0.72,side-r*0.14),Vector2(-r*0.72-flame_len,side),Vector2(-r*0.72,side+r*0.14)])
  draw_colored_polygon(flame,primary)
  draw_colored_polygon(PackedVector2Array([Vector2(-r*0.74,side-r*0.07),Vector2(-r*0.74-flame_len*0.52,side),Vector2(-r*0.74,side+r*0.07)]),Color.WHITE)
 # Main airframe silhouette and swept wings.
 var hull:=PackedVector2Array([Vector2(0,-r*1.35),Vector2(r*0.24,-r*0.48),Vector2(r*1.05,r*0.22),Vector2(r*0.86,r*0.52),Vector2(r*0.30,r*0.35),Vector2(0,r*0.78),Vector2(-r*0.30,r*0.35),Vector2(-r*0.86,r*0.52),Vector2(-r*1.05,r*0.22),Vector2(-r*0.24,-r*0.48)])
 draw_colored_polygon(hull,secondary)
 var hull_outline:=hull.duplicate()
 hull_outline.append(hull_outline[0])
 draw_polyline(hull_outline,primary,2.2,true)
 # Distinct hull details by ship class.
 match cfg.id:
  "viper":
   draw_colored_polygon(PackedVector2Array([Vector2(-r*0.2,-r*0.42),Vector2(-r*0.13,r*0.48),Vector2(0,r*0.65),Vector2(r*0.13,r*0.48),Vector2(r*0.2,-r*0.42)]),primary)
   for side in [-1.0,1.0]:
    draw_line(Vector2(side*r*0.62,r*0.25),Vector2(side*r*0.35,r*0.02),Color(0.65,0.95,1),2)
  "interceptor":
   draw_colored_polygon(PackedVector2Array([Vector2(0,-r*1.12),Vector2(r*0.14,r*0.45),Vector2(0,r*0.63),Vector2(-r*0.14,r*0.45)]),primary)
   draw_line(Vector2(-r*0.8,r*0.38),Vector2(-r*0.25,r*0.1),Color.WHITE,2)
   draw_line(Vector2(r*0.8,r*0.38),Vector2(r*0.25,r*0.1),Color.WHITE,2)
  "valkyrie":
   for side in [-1.0,1.0]:
    draw_circle(Vector2(side*r*0.78,r*0.28),r*0.16,secondary)
    draw_arc(Vector2(side*r*0.78,r*0.28),r*0.16,0,TAU,20,primary,2)
   draw_line(Vector2(0,-r*0.55),Vector2(0,r*0.48),Color(0.7,1,0.8),2)
  "phantom":
   draw_line(Vector2(0,-r*0.95),Vector2(0,r*0.62),Color(0.75,0.85,1),3)
   draw_line(Vector2(-r*0.7,r*0.32),Vector2(r*0.7,r*0.32),primary,2)
  "titan":
   for side in [-1.0,0.0,1.0]:
    draw_circle(Vector2(side*r*0.42,-r*0.15),r*0.13,Color(0.2,0.05,0.12))
    draw_circle(Vector2(side*r*0.42,-r*0.15),r*0.08,primary)
 # Canopy, nose emitter and navigation lights.
 draw_colored_polygon(PackedVector2Array([Vector2(0,-r*0.78),Vector2(r*0.17,-r*0.18),Vector2(0,r*0.05),Vector2(-r*0.17,-r*0.18)]),Color(0.72,0.98,1))
 draw_line(Vector2(0,-r*0.72),Vector2(0,-r*0.25),Color.WHITE,1)
 var blink:=1.0 if int(t*1000)%700<180 else 0.35
 draw_circle(Vector2(-r*0.35,-r*1.05),maxf(2.0,r*0.10),Color(1.0,0.22,0.3,blink))
 draw_circle(Vector2(r*0.35,-r*1.05),maxf(2.0,r*0.10),Color(0.25,1.0,0.55,blink))
 draw_set_transform(Vector2.ZERO)
 if shield:
  var shield_r:=r*1.65+2.5*sin(t*9.0)
  draw_arc(player,shield_r,0,TAU,48,CYAN,2)
  draw_arc(player,shield_r+4,0,TAU,48,Color(0.14,0.51,0.71,0.6),1)
 if invulnerable>0 and int(invulnerable*12)%2==0:draw_arc(player,r+7,0,TAU,32,Color(1,1,1,0.65),2)
 if overdrive_time>0:
  draw_arc(player,r+11,0,TAU,40,Color(primary,0.45+0.2*sin(t*8)),2)
 if dash_time>0:draw_line(player,player-dash_direction*45,Color(primary,0.6),r*0.7)

func _draw_enemy(enemy: Dictionary) -> void:
 var spec:Dictionary=ENEMY_TYPES[enemy.kind]
 var col:Color=Color.WHITE if enemy.flash>0 else spec.color
 var r:float=enemy.r
 var t:=Time.get_ticks_msec()/1000.0
 var hp_frac:=clampf(enemy.hp/float(maxi(1,enemy.max_hp)),0.0,1.0)
 var critical:=enemy.kind=="boss" and hp_frac<0.5
 if critical and enemy.flash<=0:col=Color(1.0,0.22,0.30)
 var hull_angle:float=enemy.aim
 if enemy.kind=="gunship":hull_angle=enemy.get("hull_angle",PI/2)
 draw_set_transform(enemy.pos+Vector2(15,20),hull_angle+PI/2,Vector2.ONE)
 draw_colored_polygon(PackedVector2Array([Vector2(0,-r),Vector2(r*0.65,r*0.45),Vector2(0,r*0.65),Vector2(-r*0.65,r*0.45)]),Color(0.01,0.02,0.07,0.42))
 draw_set_transform(enemy.pos,hull_angle+PI/2,Vector2.ONE)
 var flame_len:=r*(0.65+0.22*sin(t*18.0+enemy.uid))
 if enemy.kind=="interceptor":
  for side in [-1.0,1.0]:
   draw_colored_polygon(PackedVector2Array([Vector2(-r*0.62,side*r*0.22-r*0.10),Vector2(-r*0.62-flame_len*1.45,side*r*0.22),Vector2(-r*0.62,side*r*0.22+r*0.10)]),col)
 elif enemy.kind=="boss":
  for side in [-1.0,1.0]:
   draw_colored_polygon(PackedVector2Array([Vector2(-r*0.82,side*r*0.86-r*0.14),Vector2(-r*0.82-flame_len*1.15,side*r*0.86),Vector2(-r*0.82,side*r*0.86+r*0.14)]),col)
 else:
  draw_colored_polygon(PackedVector2Array([Vector2(-r*0.72,-r*0.18),Vector2(-r*0.72-flame_len,0),Vector2(-r*0.72,r*0.18)]),col)
 if enemy.kind=="scout":
  var shape:=PackedVector2Array([Vector2(0,-r),Vector2(r*0.82,-r*0.15),Vector2(r*0.65,r*0.68),Vector2(0,r*0.42),Vector2(-r*0.65,r*0.68),Vector2(-r*0.82,-r*0.15)])
  draw_colored_polygon(shape,Color(0.22,0.07,0.16))
  shape.append(shape[0]);draw_polyline(shape,col,2.5,true)
  draw_circle(Vector2(r*0.24,0),r*0.20,Color(1.0,0.82+0.15*sin(t*11+enemy.uid),0.88))
 elif enemy.kind=="interceptor":
  var shape2:=PackedVector2Array([Vector2(0,-r*1.25),Vector2(r*0.3,-r*0.15),Vector2(r*1.0,r*0.55),Vector2(r*0.5,r*0.35),Vector2(0,r*0.78),Vector2(-r*0.5,r*0.35),Vector2(-r*1.0,r*0.55),Vector2(-r*0.3,-r*0.15)])
  draw_colored_polygon(shape2,Color(0.22,0.16,0.05));shape2.append(shape2[0]);draw_polyline(shape2,col,2.5,true)
  draw_circle(Vector2(0,-r*0.18),r*0.17,Color(1.0,0.9,0.65))
 elif enemy.kind=="gunship":
  var shape3:=PackedVector2Array([Vector2(0,-r),Vector2(r*0.45,-r*0.4),Vector2(r*1.2,r*0.3),Vector2(r*0.8,r*0.8),Vector2(-r*0.8,r*0.8),Vector2(-r*1.2,r*0.3),Vector2(-r*0.45,-r*0.4)])
  draw_colored_polygon(shape3,Color(0.12,0.16,0.32));shape3.append(shape3[0]);draw_polyline(shape3,col,3,true)
  for side in [-1.0,1.0]:
   var mount:=Vector2(r*0.10,side*r*0.58)
   draw_circle(mount,r*0.22,Color(0.11,0.06,0.18))
   draw_arc(mount,r*0.22,0,TAU,24,col,2)
   var track:Vector2=(player-enemy.pos).normalized()
   draw_line(mount,mount+track*r*0.52,Color.WHITE,3)
 elif enemy.kind=="boss":
  var shape4:=PackedVector2Array([Vector2(0,-r*1.5),Vector2(r*0.45,-r*0.45),Vector2(r*1.25,r*0.6),Vector2(r*0.7,r*0.9),Vector2(0,r*0.5),Vector2(-r*0.7,r*0.9),Vector2(-r*1.25,r*0.6),Vector2(-r*0.45,-r*0.45)])
  draw_colored_polygon(shape4,Color(0.18,0.06,0.16));shape4.append(shape4[0]);draw_polyline(shape4,col,4,true)
  var rot:=enemy.rot*(1.8 if critical else 1.0)
  var core:=PackedVector2Array()
  for i in range(6):core.append(Vector2(cos(rot+i*TAU/6),sin(rot+i*TAU/6))*r*0.38)
  core.append(core[0]);draw_polyline(core,Color(1.0,0.43,0.43) if critical else Color(1.0,0.76,0.92),2.5,true)
  draw_circle(Vector2.ZERO,r*0.13,Color.WHITE)
  var track2:Vector2=(player-enemy.pos).normalized()
  for side in [-1.0,1.0]:
   var mount2:=Vector2(r*0.08,side*r*0.56)
   draw_arc(mount2,r*0.14,0,TAU,20,col,2)
   draw_line(mount2,mount2+track2*r*0.36,Color.WHITE,3)
 draw_set_transform(Vector2.ZERO)
 # Boss health ring, gunship health bar only after damage.
 if enemy.kind=="boss":
  draw_arc(enemy.pos,r+18,-PI/2,-PI/2+TAU*maxf(0.03,hp_frac),64,col,4)
 elif enemy.kind=="gunship" and enemy.hp<enemy.max_hp:
  var bw:=r*1.6
  draw_rect(Rect2(enemy.pos.x-bw/2,enemy.pos.y-r-12,bw,4),Color(0.16,0.08,0.22))
  draw_rect(Rect2(enemy.pos.x-bw/2,enemy.pos.y-r-12,bw*hp_frac,4),col)
func _draw_hud(size: Vector2) -> void:
 var portrait:=size.y>size.x
 if portrait:
  _text("%d" % score,Vector2(18,34),23,Color.WHITE,false)
  _text(_ship().name,Vector2(18,58),13,_ship().primary,false)
  for i in range(max_hp):
   var col:=PINK if i<hp else Color("#373750")
   draw_colored_polygon(PackedVector2Array([Vector2(22+i*25,72),Vector2(31+i*25,82),Vector2(22+i*25,92),Vector2(13+i*25,82)]),col)
  _text("STAGE %d • WAVE %d/%d" % [stage,subwave,total_subwaves],Vector2(size.x*0.5,122),16,GOLD)
  var bar_w:=minf(260.0,size.x*0.68)
  var bar_x:=size.x*0.5-bar_w*0.5
  draw_rect(Rect2(bar_x,139,bar_w,8),Color("#252D4A"))
  var segment:=bar_w/float(maxi(1,total_subwaves))
  for sw in range(subwave):draw_rect(Rect2(bar_x+sw*segment+2,141,maxf(2.0,segment-4),4),GOLD)
  _text("CREDITS %d" % credits,Vector2(18,size.y-142),14,GOLD,false)
 else:
  _text("SCORE %d" % score,Vector2(18,32),21,Color.WHITE,false)
  _text("%s • CR %d" % [_ship().name,credits],Vector2(18,56),13,_ship().primary,false)
  for i in range(max_hp):
   var col:=PINK if i<hp else Color("#373750")
   draw_colored_polygon(PackedVector2Array([Vector2(24+i*27,68),Vector2(33+i*27,78),Vector2(24+i*27,88),Vector2(15+i*27,78)]),col)
  _text("STAGE %d • WAVE %d/%d" % [stage,subwave,total_subwaves],Vector2(size.x*0.5,32),17,GOLD)
  var bar_w:=minf(320.0,size.x*0.34)
  var bar_x:=size.x*0.5-bar_w*0.5
  draw_rect(Rect2(bar_x,50,bar_w,7),Color("#252D4A"))
  var segment:=bar_w/float(maxi(1,total_subwaves))
  for sw in range(subwave):draw_rect(Rect2(bar_x+sw*segment+2,52,maxf(2.0,segment-4),3),GOLD)
 var status_y:=size.y-136 if portrait else size.y-112
 if shield:_text("AEGIS SHIELD",Vector2(18,status_y),13,CYAN,false);status_y+=22
 if overdrive_time>0:_text("OVERDRIVE %.1fs" % overdrive_time,Vector2(18,status_y),13,GREEN,false);status_y+=22
 if magnet_time>0:_text("MAGNET %.1fs" % magnet_time,Vector2(18,status_y),13,Color("#FFFF64"),false);status_y+=22
 if slow_time>0:_text("TIME DILATION %.1fs" % slow_time,Vector2(18,status_y),13,Color("#B4C8FF"),false)
 _text("COMBO x%d" % combo,Vector2(size.x*0.5,size.y-24),16,GOLD)
 _button(Rect2(size.x-154,12,66,42),"II" if not paused else "GO",GOLD if paused else CYAN)
 _button(Rect2(size.x-78,12,66,42),"MUTE" if muted else "AUDIO",PINK if muted else CYAN)
 _button(Rect2(size.x-154,size.y-102,140,82),"DASH" if dash_cooldown<=0 else "%.1fs" % dash_cooldown,CYAN if dash_cooldown<=0 else Color("#69718E"))
 if banner_time>0:
  _text(banner_title,Vector2(size.x*0.5,size.y*0.34 if portrait else size.y*0.20),34,CYAN)
  _text(banner_subtitle,Vector2(size.x*0.5,size.y*0.40 if portrait else size.y*0.26),18,GOLD)
 if tutorial_active:_text("DRAG TO MOVE • DOUBLE TAP TO DASH",Vector2(size.x*0.5,size.y*0.9),18,GOLD)

func _draw_menu(size: Vector2) -> void:
 _text("NEON",Vector2(size.x*0.5,size.y*0.22),70,CYAN)
 _text("SURVIVOR",Vector2(size.x*0.5,size.y*0.31),42,Color.WHITE)
 _text("V3.5 • PERFORMANCE + MOBILE UI",Vector2(size.x*0.5,size.y*0.39),16,PURPLE)
 _text("BEST SCORE %d • BEST STAGE %d" % [high_score,best_stage],Vector2(size.x*0.5,size.y*0.45),16,GOLD)
 _button(Rect2(size.x*0.18,size.y*0.50,size.x*0.64,size.y*0.10),"START MISSION",CYAN)
 _button(Rect2(size.x*0.18,size.y*0.62,size.x*0.64,size.y*0.09),"HANGAR • %d CREDITS" % credits,GOLD)
 _button(Rect2(size.x*0.18,size.y*0.73,size.x*0.64,size.y*0.09),"SETTINGS",PURPLE)
 _button(Rect2(size.x*0.18,size.y*0.84,size.x*0.64,size.y*0.09),"ACHIEVEMENTS",GREEN)

func _draw_hangar(size: Vector2) -> void:
 _text("FLEET HANGAR",Vector2(size.x*0.5,size.y*0.10),36,CYAN)
 _button(Rect2(12,12,130,48),"BACK",GOLD)
 var columns:=2 if size.x<650 else 5
 var card_width:=size.x/columns
 var card_height:=size.y*0.26
 var top:=size.y*0.18
 for i in range(SHIPS.size()):
  var ship:Dictionary=SHIPS[i]
  var row:=i/columns
  var col:=i%columns
  var rect:=Rect2(col*card_width+8,top+row*card_height,card_width-16,card_height-8)
  var unlocked:=unlocked_ships.has(ship.id)
  draw_rect(rect,Color(0.06,0.09,0.17,0.96))
  draw_rect(rect,Color(ship.primary,0.6),false,2)
  _text(ship.name,Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+28),16,ship.primary)
  _text(ship.role,Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+52),11,Color.WHITE)
  _draw_ship_icon(Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+rect.size.y*0.48),ship.primary,int(ship.size))
  _text(ship.ability,Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+rect.size.y*0.73),10,GOLD)
  _text("UNLOCKED" if unlocked else "%d CR • STAGE %d" % [ship.cost,ship.stage],Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+rect.size.y*0.88),13,GREEN if unlocked else PINK)

func _draw_ship_icon(pos: Vector2,color: Color,r: int) -> void:
 draw_colored_polygon(PackedVector2Array([pos+Vector2(0,-r),pos+Vector2(r*0.65,r*0.6),pos+Vector2(0,r*0.25),pos+Vector2(-r*0.65,r*0.6)]),color)
 draw_circle(pos+Vector2(0,-r*0.2),r*0.2,CYAN)

func _draw_settings(size: Vector2) -> void:
 _text("SYSTEM SETTINGS",Vector2(size.x*0.5,size.y*0.16),38,CYAN)
 _button(Rect2(12,12,130,48),"BACK",GOLD)
 _text("DIFFICULTY",Vector2(size.x*0.5,size.y*0.30),22,Color.WHITE)
 _button(Rect2(size.x*0.18,size.y*0.22,size.x*0.64,size.y*0.055),"ACHIEVEMENTS %d/%d • KILLS %d" % [achievements.size(),ACHIEVEMENTS.size(),total_kills],GOLD)
 var ids:Array[String]=["easy","normal","hard","nightmare"]
 for i in range(4):
  var rect:=Rect2(i*size.x/4+5,size.y*0.34,size.x/4-10,56)
  var col:=CYAN if ids[i]==difficulty else PURPLE
  draw_rect(rect,Color(col,0.2))
  draw_rect(rect,col,false,2)
  _text(DIFFICULTIES[ids[i]].label,Vector2(rect.position.x+rect.size.x/2,rect.position.y+35),14,Color.WHITE)
 _button(Rect2(size.x*0.18,size.y*0.52,size.x*0.64,62),"SOUND: "+("MUTED" if muted else "ON"),CYAN)
 _button(Rect2(size.x*0.18,size.y*0.64,size.x*0.64,62),"FRAME RATE: %d FPS" % target_fps,GOLD)
 _text("SFX VOLUME",Vector2(size.x*0.5,size.y*0.79),16,Color.WHITE)
 draw_rect(Rect2(size.x*0.2,size.y*0.82,size.x*0.6,8),Color("#25324D"))
 draw_rect(Rect2(size.x*0.2,size.y*0.82,size.x*0.6*sfx_volume,8),CYAN)
 _text("MUSIC VOLUME",Vector2(size.x*0.5,size.y*0.89),16,Color.WHITE)
 draw_rect(Rect2(size.x*0.2,size.y*0.92,size.x*0.6,8),Color("#25324D"))
 draw_rect(Rect2(size.x*0.2,size.y*0.92,size.x*0.6*music_volume,8),PURPLE)

func _draw_achievements(size: Vector2) -> void:
 _text("ACHIEVEMENTS",Vector2(size.x*0.5,size.y*0.10),36,GOLD)
 _button(Rect2(12,12,130,48),"BACK",CYAN)
 for i in range(ACHIEVEMENTS.size()):
  var entry:Dictionary=ACHIEVEMENTS[i]
  var row_h:=size.y*0.052
  var y:=size.y*0.17+i*row_h
  var unlocked:=achievements.has(entry.id)
  draw_rect(Rect2(size.x*0.08,y,size.x*0.84,row_h-3),Color(0.08,0.1,0.18,0.95))
  _text(entry.name.to_upper(),Vector2(size.x*0.32,y+row_h*0.68),13,GOLD if unlocked else Color("#66718A"))
  _text(entry.desc,Vector2(size.x*0.68,y+row_h*0.68),11,Color.WHITE if unlocked else Color("#66718A"))

func _draw_game_over(size: Vector2) -> void:
 _draw_overlay(size,"MISSION FAILED","SCORE %d • RECORD %d" % [score,high_score],PINK)
 _button(Rect2(size.x*0.2,size.y*0.65,size.x*0.6,66),"RETRY",CYAN)
 _button(Rect2(size.x*0.2,size.y*0.76,size.x*0.6,60),"MAIN MENU",GOLD)

func _draw_overlay(size: Vector2,title: String,subtitle: String,color: Color) -> void:
 draw_rect(Rect2(Vector2.ZERO,size),Color(0,0,0,0.72))
 _text(title,Vector2(size.x*0.5,size.y*0.45),42,color)
 _text(subtitle,Vector2(size.x*0.5,size.y*0.55),18,Color.WHITE)

func _button(rect: Rect2,label: String,color: Color) -> void:
 draw_rect(rect,Color(0.06,0.1,0.19,0.95))
 draw_rect(rect,color,false,2)
 _text(label,rect.position+Vector2(rect.size.x*0.5,rect.size.y*0.62),18,color)

func _text(value: String,pos: Vector2,size: int,color: Color,centered: bool=true) -> void:
 var font:=ThemeDB.fallback_font
 var width:=font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
 draw_string(font,Vector2(pos.x-width*0.5 if centered else pos.x,pos.y),value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

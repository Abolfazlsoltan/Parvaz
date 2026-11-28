extends Node2D
# Parvaz 1.2 — mobile-first campaign update.
# Ported from NeonSurvivor_V3.5_Performance_UI.py. Keep gameplay data in sync with source.

const BG := Color("#080B18")
const GRID := Color("#141A32")
const CYAN := Color("#41E8FF")
const PINK := Color("#FF477E")
const GOLD := Color("#FFD166")
const PURPLE := Color("#B36BFF")
const GREEN := Color("#65F59A")
const SAVE_PATH := "user://neon_v3_save.json"
const CAMPAIGN_STAGE_COUNT := 8
const STAGE_TILE_COUNT := 12
const SOUND_BANK_SCRIPT = preload("res://scripts/sound_bank.gd")

const SHIPS := [
 {"id":"viper","name":"VIPER MK-I","role":"Balanced Twin-Cannon","stage":1,"cost":0,"primary":Color8(100,240,255),"secondary":Color8(35,95,145),"bullet":Color8(140,250,255),"size":25,"hp":4,"rate":0.11,"speed":1020.0,"damage":1.0,"dash":0.95,"pattern":"twin","ability":"Fast Twin Plasma"},
 {"id":"interceptor","name":"SOLAR FALCON","role":"3-Way Spread & Quick Dash","stage":2,"cost":1500,"primary":Color8(255,215,70),"secondary":Color8(135,85,20),"bullet":Color8(255,235,110),"size":26,"hp":4,"rate":0.13,"speed":1060.0,"damage":0.95,"dash":0.65,"pattern":"spread3","ability":"35% Faster Dash Cooldown"},
 {"id":"valkyrie","name":"VALKYRIE X","role":"Homing Missiles + Laser","stage":4,"cost":4000,"primary":Color8(110,255,145),"secondary":Color8(25,115,65),"bullet":Color8(130,255,165),"size":28,"hp":5,"rate":0.14,"speed":980.0,"damage":1.15,"dash":0.90,"pattern":"homing","ability":"Auto-Homing Wing Missiles"},
 {"id":"phantom","name":"VOID PHANTOM","role":"Piercing Rail-Beams","stage":6,"cost":8000,"primary":Color8(140,180,255),"secondary":Color8(40,70,140),"bullet":Color8(180,210,255),"size":27,"hp":4,"rate":0.17,"speed":1280.0,"damage":1.85,"dash":0.75,"pattern":"pierce","ability":"Shots Pierce Through Enemies"},
 {"id":"titan","name":"AEGIS TITAN","role":"5-Cannon Heavy Cruiser","stage":8,"cost":14000,"primary":Color8(255,95,135),"secondary":Color8(135,28,55),"bullet":Color8(255,135,165),"size":31,"hp":6,"rate":0.16,"speed":960.0,"damage":1.35,"dash":1.05,"pattern":"heavy5","ability":"Heavy Armor + 5-Gun Barrage"},
 {"id":"raptor","name":"RAPTOR X","role":"Rapid Smart-Volley Fighter","stage":3,"cost":2600,"primary":Color8(255,150,75),"secondary":Color8(120,55,24),"bullet":Color8(255,185,110),"size":25,"hp":4,"rate":0.10,"speed":1180.0,"damage":1.08,"dash":0.72,"pattern":"volley","ability":"Three-Lane Burst Fire"},
 {"id":"nova","name":"NOVA WARDEN","role":"Armored Pulse Interceptor","stage":5,"cost":5600,"primary":Color8(220,125,255),"secondary":Color8(85,38,125),"bullet":Color8(235,170,255),"size":29,"hp":6,"rate":0.18,"speed":960.0,"damage":1.55,"dash":0.98,"pattern":"pierce","ability":"High-Damage Piercing Pulse"},
 {"id":"oracle","name":"ORACLE-7","role":"Autonomous Seeker Fighter","stage":7,"cost":10200,"primary":Color8(100,255,220),"secondary":Color8(20,105,100),"bullet":Color8(125,255,230),"size":27,"hp":5,"rate":0.13,"speed":1100.0,"damage":1.2,"dash":0.82,"pattern":"smart","ability":"Dual Homing Smart Missiles"}
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
const POWERUPS := {"shield":{"color":Color8(65,230,255),"symbol":"S","label":"AEGIS SHIELD"},"overdrive":{"color":Color8(95,255,130),"symbol":"W","label":"WEAPON OVERDRIVE"},"morph":{"color":Color8(255,185,60),"symbol":"X","label":"SHIP MORPH CORE"},"repair":{"color":Color8(255,95,130),"symbol":"+","label":"HULL REPAIR"},"nuke":{"color":Color.WHITE,"symbol":"N","label":"EMP NOVA"},"magnet":{"color":Color8(255,255,100),"symbol":"M","label":"MAGNET PULSE"},"slow":{"color":Color8(180,200,255),"symbol":"T","label":"TIME DILATION"},"targeting":{"color":Color8(115,255,190),"symbol":"A","label":"SMART TARGETING"},"wingman":{"color":Color8(190,145,255),"symbol":"W","label":"WINGMAN ESCORT"}}

var rng := RandomNumberGenerator.new()
var sound_bank: Node
var ui_layer: CanvasLayer
var ui_root: Control
var ui_theme: Theme
var ui_signature := ""
var dash_ui_button: Button
var language := "fa"
var viewport_size := Vector2(540,960)
var background_gradient: GradientTexture2D
var state := "menu"
var achievements_return_state := "menu"
var paused := false
var difficulty := "normal"
var selected_ship := "viper"
var unlocked_ships: Array[String] = ["viper"]
var credits := 0
var high_score := 0
var best_stage := 1
var max_unlocked_stage := 1
var selected_stage := 1
var campaign_complete := false
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
var bank := 0.0
var muzzle_flash_time := 0.0
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
var targeting_time := 0.0
var wingman_time := 0.0
var wingman_fire_cd := 0.0
var victory_fly_time := 0.0
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
var nebula_layers: Array[Dictionary] = []
var background_structures: Array[Dictionary] = []
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
var screen_shake_offset := Vector2.ZERO
var uid := 0

func _ready() -> void:
 rng.randomize()
 sound_bank=SOUND_BANK_SCRIPT.new()
 add_child(sound_bank)
 viewport_size = get_viewport_rect().size
 _load_save()
 _setup_ui()
 Engine.max_fps=target_fps
 _sync_audio()
 _create_stars()
 _build_background_gradient()
 _reset_run()
 get_viewport().size_changed.connect(_resize)
 _refresh_ui(true)
 queue_redraw()

func _notification(what: int) -> void:
 # Flush progress when Android suspends the app or the window is closed.
 if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
  _save()

func _resize() -> void:
 var old_size := viewport_size
 viewport_size = get_viewport_rect().size
 if old_size.x > 0.0 and old_size.y > 0.0:
  var scale_factor := viewport_size / old_size
  # Preserve the space scene when Android changes between portrait and landscape.
  for star in stars:
   star.pos *= scale_factor
  for layer in nebula_layers:
   layer.pos *= scale_factor
  for structure in background_structures:
   structure.pos *= scale_factor
  player *= scale_factor
  previous_player = player
  drag_delta *= scale_factor
  var margin := float(_ship().size + 6)
  player.x = clampf(player.x, margin, viewport_size.x - margin)
  player.y = clampf(player.y, margin + 40.0, viewport_size.y - margin)
 queue_redraw()

func _build_background_gradient() -> void:
 var gradient:=Gradient.new()
 gradient.colors=PackedColorArray([Color(0.035,0.063,0.145),Color(0.012,0.019,0.055)])
 gradient.offsets=PackedFloat32Array([0.0,1.0])
 background_gradient=GradientTexture2D.new()
 background_gradient.gradient=gradient
 background_gradient.width=1
 background_gradient.height=256
 background_gradient.fill_from=Vector2(0,0)
 background_gradient.fill_to=Vector2(0,1)

func _create_stars() -> void:
 stars.clear()
 nebula_layers.clear()
 background_structures.clear()
 for i in range(55):
  var star_size:=rng.randf_range(0.35,1.0)
  stars.append({"pos":Vector2(rng.randf_range(0,viewport_size.x),rng.randf_range(0,viewport_size.y)),"speed":star_size,"size":star_size})
 var nebula_colors:Array[Color]=[Color("#122044"),Color("#24143A"),Color("#0E2C40")]
 for i in range(3):
  nebula_layers.append({"pos":Vector2(rng.randf_range(0,viewport_size.x),rng.randf_range(0,viewport_size.y)),"radius":rng.randf_range(60.0,130.0),"color":nebula_colors[i],"speed":rng.randf_range(8.0,16.0)})
 for i in range(2):
  background_structures.append({"pos":Vector2(rng.randf_range(40,viewport_size.x-40),rng.randf_range(40,viewport_size.y-40)),"size":rng.randf_range(40.0,85.0)})

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
 language = str(data.get("language","fa"))
 if language not in ["fa","en"]:language="fa"
 max_unlocked_stage = clampi(int(data.get("max_unlocked_stage",mini(best_stage,CAMPAIGN_STAGE_COUNT))),1,CAMPAIGN_STAGE_COUNT)
 selected_stage = clampi(int(data.get("selected_stage",1)),1,max_unlocked_stage)
 campaign_complete = data.get("campaign_complete",false) == true
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
 var data := {"hi":high_score,"best_stage":best_stage,"language":language,"max_unlocked_stage":max_unlocked_stage,"selected_stage":selected_stage,"campaign_complete":campaign_complete,"target_fps":target_fps,"credits":credits,"unlocked_ships":unlocked_ships,"selected_ship":selected_ship,"muted":muted,"sfx_volume":sfx_volume,"music_volume":music_volume,"difficulty":difficulty,"tutorial_done":tutorial_done,"achievements":achievements,"total_kills":total_kills,"total_runs":total_runs,"total_playtime":total_playtime,"bosses_defeated":bosses_defeated}
 # Atomic-style temp save, mirroring the Python game's write-then-replace persistence.
 var temp_path:=SAVE_PATH+".tmp"
 var file:=FileAccess.open(temp_path,FileAccess.WRITE)
 if file==null:return
 file.store_string(JSON.stringify(data))
 file.flush()
 file.close()
 var temp_absolute:=ProjectSettings.globalize_path(temp_path)
 var save_absolute:=ProjectSettings.globalize_path(SAVE_PATH)
 var err:=DirAccess.rename_absolute(temp_absolute,save_absolute)
 if err!=OK:
  if FileAccess.file_exists(SAVE_PATH):DirAccess.remove_absolute(save_absolute)
  DirAccess.rename_absolute(temp_absolute,save_absolute)

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
 targeting_time = 0.0
 wingman_time = 0.0
 wingman_fire_cd = 0.0
 victory_fly_time = 0.0
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

func _start_run(requested_stage: int = -1) -> void:
 _reset_run()
 selected_stage = clampi(requested_stage if requested_stage > 0 else selected_stage,1,max_unlocked_stage)
 state = "play"
 total_runs += 1
 tutorial_active = not tutorial_done
 _start_stage(selected_stage)
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
 if language=="fa":
  if title.begins_with("STAGE "):banner_title="مرحلهٔ "+_fa_number(int(title.trim_prefix("STAGE ")))
  if subtitle.begins_with("SUB-WAVE "):
   var wave_text:=subtitle.trim_prefix("SUB-WAVE ").split(" / ")
   banner_subtitle="موج "+_fa_number(int(wave_text[0]))+" از "+_fa_number(int(wave_text[1]))
  elif subtitle=="BOSS SQUADRON!":banner_subtitle="گروه فرماندهی دشمن"
 banner_time = 2.1

func _spawn_subwave() -> void:
 var hp_scale: float = (1.0 + (stage-1)*0.14) * DIFFICULTIES[difficulty].hp
 var w: float = viewport_size.x
 var h: float = viewport_size.y
 if subwave == 1:
  var count := mini(9,5+floori(float(stage)/2.0))
  for i in range(count):
   var offset := i-floori(float(count)/2.0)
   var x := w*0.5+offset*minf(75.0,w*0.085)
   _create_enemy("scout",Vector2(x,-40-abs(offset)*34),"formation_hover",Vector2(x,h*0.22+abs(offset)*24),1,h*0.22,i*0.5,hp_scale,rng.randf_range(1.6,3.0))
 elif subwave == 2:
  var per_side := mini(5,3+floori(float(stage)/3.0))
  for side in [-1,1]:
   for i in range(per_side):
    var x: float = -45-i*55 if side == -1 else w+45+i*55
    var y: float = h*(0.18+i*0.07)
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
   var cleared_stage := stage
   max_unlocked_stage = clampi(maxi(max_unlocked_stage,cleared_stage+1),1,CAMPAIGN_STAGE_COUNT)
   if cleared_stage >= CAMPAIGN_STAGE_COUNT:
    campaign_complete = true
   best_stage = maxi(best_stage,cleared_stage)
   selected_stage = cleared_stage
   victory_fly_time = 0.0
   state = "stage_clear"
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
  kind = "shield" if roll<0.16 else "overdrive" if roll<0.30 else "targeting" if roll<0.43 else "wingman" if roll<0.55 else "morph" if roll<0.68 else "repair" if roll<0.80 else "nuke" if roll<0.87 else "magnet" if roll<0.95 else "slow"
 if powerups.size() >= 5:
  powerups.pop_front()
 powerups.append({"pos":pos,"vel":Vector2(0,58),"kind":kind,"time":11.0})

func _popup(pos: Vector2,text: String,color: Color=GOLD) -> void:
 var shown_text:=text
 if language=="fa":
  if text.begins_with("UNLOCKED: "):shown_text="جنگندهٔ جدید: "+text.trim_prefix("UNLOCKED: ")
  elif text.begins_with("ACHIEVEMENT: "):shown_text="دستاورد: "+text.trim_prefix("ACHIEVEMENT: ")
 popups.append({"pos":pos,"text":shown_text,"color":color,"time":0.85,"max":0.85})

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
  credits += floori(float(score)/15.0)
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
 credits += maxi(2,floori(float(points)/25.0))
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
 bullets.append({"pos":pos,"vel":dir*cfg.speed,"dir":dir,"speed":cfg.speed,"life":1.35,"color":cfg.bullet,"damage":damage,"pierce":pierce,"homing":homing or targeting_time>0.0,"radius":radius,"hits":[]})

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
 elif pattern == "volley":
  for angle in ([-0.20,0.0,0.20] if overdrive_time<=0 else [-0.34,-0.17,0.0,0.17,0.34]):
   _add_player_bullet(player+aim*23,aim.rotated(angle),0,false,4.5)
 elif pattern == "smart":
  sfx="shoot_plasma"
  _add_player_bullet(player+aim*25,aim,0,true,5.5)
  for angle in [-0.30,0.30]:
   _add_player_bullet(player+aim*18+perpendicular*angle*22,aim.rotated(angle),0,true,4)
 if sound_bank!=null:sound_bank.play_sfx(sfx)
 muzzle_flash_time=0.045
 fire_cooldown = cfg.rate*(0.76 if overdrive_time>0 else 1.0)

func _enemy_shoot(enemy: Dictionary,angle: float,speed: float,radius: float,life: float) -> void:
 if enemy_bullets.size() < 28:
  enemy_bullets.append({"pos":enemy.pos,"vel":Vector2(cos(angle),sin(angle))*speed,"life":life,"radius":radius})

func _process(delta: float) -> void:
 _refresh_ui()
 if is_instance_valid(dash_ui_button):
  dash_ui_button.text=_loc("شتاب\nآماده" if dash_cooldown<=0.01 else "شارژ\n%s" % _fa_decimal(dash_cooldown),"DASH\nREADY" if dash_cooldown<=0.01 else "RECHARGE\n%.1fs" % dash_cooldown)
 var dt := minf(delta,0.033)
 touch_ripple_time=maxf(0.0,touch_ripple_time-dt)
 for star in stars:
  star.pos.y = fposmod(star.pos.y+22.0*star.speed*dt,viewport_size.y)
 if state=="stage_clear":
  victory_fly_time += dt
  if victory_fly_time < 0.95:
   player.y -= maxf(760.0,viewport_size.y*1.8)*dt
   aim_angle = -PI/2
   if rng.randf()<0.35:_burst(player,_ship().primary,2,85,0.22,3.0)
  queue_redraw()
  return
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
 var keyboard:=Vector2(int(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT))-int(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),int(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))-int(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)))
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
 var target: Variant = _nearest_enemy()
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
 flash_time=maxf(0.0,flash_time-dt)
 screen_shake=maxf(0.0,screen_shake-44.0*dt)
 fire_cooldown-=dt
 if fire_cooldown<=0.0:
  _fire_weapons()
 targeting_time=maxf(0.0,targeting_time-dt)
 wingman_time=maxf(0.0,wingman_time-dt)
 if wingman_time>0.0:
  wingman_fire_cd-=dt
  if wingman_fire_cd<=0.0:
   var escort_target: Variant = _nearest_enemy()
   if escort_target!=null:
    var escort_pos := player+Vector2(-46.0,20.0+sin(world_time*3.8)*10.0)
    var escort_direction: Vector2 = (escort_target.pos-escort_pos).normalized()
    _add_player_bullet(escort_pos+escort_direction*10.0,escort_direction,0,true,3.2)
    wingman_fire_cd=0.38
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
    var ta: float = world_time*1.35+enemy.phase
    var goal2: Vector2=enemy.anchor+Vector2(sin(ta)*110.0,sin(ta*2.0)*55.0)
    enemy.pos+=(goal2-enemy.pos)*minf(1.0,2.2*effective_dt)
   "boss_cruiser":
    var gy:=minf(155.0,viewport_size.y*0.23)
    if enemy.pos.y<gy:enemy.pos.y+=75.0*effective_dt
    else:enemy.pos.x=viewport_size.x*0.5+sin(world_time*0.9)*viewport_size.x*0.30
  var toward: Vector2 = player-enemy.pos
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
    if sound_bank!=null:sound_bank.play_sfx("powerup")
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
   _popup(player+Vector2(0,-28),_powerup_label(kind),POWERUPS[kind].color)
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
    "targeting":targeting_time=12.0
    "wingman":
     wingman_time=16.0
     wingman_fire_cd=0.0
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
 if particles.size()>80:particles=particles.slice(particles.size()-80)
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
  var old_cfg:=_ship()
  selected_ship=id
  if state=="play":
   var new_cfg:=_ship()
   var hp_diff:=int(new_cfg.hp)-int(old_cfg.hp)
   max_hp=int(new_cfg.hp)
   hp=maxi(1,mini(max_hp,hp+maxi(0,hp_diff)))
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

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_ESCAPE or event.keycode==KEY_BACK:
   if state=="play":
    paused=not paused
   elif state!="menu":
    state="menu"
    paused=false
   _refresh_ui(true)
   return
  if event.keycode==KEY_SPACE and state=="play" and not paused and not tutorial_active:
   dash_requested=true
   return
 if state!="play" or paused or tutorial_active:
  return
 if OS.has_feature("android"):
  if event is InputEventScreenTouch:
   if event.pressed:
    _game_touch_down(event.position,event.index,event.double_tap)
   else:
    _game_touch_up(event.index)
  elif event is InputEventScreenDrag and event.index==drag_id:
   drag_delta+=event.position-last_drag
   last_drag=event.position
 else:
  if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
   if event.pressed:
    _game_touch_down(event.position,-2,false)
   else:
    _game_touch_up(-2)
  elif event is InputEventMouseMotion and mouse_drag:
   drag_delta+=event.position-last_drag
   last_drag=event.position

func _game_touch_down(pos: Vector2,id: int,double_tap: bool=false) -> void:
 if id!=-2 and double_tap:
  dash_requested=true
  return
 if drag_id!=-1 and drag_id!=id:
  return
 touch_ripple_pos=pos
 touch_ripple_time=0.18
 drag_id=id
 mouse_drag=id==-2
 last_drag=pos

func _game_touch_up(id: int) -> void:
 if drag_id==id:drag_id=-1
 if id==-2:mouse_drag=false


func _loc(fa_text: String,en_text: String) -> String:
 return fa_text if language=="fa" else en_text

func _fa_number(value: Variant) -> String:
 var result:=str(value)
 var western:="0123456789"
 var persian:="۰۱۲۳۴۵۶۷۸۹"
 for i in range(10):
  result=result.replace(western.substr(i,1),persian.substr(i,1))
 return result

func _fa_decimal(value: float) -> String:
 return _fa_number("%.1f" % value).replace(".", "٫")

func _powerup_label(kind: String) -> String:
 var labels:Dictionary={
  "shield":["سپر محافظ","AEGIS SHIELD"],
  "overdrive":["افزایش قدرت شلیک","WEAPON OVERDRIVE"],
  "morph":["تغییر جنگنده","SHIP MORPH CORE"],
  "repair":["تعمیر بدنه","HULL REPAIR"],
  "nuke":["موج الکترومغناطیسی","EMP NOVA"],
  "magnet":["جذب جایزه‌ها","MAGNET PULSE"],
  "slow":["کندسازی زمان","TIME DILATION"],
  "targeting":["هدف‌گیری هوشمند","SMART TARGETING"],
  "wingman":["جنگندهٔ کمکی","WINGMAN ESCORT"]
 }
 if not labels.has(kind):return kind
 return labels[kind][0] if language=="fa" else labels[kind][1]

func _setup_ui() -> void:
 ui_layer=CanvasLayer.new()
 ui_layer.layer=20
 add_child(ui_layer)
 ui_root=Control.new()
 ui_root.name="MobileUI"
 ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 ui_root.mouse_filter=Control.MOUSE_FILTER_IGNORE
 ui_layer.add_child(ui_root)
 ui_theme=Theme.new()
 ui_theme.default_font=ThemeDB.fallback_font
 ui_theme.default_font_size=22
 ui_root.theme=ui_theme
 _set_ui_direction()

func _set_ui_direction() -> void:
 if not is_instance_valid(ui_root):return
 ui_root.layout_direction=Control.LAYOUT_DIRECTION_RTL if language=="fa" else Control.LAYOUT_DIRECTION_LTR
 ui_root.text_direction=Control.TEXT_DIRECTION_RTL if language=="fa" else Control.TEXT_DIRECTION_LTR

func _ui_signature() -> String:
 return "%s|%s|%s|%s|%s" % [state,str(paused),str(tutorial_active),language,str(victory_fly_time>=0.90)]

func _refresh_ui(force: bool=false) -> void:
 if not is_instance_valid(ui_root):return
 var signature:=_ui_signature()
 if not force and signature==ui_signature:return
 ui_signature=signature
 for child in ui_root.get_children():
  ui_root.remove_child(child)
  child.queue_free()
 dash_ui_button=null
 _set_ui_direction()
 match state:
  "menu":_build_menu_ui()
  "stages":_build_stages_ui()
  "hangar":_build_hangar_ui()
  "settings":_build_settings_ui()
  "help":_build_help_ui()
  "achievements":_build_achievements_ui()
  "over":_build_game_over_ui()
  "stage_clear":
   if victory_fly_time>=0.90:_build_stage_clear_ui()
  "play":
   _build_game_controls_ui()
   if paused:_build_pause_overlay_ui()
   elif tutorial_active:_build_tutorial_overlay_ui()

func _ui_style(accent: Color=Color("#2B78A8"),background: Color=Color("#10233D"),radius: int=18) -> StyleBoxFlat:
 var style:=StyleBoxFlat.new()
 style.bg_color=background
 style.border_color=accent
 style.set_border_width_all(2)
 style.set_corner_radius_all(radius)
 style.content_margin_left=16
 style.content_margin_right=16
 style.content_margin_top=12
 style.content_margin_bottom=12
 return style

func _ui_button(parent: Control,label_text: String,accent: Color=CYAN,height: float=68,action: Callable=Callable(),disabled: bool=false) -> Button:
 var button:=Button.new()
 button.text=label_text
 button.custom_minimum_size=Vector2(0,height)
 button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button.focus_mode=Control.FOCUS_NONE
 button.disabled=disabled
 button.clip_text=false
 button.add_theme_font_size_override("font_size",21)
 button.add_theme_color_override("font_color",Color("#F4F7FF"))
 button.add_theme_color_override("font_hover_color",Color.WHITE)
 button.add_theme_color_override("font_pressed_color",Color.WHITE)
 button.add_theme_color_override("font_disabled_color",Color("#77839A"))
 button.add_theme_stylebox_override("normal",_ui_style(accent,Color("#142844")))
 button.add_theme_stylebox_override("hover",_ui_style(accent.lightened(0.14),Color("#203B5D")))
 button.add_theme_stylebox_override("pressed",_ui_style(accent.darkened(0.14),Color("#0A172C")))
 button.add_theme_stylebox_override("disabled",_ui_style(Color("#3D4658"),Color("#121A29")))
 button.add_theme_stylebox_override("focus",_ui_style(accent,Color("#142844")))
 parent.add_child(button)
 if action.is_valid():
  button.pressed.connect(action)
 return button

func _ui_label(parent: Control,label_text: String,font_size: int=21,color: Color=Color("#ECF4FF"),centered: bool=false) -> Label:
 var label:=Label.new()
 label.text=label_text
 label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER if centered else (HORIZONTAL_ALIGNMENT_RIGHT if language=="fa" else HORIZONTAL_ALIGNMENT_LEFT)
 label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 label.text_direction=Control.TEXT_DIRECTION_AUTO
 label.add_theme_font_size_override("font_size",font_size)
 label.add_theme_color_override("font_color",color)
 label.add_theme_color_override("font_shadow_color",Color(0,0,0,0.45))
 label.add_theme_constant_override("shadow_offset_x",1)
 label.add_theme_constant_override("shadow_offset_y",1)
 parent.add_child(label)
 return label

func _ui_card(parent: Control,accent: Color=Color("#31577D")) -> VBoxContainer:
 var panel:=PanelContainer.new()
 panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 panel.add_theme_stylebox_override("panel",_ui_style(accent,Color("#10223B"),18))
 parent.add_child(panel)
 var margins:=MarginContainer.new()
 margins.add_theme_constant_override("margin_left",10)
 margins.add_theme_constant_override("margin_right",10)
 margins.add_theme_constant_override("margin_top",8)
 margins.add_theme_constant_override("margin_bottom",8)
 panel.add_child(margins)
 var body:=VBoxContainer.new()
 body.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 body.add_theme_constant_override("separation",8)
 margins.add_child(body)
 return body

func _ui_screen(title: String,subtitle: String="",show_back: bool=true) -> VBoxContainer:
 var shade:=ColorRect.new()
 shade.color=Color(0.015,0.025,0.055,0.88)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 ui_root.add_child(shade)
 var margins:=MarginContainer.new()
 margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 margins.add_theme_constant_override("margin_left",14)
 margins.add_theme_constant_override("margin_right",14)
 margins.add_theme_constant_override("margin_top",16)
 margins.add_theme_constant_override("margin_bottom",16)
 ui_root.add_child(margins)
 var outer:=PanelContainer.new()
 outer.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 outer.size_flags_vertical=Control.SIZE_EXPAND_FILL
 outer.add_theme_stylebox_override("panel",_ui_style(Color("#285C88"),Color("#08162B"),24))
 margins.add_child(outer)
 var scroll:=ScrollContainer.new()
 scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
 scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_AUTO
 outer.add_child(scroll)
 var inner:=MarginContainer.new()
 inner.add_theme_constant_override("margin_left",12)
 inner.add_theme_constant_override("margin_right",12)
 inner.add_theme_constant_override("margin_top",12)
 inner.add_theme_constant_override("margin_bottom",12)
 inner.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 scroll.add_child(inner)
 var content:=VBoxContainer.new()
 content.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 content.add_theme_constant_override("separation",14)
 inner.add_child(content)
 if show_back:
  _ui_button(content,_loc("‹  بازگشت","‹  BACK"),Color("#6486AA"),58,Callable(self,"_ui_back"))
 _ui_label(content,title,34,CYAN,true)
 if subtitle!="":_ui_label(content,subtitle,18,Color("#AFC5E3"),true)
 return content

func _ui_back() -> void:
 if state=="achievements":state=achievements_return_state
 else:state="menu"
 paused=false
 _refresh_ui(true)
 queue_redraw()

func _build_menu_ui() -> void:
 var content:=_ui_screen("پرواز","نبرد هوایی  •  کمپین مرحله‌ای",false)
 _ui_label(content,_loc("جنگندهٔ فعال: ","ACTIVE FIGHTER: ")+str(_ship().name),18,_ship().primary,true)
 var summary:=_ui_card(content,GOLD)
 _ui_label(summary,_loc("پیشرفت کمپین","CAMPAIGN PROGRESS"),19,GOLD,true)
 _ui_label(summary,_loc("%s از ۸ مرحله باز است" % _fa_number(max_unlocked_stage),"%d of 8 missions unlocked" % max_unlocked_stage),23,Color.WHITE,true)
 _ui_label(summary,_loc("رکورد: %s   اعتبار: %s" % [_fa_number(high_score),_fa_number(credits)],"RECORD: %d   CREDITS: %d" % [high_score,credits]),17,Color("#C5D6EB"),true)
 _ui_button(content,_loc("انتخاب مرحله و شروع","CAMPAIGN / PLAY"),GREEN,78,Callable(self,"_ui_open_stages"))
 _ui_button(content,_loc("آشیانهٔ هواپیماها","AIRCRAFT HANGAR"),GOLD,72,Callable(self,"_ui_open_hangar"))
 _ui_button(content,_loc("تنظیمات","SETTINGS"),CYAN,72,Callable(self,"_ui_open_settings"))
 _ui_button(content,_loc("آموزش و راهنما","FLIGHT SCHOOL"),PURPLE,72,Callable(self,"_ui_open_help"))
 _ui_button(content,_loc("دستاوردها","ACHIEVEMENTS"),Color("#91A2FF"),72,Callable(self,"_ui_open_achievements"))
 _ui_label(content,_loc("برای حرکت، صفحه را بکشید؛ شلیک خودکار است.","DRAG TO STEER • WEAPONS FIRE AUTOMATICALLY"),16,Color("#94A8C8"),true)

func _ui_open_stages() -> void:
 state="stages"
 _refresh_ui(true)

func _ui_open_hangar() -> void:
 state="hangar"
 _refresh_ui(true)

func _ui_open_settings() -> void:
 state="settings"
 _refresh_ui(true)

func _ui_open_help() -> void:
 state="help"
 _refresh_ui(true)

func _ui_open_achievements() -> void:
 achievements_return_state="menu"
 state="achievements"
 _refresh_ui(true)

func _ui_start_stage(number: int) -> void:
 if number<=max_unlocked_stage and number<=CAMPAIGN_STAGE_COUNT:
  selected_stage=number
  _start_run(number)
  _refresh_ui(true)

func _build_stages_ui() -> void:
 var content:=_ui_screen(_loc("انتخاب مرحله","MISSION SELECT"),_loc("با تکمیل هر مرحله، مرحلهٔ بعدی باز می‌شود.","COMPLETE A MISSION TO UNLOCK THE NEXT."))
 var progress:=_ui_card(content,GOLD)
 _ui_label(progress,_loc("%s از ۸ مرحله باز شده" % _fa_number(max_unlocked_stage),"%d / 8 MISSIONS UNLOCKED" % max_unlocked_stage),20,GOLD,true)
 var grid:=GridContainer.new()
 grid.columns=2 if viewport_size.y>=viewport_size.x else 4
 grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 grid.add_theme_constant_override("h_separation",10)
 grid.add_theme_constant_override("v_separation",10)
 content.add_child(grid)
 for i in range(STAGE_TILE_COUNT):
  var number:=i+1
  var available:=number<=CAMPAIGN_STAGE_COUNT and number<=max_unlocked_stage
  var complete:=number<max_unlocked_stage or (number==CAMPAIGN_STAGE_COUNT and campaign_complete)
  var label:=_loc("مرحلهٔ %s" % _fa_number(number),"MISSION %02d" % number)
  if complete:label+="\n"+_loc("تکمیل‌شده","CLEARED")
  elif available:label+="\n"+_loc("آمادهٔ پرواز","READY")
  elif number<=CAMPAIGN_STAGE_COUNT:label+="\n"+_loc("قفل","LOCKED")
  else:label+="\n"+_loc("در به‌روزرسانی آینده","COMING SOON")
  var accent:=GREEN if complete else (CYAN if available else Color("#59657B"))
  _ui_button(grid,label,accent,118,Callable(self,"_ui_start_stage").bind(number),not available)

func _ui_select_ship(id: String) -> void:
 if unlocked_ships.has(id):
  _equip_ship(id)
 _save()
 _refresh_ui(true)

func _ship_description(id: String) -> String:
 var descriptions:Dictionary={
  "viper":["شلیک دوتایی متعادل","Balanced twin fire"],
  "interceptor":["شلیک سه‌جهته و شتاب سریع","Three-way spread and quick dash"],
  "valkyrie":["موشک‌های خودهدایت‌شونده","Homing missiles"],
  "phantom":["شلیک نفوذکننده","Piercing shots"],
  "titan":["زره سنگین و شلیک پنج‌گانه","Heavy armor and five-way fire"],
  "raptor":["شلیک سه‌مسیرهٔ سریع","Fast three-lane volley"],
  "nova":["پالس پرقدرت نفوذکننده","High-power piercing pulse"],
  "oracle":["موشک‌های جست‌وجوگر","Autonomous seeker missiles"]
 }
 if not descriptions.has(id):return ""
 return descriptions[id][0] if language=="fa" else descriptions[id][1]

func _build_hangar_ui() -> void:
 var content:=_ui_screen(_loc("آشیانهٔ هواپیماها","AIRCRAFT HANGAR"),_loc("برای انتخاب جنگنده، کارت آن را لمس کنید.","TAP AN AIRCRAFT CARD TO EQUIP IT."))
 var balance:=_ui_card(content,GOLD)
 _ui_label(balance,_loc("اعتبار: %s" % _fa_number(credits),"CREDITS: %d" % credits),20,GOLD,true)
 var grid:=GridContainer.new()
 grid.columns=2 if viewport_size.y>=viewport_size.x else 4
 grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 grid.add_theme_constant_override("h_separation",10)
 grid.add_theme_constant_override("v_separation",10)
 content.add_child(grid)
 for ship in SHIPS:
  var unlocked:=unlocked_ships.has(ship.id)
  var selected:=selected_ship==ship.id
  var status:=_loc("انتخاب شده","EQUIPPED") if selected else (_loc("در دسترس","UNLOCKED") if unlocked else _loc("پس از مرحلهٔ %s" % _fa_number(ship.stage),"UNLOCK AT MISSION %d" % ship.stage))
  var caption:=str(ship.name)+"\n"+_loc("زره %s  •  قدرت %s٪" % [_fa_number(ship.hp),_fa_number(int(ship.damage*100))],"ARMOR %d  •  DAMAGE %d%%" % [ship.hp,int(ship.damage*100)])+"\n"+_ship_description(str(ship.id))+"\n"+status
  _ui_button(grid,caption,ship.primary if unlocked else Color("#65738A"),154,Callable(self,"_ui_select_ship").bind(str(ship.id)),not unlocked)

func _ui_set_language(value: String) -> void:
 language=value if value in ["fa","en"] else "fa"
 _save()
 _refresh_ui(true)

func _ui_toggle_mute() -> void:
 muted=not muted
 _sync_audio()
 if not muted and state=="play" and not paused and sound_bank!=null:sound_bank.start_music()
 _save()
 _refresh_ui(true)

func _ui_set_sfx(value: float) -> void:
 sfx_volume=clampf(value,0.0,1.0)
 _sync_audio()

func _ui_set_music(value: float) -> void:
 music_volume=clampf(value,0.0,1.0)
 _sync_audio()

func _ui_set_difficulty(value: String) -> void:
 if DIFFICULTIES.has(value):
  difficulty=value
  _save()
  _refresh_ui(true)

func _ui_set_fps(value: int) -> void:
 target_fps=60 if value>=60 else 45
 Engine.max_fps=target_fps
 _save()
 _refresh_ui(true)

func _ui_add_slider(parent: Control,title: String,value: float,callback: Callable) -> void:
 _ui_label(parent,title,18,Color("#DCE8F8"))
 var slider:=HSlider.new()
 slider.min_value=0.0
 slider.max_value=1.0
 slider.step=0.05
 slider.value=value
 slider.custom_minimum_size=Vector2(0,48)
 slider.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 slider.focus_mode=Control.FOCUS_NONE
 slider.add_theme_color_override("grabber_color",CYAN)
 slider.add_theme_color_override("grabber_highlight_color",Color.WHITE)
 parent.add_child(slider)
 slider.value_changed.connect(callback)

func _build_settings_ui() -> void:
 var content:=_ui_screen(_loc("تنظیمات","SETTINGS"),_loc("زبان، صدا و تجربهٔ بازی را تنظیم کنید.","LANGUAGE, AUDIO AND GAMEPLAY OPTIONS."))
 var language_card:=_ui_card(content,CYAN)
 _ui_label(language_card,_loc("زبان بازی","GAME LANGUAGE"),20,Color.WHITE)
 var language_row:=HBoxContainer.new()
 language_row.add_theme_constant_override("separation",10)
 language_card.add_child(language_row)
 _ui_button(language_row,"فارسی"+(" ✓" if language=="fa" else ""),CYAN,62,Callable(self,"_ui_set_language").bind("fa"))
 _ui_button(language_row,"English"+(" ✓" if language=="en" else ""),PURPLE,62,Callable(self,"_ui_set_language").bind("en"))
 var audio_card:=_ui_card(content,GREEN)
 _ui_label(audio_card,_loc("صدا","AUDIO"),20,Color.WHITE)
 _ui_button(audio_card,_loc("صدا: روشن","SOUND: ON") if not muted else _loc("صدا: خاموش","SOUND: OFF"),GREEN if not muted else PINK,64,Callable(self,"_ui_toggle_mute"))
 _ui_add_slider(audio_card,_loc("صدای افکت‌ها","SOUND EFFECTS"),sfx_volume,Callable(self,"_ui_set_sfx"))
 _ui_add_slider(audio_card,_loc("صدای موسیقی","MUSIC VOLUME"),music_volume,Callable(self,"_ui_set_music"))
 var gameplay:=_ui_card(content,PURPLE)
 _ui_label(gameplay,_loc("گیم‌پلی","GAMEPLAY"),20,Color.WHITE)
 _ui_label(gameplay,_loc("درجهٔ سختی","DIFFICULTY"),18,Color("#C7D9EE"))
 var diff_grid:=GridContainer.new()
 diff_grid.columns=2
 diff_grid.add_theme_constant_override("h_separation",8)
 diff_grid.add_theme_constant_override("v_separation",8)
 gameplay.add_child(diff_grid)
 var diff_ids:Array[String]=["easy","normal","hard","nightmare"]
 var diff_fa:Array[String]=["آسان","معمولی","سخت","کابوس"]
 for i in range(diff_ids.size()):
  var label:=diff_fa[i] if language=="fa" else DIFFICULTIES[diff_ids[i]].label
  if difficulty==diff_ids[i]:label+=" ✓"
  _ui_button(diff_grid,label,CYAN if difficulty==diff_ids[i] else PURPLE,60,Callable(self,"_ui_set_difficulty").bind(diff_ids[i]))
 _ui_label(gameplay,_loc("نرخ فریم","FRAME RATE"),18,Color("#C7D9EE"))
 var fps_row:=HBoxContainer.new()
 fps_row.add_theme_constant_override("separation",8)
 gameplay.add_child(fps_row)
 _ui_button(fps_row,"45 FPS"+(" ✓" if target_fps==45 else ""),GOLD,60,Callable(self,"_ui_set_fps").bind(45))
 _ui_button(fps_row,"60 FPS"+(" ✓" if target_fps==60 else ""),GOLD,60,Callable(self,"_ui_set_fps").bind(60))
 var stats:=_ui_card(content,Color("#58718F"))
 _ui_label(stats,_loc("آمار بازی","GAME STATISTICS"),19,Color.WHITE)
 _ui_label(stats,_loc("انهدام‌ها: %s  •  زمان بازی: %s دقیقه  •  اجراها: %s" % [_fa_number(total_kills),_fa_number(int(total_playtime/60.0)),_fa_number(total_runs)],"KILLS: %d  •  PLAYTIME: %d MIN  •  RUNS: %d" % [total_kills,int(total_playtime/60.0),total_runs]),17,Color("#B8C9DE"))

func _build_help_ui() -> void:
 var content:=_ui_screen(_loc("آموزش پرواز","FLIGHT SCHOOL"),_loc("راهنمای کنترل و قابلیت‌ها","CONTROLS AND ABILITIES."))
 var items:Array=[
  [_loc("حرکت","MOVEMENT"),_loc("انگشت خود را روی میدان بازی بکشید تا جنگنده حرکت کند.","DRAG ON THE BATTLEFIELD TO STEER.")],
  [_loc("شلیک","FIRE"),_loc("شلیک خودکار است و جنگنده نزدیک‌ترین دشمن را هدف می‌گیرد.","YOUR AIRCRAFT FIRES AUTOMATICALLY AND TRACKS THE NEAREST TARGET.")],
  [_loc("شتاب","DASH"),_loc("دکمهٔ گرد شتاب را لمس کنید تا جنگنده سریع حرکت کند.","TAP THE ROUND DASH BUTTON TO BURST FORWARD.")],
  [_loc("جایزه‌ها","POWER CORES"),_loc("هسته‌های جایزه، سپر، تعمیر و قابلیت‌های موقت می‌دهند.","COLLECT CORES FOR SHIELDS, REPAIRS AND TEMPORARY POWERS.")],
  [_loc("هدف‌گیری هوشمند","SMART TARGETING"),_loc("برای مدتی شلیک‌ها مسیر خود را به سمت هدف اصلاح می‌کنند.","PROJECTILES HOME TOWARD TARGETS FOR A SHORT TIME.")],
  [_loc("جنگندهٔ کمکی","WINGMAN"),_loc("یک جنگندهٔ کوچک کنار شما پرواز می‌کند و خودکار پشتیبانی می‌کند.","A SMALL SUPPORT FIGHTER JOINS AND ATTACKS AUTOMATICALLY.")],
  [_loc("کمپین","CAMPAIGN"),_loc("مرحلهٔ فعلی را تمام کنید تا مرحلهٔ بعدی باز شود. پیشرفت ذخیره می‌شود.","COMPLETE A MISSION TO UNLOCK THE NEXT. PROGRESS IS SAVED.")]
 ]
 for item in items:
  var card:=_ui_card(content,Color("#345C83"))
  _ui_label(card,item[0],19,GOLD)
  _ui_label(card,item[1],17,Color("#D3E0F2"))

func _achievement_fa(id: String) -> Array:
 var names:Dictionary={
  "first_blood":["اولین پیروزی","اولین دشمن را شکست بده"],
  "stage_5":["خلبان باتجربه","به مرحلهٔ پنجم برس"],
  "stage_10":["تک‌خال حرفه‌ای","به مرحلهٔ دهم برس"],
  "combo_10":["استاد زنجیره","به زنجیرهٔ ۱۰تایی برس"],
  "score_10k":["امتیاز بالا","۱۰ هزار امتیاز بگیر"],
  "score_50k":["افسانه","۵۰ هزار امتیاز بگیر"],
  "boss_slayer":["شکارچی غول","فرماندهٔ دشمن را شکست بده"],
  "all_ships":["فرماندهٔ ناوگان","همهٔ جنگنده‌ها را باز کن"],
  "no_damage":["بی‌خراش","یک مرحله را بدون آسیب تمام کن"],
  "speed_demon":["شتاب‌گیر","۵۰ بار شتاب بگیر"],
  "survivor":["بازمانده","۳۰ دقیقه بازی کن"],
  "killer":["ویرانگر","۵۰۰ دشمن را شکست بده"],
  "collector":["جمع‌آورنده","۵۰ جایزه جمع کن"],
  "perfectionist":["کمال‌گرا","۵ مرحله را با سلامت کامل تمام کن"],
  "marathon":["ماراتن","۲۰ بار بازی را اجرا کن"]
 }
 if names.has(id):return names[id]
 return ["",""]

func _build_achievements_ui() -> void:
 var content:=_ui_screen(_loc("دستاوردها","ACHIEVEMENTS"),_loc("چالش‌ها را کامل کنید و اعتبار بگیرید.","COMPLETE CHALLENGES TO EARN CREDITS."))
 var summary:=_ui_card(content,GOLD)
 _ui_label(summary,_loc("%s از %s دستاورد باز شده" % [_fa_number(achievements.size()),_fa_number(ACHIEVEMENTS.size())],"%d / %d UNLOCKED" % [achievements.size(),ACHIEVEMENTS.size()]),20,GOLD,true)
 for entry in ACHIEVEMENTS:
  var title:=str(entry.name)
  var description:=str(entry.desc)
  if language=="fa":
   var fa:=_achievement_fa(str(entry.id))
   title=fa[0]
   description=fa[1]
  var card:=_ui_card(content,GREEN if achievements.has(entry.id) else Color("#53617A"))
  _ui_label(card,title,19,GOLD if achievements.has(entry.id) else Color("#9AA7BB"))
  _ui_label(card,description,16,Color("#CBD8EA"))

func _build_game_controls_ui() -> void:
 var pause_button:=_ui_button(ui_root,"Ⅱ",GOLD,68,Callable(self,"_ui_toggle_pause"))
 pause_button.name="PauseButton"
 pause_button.position=Vector2(viewport_size.x-86.0,18.0)
 pause_button.size=Vector2(68.0,68.0)
 pause_button.custom_minimum_size=Vector2(68.0,68.0)
 pause_button.add_theme_font_size_override("font_size",26)
 dash_ui_button=_ui_button(ui_root,_loc("شتاب\nآماده","DASH\nREADY"),CYAN,112,Callable(self,"_ui_request_dash"))
 dash_ui_button.name="DashButton"
 dash_ui_button.position=Vector2(viewport_size.x-142.0,viewport_size.y-158.0)
 dash_ui_button.size=Vector2(122.0,122.0)
 dash_ui_button.custom_minimum_size=Vector2(122.0,122.0)
 dash_ui_button.add_theme_font_size_override("font_size",20)
 dash_ui_button.add_theme_stylebox_override("normal",_ui_style(CYAN,Color("#0D2741"),64))
 dash_ui_button.add_theme_stylebox_override("hover",_ui_style(Color.WHITE,Color("#16405D"),64))
 dash_ui_button.add_theme_stylebox_override("pressed",_ui_style(GOLD,Color("#09172B"),64))

func _ui_request_dash() -> void:
 if state=="play" and not paused and dash_cooldown<=0.0:
  dash_requested=true

func _ui_toggle_pause() -> void:
 if state=="play":
  paused=not paused
  if paused and sound_bank!=null:sound_bank.stop_music()
  elif not paused and not muted and sound_bank!=null:sound_bank.start_music()
  _refresh_ui(true)

func _ui_center_modal(title: String,subtitle: String) -> VBoxContainer:
 var shade:=ColorRect.new()
 shade.color=Color(0.0,0.008,0.025,0.82)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 shade.mouse_filter=Control.MOUSE_FILTER_STOP
 ui_root.add_child(shade)
 var center:=CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 center.mouse_filter=Control.MOUSE_FILTER_IGNORE
 ui_root.add_child(center)
 var panel:=PanelContainer.new()
 panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 panel.custom_minimum_size=Vector2(viewport_size.x*0.84,0)
 panel.add_theme_stylebox_override("panel",_ui_style(CYAN,Color("#0C1B33"),24))
 center.add_child(panel)
 var margins:=MarginContainer.new()
 margins.add_theme_constant_override("margin_left",16)
 margins.add_theme_constant_override("margin_right",16)
 margins.add_theme_constant_override("margin_top",16)
 margins.add_theme_constant_override("margin_bottom",16)
 panel.add_child(margins)
 var body:=VBoxContainer.new()
 body.add_theme_constant_override("separation",14)
 margins.add_child(body)
 _ui_label(body,title,30,CYAN,true)
 _ui_label(body,subtitle,18,Color("#D4E1F1"),true)
 return body

func _build_tutorial_overlay_ui() -> void:
 var body:=_ui_center_modal(_loc("آموزش کوتاه","QUICK TUTORIAL"),_loc("برای حرکت، صفحه را بکشید. شلیک خودکار است. برای شتاب از دکمهٔ گرد پایین استفاده کنید.","DRAG TO STEER. FIRE IS AUTOMATIC. TAP THE ROUND DASH BUTTON TO BURST FORWARD."))
 _ui_button(body,_loc("شروع بازی","LET'S FLY"),GREEN,72,Callable(self,"_ui_finish_tutorial"))

func _ui_finish_tutorial() -> void:
 tutorial_active=false
 tutorial_done=true
 _save()
 _refresh_ui(true)

func _build_pause_overlay_ui() -> void:
 var body:=_ui_center_modal(_loc("بازی متوقف شد","PAUSED"),_loc("می‌خواهید چه کار کنید؟","WHAT WOULD YOU LIKE TO DO?"))
 _ui_button(body,_loc("ادامهٔ بازی","RESUME"),GREEN,72,Callable(self,"_ui_toggle_pause"))
 _ui_button(body,_loc("شروع دوبارهٔ مرحله","RESTART MISSION"),GOLD,72,Callable(self,"_ui_restart_stage"))
 _ui_button(body,_loc("تنظیمات صدا و بازی","AUDIO AND GAME SETTINGS"),CYAN,72,Callable(self,"_ui_open_settings_from_pause"))
 _ui_button(body,_loc("بازگشت به منو","MAIN MENU"),PINK,72,Callable(self,"_ui_exit_to_menu"))

func _ui_open_settings_from_pause() -> void:
 paused=false
 state="settings"
 _refresh_ui(true)

func _ui_restart_stage() -> void:
 _start_run(stage)
 _refresh_ui(true)

func _ui_exit_to_menu() -> void:
 paused=false
 state="menu"
 if sound_bank!=null:sound_bank.stop_music()
 _refresh_ui(true)

func _ui_next_stage() -> void:
 if stage<CAMPAIGN_STAGE_COUNT:
  _start_run(stage+1)
 else:
  state="stages"
  _refresh_ui(true)

func _build_game_over_ui() -> void:
 var body:=_ui_center_modal(_loc("مأموریت ناموفق","MISSION FAILED"),_loc("امتیاز: %s   رکورد: %s" % [_fa_number(score),_fa_number(high_score)],"SCORE: %d   RECORD: %d" % [score,high_score]))
 _ui_button(body,_loc("تلاش دوباره","RETRY MISSION"),CYAN,72,Callable(self,"_ui_restart_stage"))
 _ui_button(body,_loc("بازگشت به منو","MAIN MENU"),GOLD,68,Callable(self,"_ui_exit_to_menu"))

func _build_stage_clear_ui() -> void:
 var body:=_ui_center_modal(_loc("مرحله با موفقیت تمام شد","MISSION CLEARED"),_loc("مرحلهٔ %s با موفقیت تکمیل شد." % _fa_number(stage),"MISSION %02d SECURED." % stage))
 _ui_label(body,_loc("امتیاز: %s   اعتبار: %s" % [_fa_number(score),_fa_number(credits)],"SCORE: %d   CREDITS: %d" % [score,credits]),18,GOLD,true)
 if stage<CAMPAIGN_STAGE_COUNT:
  _ui_label(body,_loc("مرحلهٔ بعدی باز شد!","NEXT MISSION UNLOCKED!"),19,GREEN,true)
  _ui_button(body,_loc("مرحلهٔ بعدی","NEXT MISSION"),GREEN,72,Callable(self,"_ui_next_stage"))
 _ui_button(body,_loc("انتخاب مرحله","MISSION SELECT"),CYAN,68,Callable(self,"_ui_open_stages"))
 _ui_button(body,_loc("منوی اصلی","MAIN MENU"),GOLD,68,Callable(self,"_ui_exit_to_menu"))

func _draw() -> void:
 var size:=get_viewport_rect().size
 if size.x<2.0 or size.y<2.0:size=Vector2(540,960)
 viewport_size=size
 draw_rect(Rect2(Vector2.ZERO,size),BG)
 if background_gradient!=null:
  draw_texture_rect(background_gradient,Rect2(Vector2.ZERO,size),false)
 for layer in nebula_layers:
  draw_set_transform(layer.pos,0,Vector2(layer.radius,layer.radius*0.35))
  draw_arc(Vector2.ZERO,1.0,0,TAU,56,Color(layer.color,0.18),2.0)
  draw_arc(Vector2.ZERO,0.72,0,TAU,48,Color(layer.color,0.10),2.0)
  draw_set_transform(Vector2.ZERO)
 for structure in background_structures:
  var p:Vector2=structure.pos
  var side:float=structure.size
  var rect:=Rect2(p.x-side*0.5,p.y-side*0.35,side,side*0.7)
  draw_rect(rect,Color(0.02,0.035,0.075,0.45),false,1)
  draw_line(rect.position,rect.position+rect.size,Color(0.02,0.035,0.075,0.55),1)
 var grid_step:=66.0
 for x in range(0,ceili(size.x/grid_step)+1):
  var gx:=x*grid_step
  draw_line(Vector2(gx,0),Vector2(gx,size.y),Color("#0D111F"),1)
 for y in range(0,ceili(size.y/grid_step)+1):
  var gy:=y*grid_step
  draw_line(Vector2(0,gy),Vector2(size.x,gy),Color("#0D111F"),1)
 for star in stars:
  var brightness:float=0.33+0.57*star.size
  draw_circle(star.pos,maxf(1.0,star.size*1.5),Color(brightness,brightness,minf(1.0,brightness+0.06),0.78))
 if state=="play" or state=="over" or state=="stage_clear":
  screen_shake_offset=Vector2(rng.randf_range(-screen_shake,screen_shake),rng.randf_range(-screen_shake,screen_shake)) if screen_shake>0.1 else Vector2.ZERO
  draw_set_transform(screen_shake_offset,0,Vector2.ONE)
  _draw_game()
  draw_set_transform(Vector2.ZERO)
 if state=="play":_draw_hud(size)
 if flash_time>0.0:draw_rect(Rect2(Vector2.ZERO,size),Color(1,1,1,flash_time*0.4))


func _stage_tile_rect(index: int,size: Vector2) -> Rect2:
 var portrait := size.y > size.x
 var columns := 3 if portrait else 4
 var gap := 10.0
 var total_width := size.x*0.90
 var tile_width := (total_width-gap*(columns-1))/columns
 var tile_height := clampf(size.y*0.14,62.0,124.0)
 var row := floori(float(index)/float(columns))
 var col := index%columns
 var x0 := (size.x-total_width)*0.5
 return Rect2(x0+col*(tile_width+gap),size.y*0.22+row*(tile_height+gap),tile_width,tile_height)

func _dash_button_center(size: Vector2) -> Vector2:
 return Vector2(size.x-66.0,size.y-70.0)

func _draw_dash_button(size: Vector2) -> void:
 var center := _dash_button_center(size)
 var ready := dash_cooldown <= 0.01
 var ratio := clampf(1.0-dash_cooldown/maxf(0.1,_ship().dash),0.0,1.0)
 var accent := CYAN if ready else Color("#7886A8")
 draw_circle(center,39.0,Color(0.015,0.045,0.10,0.96))
 draw_arc(center,35.0,0.0,TAU,48,Color("#263A58"),5.0)
 draw_arc(center,35.0,-PI/2.0,-PI/2.0+TAU*ratio,48,accent,5.0)
 draw_arc(center,28.0,0.0,TAU,40,Color(accent,0.22),1.5)
 _text("DASH" if ready else "%.1f" % dash_cooldown,center+Vector2(0,5),15,Color.WHITE if ready else accent)
 _text("READY" if ready else "RECHARGE",center+Vector2(0,20),8,accent)

func _draw_wingman() -> void:
 if wingman_time <= 0.0:
  return
 var pos := player+Vector2(-46.0,20.0+sin(world_time*3.8)*10.0)
 var r := float(_ship().size)*0.56
 var accent := Color("#C6A2FF")
 draw_circle(pos+screen_shake_offset,r*1.35,Color(accent,0.10))
 draw_set_transform(pos+screen_shake_offset,aim_angle+PI/2.0,Vector2.ONE)
 var shape := PackedVector2Array([Vector2(0,-r*1.25),Vector2(r*0.26,-r*0.22),Vector2(r*0.82,r*0.52),Vector2(0,r*0.40),Vector2(-r*0.82,r*0.52),Vector2(-r*0.26,-r*0.22)])
 draw_colored_polygon(shape,Color("#382954"))
 shape.append(shape[0])
 draw_polyline(shape,accent,2.0,true)
 draw_colored_polygon(PackedVector2Array([Vector2(0,-r*0.68),Vector2(r*0.12,-r*0.10),Vector2(0,r*0.12),Vector2(-r*0.12,-r*0.10)]),Color("#E9DEFF"))
 draw_set_transform(screen_shake_offset,0.0,Vector2.ONE)
 draw_arc(pos,r*1.12,0.0,TAU,28,Color(accent,0.55),1.5)

func _draw_stages(size: Vector2) -> void:
 _button(Rect2(12,12,130,48),"BACK",GOLD)
 _text("MISSION SELECT",Vector2(size.x*0.5,size.y*0.105),32,CYAN)
 var cleared := max_unlocked_stage-1+int(campaign_complete)
 _text("%d / %d MISSIONS CLEARED" % [cleared,CAMPAIGN_STAGE_COUNT],Vector2(size.x*0.5,size.y*0.165),14,GOLD)
 for i in range(STAGE_TILE_COUNT):
  var number := i+1
  var rect := _stage_tile_rect(i,size)
  var unlocked := number<=CAMPAIGN_STAGE_COUNT and number<=max_unlocked_stage
  var complete := number<max_unlocked_stage or (number==CAMPAIGN_STAGE_COUNT and campaign_complete)
  var accent := GREEN if complete else (CYAN if unlocked else Color("#65718A"))
  draw_rect(Rect2(rect.position+Vector2(0,4),rect.size),Color(0.0,0.0,0.0,0.25))
  draw_rect(rect,Color("#0C1730") if unlocked else Color("#101421"))
  draw_rect(rect,Color(accent,0.72),false,2.0)
  _text("MISSION %02d" % number,Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+rect.size.y*0.38),16,accent)
  var status := "CLEARED" if complete else ("TAP TO DEPLOY" if unlocked else ("COMING SOON" if number>CAMPAIGN_STAGE_COUNT else "LOCKED"))
  _text(status,Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+rect.size.y*0.72),11,Color.WHITE if unlocked else Color("#78829A"))
 _text("CLEAR THE CURRENT MISSION TO UNLOCK THE NEXT • 9–12 ARRIVE IN A FUTURE UPDATE",Vector2(size.x*0.5,size.y*0.92),10,Color("#9EADC9"))

func _draw_help(size: Vector2) -> void:
 _button(Rect2(12,12,130,48),"BACK",GOLD)
 _text("FLIGHT SCHOOL",Vector2(size.x*0.5,size.y*0.13),34,CYAN)
 var panel := Rect2(size.x*0.08,size.y*0.22,size.x*0.84,size.y*0.62)
 draw_rect(panel,Color("#0A1429",0.94))
 draw_rect(panel,Color("#315C84"),false,2.0)
 var lines := [
  ["STEERING","Drag anywhere on the battlefield to guide your aircraft."],
  ["WEAPONS","Your aircraft fires automatically. Aim follows the nearest enemy."],
  ["DASH","Tap the circular DASH control, double-tap, or use a second finger."],
  ["POWER CORES","Collect drops for shields, repairs, overdrive and special abilities."],
  ["SMART TARGETING","Turns your shots into homing projectiles for a limited time."],
  ["WINGMAN ESCORT","Deploys a small support fighter that targets and fires automatically."],
  ["CAMPAIGN","Finish a mission to unlock the next one. Your progress is saved."]
 ]
 var row_height := panel.size.y/float(lines.size())
 for i in range(lines.size()):
  var y := panel.position.y+i*row_height
  _text(lines[i][0],Vector2(panel.position.x+panel.size.x*0.06,y+row_height*0.40),13,GOLD,false)
  _text(lines[i][1],Vector2(panel.position.x+panel.size.x*0.06,y+row_height*0.73),11,Color("#D3E0F6"),false)

func _draw_stage_clear(size: Vector2) -> void:
 draw_rect(Rect2(Vector2.ZERO,size),Color(0.0,0.015,0.045,0.82))
 var panel := Rect2(size.x*0.10,size.y*0.17,size.x*0.80,size.y*0.72)
 draw_rect(Rect2(panel.position+Vector2(0,7),panel.size),Color(0.0,0.0,0.0,0.36))
 draw_rect(panel,Color("#0B1831",0.98))
 draw_rect(panel,GOLD,false,2.0)
 var final_stage := stage>=CAMPAIGN_STAGE_COUNT
 _text("CAMPAIGN COMPLETE" if final_stage else "MISSION CLEARED",Vector2(size.x*0.5,size.y*0.31),34,GOLD)
 _text("MISSION %02d SECURED" % stage,Vector2(size.x*0.5,size.y*0.41),19,CYAN)
 _text("SCORE %d  •  CREDITS %d" % [score,credits],Vector2(size.x*0.5,size.y*0.49),14,Color.WHITE)
 if final_stage:
  _text("ALL %d MISSIONS COMPLETED. MORE MISSIONS COMING SOON." % CAMPAIGN_STAGE_COUNT,Vector2(size.x*0.5,size.y*0.57),11,Color("#B8C8E5"))
 else:
  _text("MISSION %02d IS NOW UNLOCKED" % (stage+1),Vector2(size.x*0.5,size.y*0.55),13,GREEN)
 if not final_stage:
  _button(Rect2(size.x*0.18,size.y*0.60,size.x*0.64,size.y*0.085),"NEXT MISSION",GREEN)
  _button(Rect2(size.x*0.18,size.y*0.70,size.x*0.64,size.y*0.085),"MISSION SELECT",CYAN)
  _button(Rect2(size.x*0.18,size.y*0.80,size.x*0.64,size.y*0.085),"MAIN MENU",GOLD)
 else:
  _button(Rect2(size.x*0.18,size.y*0.70,size.x*0.64,size.y*0.085),"MISSION SELECT",CYAN)
  _button(Rect2(size.x*0.18,size.y*0.80,size.x*0.64,size.y*0.085),"MAIN MENU",GOLD)

func _draw_game() -> void:
 var pcol:Color=_ship().primary
 for trail in trails:
  var alpha: float = 0.24*trail.time/trail.max
  draw_circle(trail.pos,11.0*trail.time/trail.max,Color(pcol,alpha))
 for wave in shockwaves:
  draw_arc(wave.pos,wave.radius,0,TAU,40,Color(wave.color,wave.time/wave.max),3)
 for bullet in bullets:
  var tail: Vector2 = bullet.pos-bullet.dir*22.0
  draw_line(bullet.pos,tail,bullet.color,3)
  draw_line(bullet.pos,tail,Color(1,1,1,0.9),1)
  if not OS.has_feature("android"):draw_arc(bullet.pos,10,0,TAU,20,Color(bullet.color,0.22),2)
 for bullet in enemy_bullets:
  draw_circle(bullet.pos,bullet.radius,PINK)
  draw_arc(bullet.pos,bullet.radius,0,TAU,20,Color.WHITE,1)
 for enemy in enemies:
  if not OS.has_feature("android"):draw_arc(enemy.pos,enemy.r*1.8,0,TAU,24,Color(ENEMY_TYPES[enemy.kind].color,0.12),3)
  _draw_enemy(enemy)
 var target: Variant = _nearest_enemy()
 if target!=null:
  var tr:float=target.r+11.0
  var lock_color:=Color("#72FFC2") if targeting_time>0.0 else PINK
  draw_arc(target.pos,tr,0,TAU,32,Color.WHITE,1)
  draw_arc(target.pos,tr+4,0,TAU,32,lock_color,2)
 for item in powerups:
  var col:Color=POWERUPS[item.kind].color
  if item.time>3.0 or int(item.time*7.0)%2==0:
   draw_circle(item.pos,19,Color(col,0.12))
   draw_circle(item.pos,17,Color(0.055,0.08,0.15,0.95))
   draw_arc(item.pos,17,0,TAU,28,col,2)
   _text(POWERUPS[item.kind].symbol,item.pos+Vector2(0,6),18,col)
 for particle in particles:
  var alpha:=clampf(particle.life/particle.max,0.0,1.0)
  draw_circle(particle.pos,particle.size*alpha,Color(particle.color,alpha))
 for popup in popups:_text(popup.text,popup.pos,16,Color(popup.color,popup.time/popup.max))
 if not (invulnerable>0.0 and int(invulnerable*14.0)%2==0):
  if not OS.has_feature("android"):draw_arc(player,58,0,TAU,32,Color(pcol,0.10),8)
  _draw_wingman()
  _draw_player()

func _draw_player() -> void:
 var cfg:=_ship()
 var r:=float(cfg.size)
 var primary:Color=cfg.primary
 var secondary:Color=cfg.secondary
 var t:=Time.get_ticks_msec()/1000.0
 var thrust:=clampf(velocity.length()/480.0,0.25,1.0)
 var flicker:=1.0+0.22*sin(t*26.0)
 draw_set_transform(player+screen_shake_offset+Vector2(18,24),aim_angle+PI/2,Vector2.ONE)
 # Ground shadow, matching the original's elevated aircraft presentation.
 draw_colored_polygon(PackedVector2Array([Vector2(0,-r*1.25),Vector2(r*0.8,r*0.55),Vector2(0,r*0.75),Vector2(-r*0.8,r*0.55)]),Color(0.01,0.02,0.06,0.38))
 draw_set_transform(player+screen_shake_offset,aim_angle+PI/2+bank*0.14,Vector2.ONE)
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
 draw_set_transform(screen_shake_offset,0,Vector2.ONE)
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
 var critical: bool = enemy.kind=="boss" and hp_frac<0.5
 if critical and enemy.flash<=0:col=Color(1.0,0.22,0.30)
 var hull_angle:float=enemy.aim
 if enemy.kind=="gunship":hull_angle=enemy.get("hull_angle",PI/2)
 draw_set_transform(enemy.pos+screen_shake_offset+Vector2(15,20),hull_angle+PI/2,Vector2.ONE)
 draw_colored_polygon(PackedVector2Array([Vector2(0,-r),Vector2(r*0.65,r*0.45),Vector2(0,r*0.65),Vector2(-r*0.65,r*0.45)]),Color(0.01,0.02,0.07,0.42))
 draw_set_transform(enemy.pos+screen_shake_offset,hull_angle+PI/2,Vector2.ONE)
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
  var rot: float = enemy.rot*(1.8 if critical else 1.0)
  var core:=PackedVector2Array()
  for i in range(6):core.append(Vector2(cos(rot+i*TAU/6),sin(rot+i*TAU/6))*r*0.38)
  core.append(core[0]);draw_polyline(core,Color(1.0,0.43,0.43) if critical else Color(1.0,0.76,0.92),2.5,true)
  draw_circle(Vector2.ZERO,r*0.13,Color.WHITE)
  var track2:Vector2=(player-enemy.pos).normalized()
  for side in [-1.0,1.0]:
   var mount2:=Vector2(r*0.08,side*r*0.56)
   draw_arc(mount2,r*0.14,0,TAU,20,col,2)
   draw_line(mount2,mount2+track2*r*0.36,Color.WHITE,3)
 draw_set_transform(screen_shake_offset,0,Vector2.ONE)
 # Boss health ring, gunship health bar only after damage.
 if enemy.kind=="boss":
  draw_arc(enemy.pos,r+18,-PI/2,-PI/2+TAU*maxf(0.03,hp_frac),64,col,4)
 elif enemy.kind=="gunship" and enemy.hp<enemy.max_hp:
  var bw:=r*1.6
  draw_rect(Rect2(enemy.pos.x-bw/2,enemy.pos.y-r-12,bw,4),Color(0.16,0.08,0.22))
  draw_rect(Rect2(enemy.pos.x-bw/2,enemy.pos.y-r-12,bw*hp_frac,4),col)
 draw_set_transform(screen_shake_offset,0,Vector2.ONE)
func _draw_hud(size: Vector2) -> void:
 var scale_ui:=clampf(minf(size.x/540.0,size.y/960.0),0.82,1.35)
 var left:=18.0*scale_ui
 var top:=24.0*scale_ui
 draw_rect(Rect2(8.0*scale_ui,10.0*scale_ui,size.x*0.47,106.0*scale_ui),Color(0.01,0.025,0.06,0.76))
 _text(_loc("امتیاز: %s" % _fa_number(score),"SCORE: %d" % score),Vector2(left,top+20.0*scale_ui),23,_ship().primary,false)
 _text(_loc("اعتبار: %s" % _fa_number(credits),"CREDITS: %d" % credits),Vector2(left,top+52.0*scale_ui),18,GOLD,false)
 _text(_ship().name,Vector2(left,top+84.0*scale_ui),16,Color("#C4D5E9"),false)
 var heart_x:=left
 var heart_y:=top+102.0*scale_ui
 for i in range(max_hp):
  var col:=PINK if i<hp else Color("#39445B")
  draw_rect(Rect2(heart_x+i*29.0*scale_ui,heart_y,23.0*scale_ui,13.0*scale_ui),col,true)
 var header:=Rect2(size.x*0.51,12.0*scale_ui,size.x*0.46,90.0*scale_ui)
 draw_rect(header,Color(0.01,0.025,0.06,0.76))
 _text(_loc("مرحلهٔ %s" % _fa_number(stage),"MISSION %d" % stage),Vector2(header.position.x+header.size.x*0.5,top+18.0*scale_ui),18,GOLD)
 _text(_loc("موج %s از %s" % [_fa_number(subwave),_fa_number(total_subwaves)],"WAVE %d / %d" % [subwave,total_subwaves]),Vector2(header.position.x+header.size.x*0.5,top+48.0*scale_ui),16,Color.WHITE)
 var bar:=Rect2(header.position.x+header.size.x*0.10,top+65.0*scale_ui,header.size.x*0.80,7.0*scale_ui)
 draw_rect(bar,Color("#263650"))
 var segment:=bar.size.x/float(maxi(1,total_subwaves))
 for i in range(subwave):
  draw_rect(Rect2(bar.position.x+i*segment+2,bar.position.y+1,maxf(2.0,segment-4),5.0*scale_ui),GREEN)
 var status_y:=size.y-184.0*scale_ui
 var status:Array[String]=[]
 if shield:status.append(_loc("سپر محافظ فعال","SHIELD ACTIVE"))
 if overdrive_time>0.0:status.append(_loc("قدرت شلیک: %s" % _fa_decimal(overdrive_time),"OVERDRIVE %.1fs" % overdrive_time))
 if magnet_time>0.0:status.append(_loc("جذب جایزه: %s" % _fa_decimal(magnet_time),"MAGNET %.1fs" % magnet_time))
 if slow_time>0.0:status.append(_loc("کندسازی زمان: %s" % _fa_decimal(slow_time),"TIME DILATION %.1fs" % slow_time))
 if targeting_time>0.0:status.append(_loc("هدف‌گیری هوشمند: %s" % _fa_decimal(targeting_time),"SMART TARGETING %.1fs" % targeting_time))
 if wingman_time>0.0:status.append(_loc("جنگندهٔ کمکی: %s" % _fa_decimal(wingman_time),"WINGMAN %.1fs" % wingman_time))
 for i in range(status.size()):
  _text(status[i],Vector2(left,status_y+i*25.0*scale_ui),16,GREEN if i%2==0 else CYAN,false)
 _text(_loc("زنجیره ×%s" % _fa_number(combo),"COMBO x%d" % combo),Vector2(size.x*0.5,size.y-24.0*scale_ui),19,GOLD)
 if banner_time>0.0:
  _text(banner_title,Vector2(size.x*0.5,size.y*0.30),34,CYAN)
  _text(banner_subtitle,Vector2(size.x*0.5,size.y*0.36),19,GOLD)


func _draw_menu(size: Vector2) -> void:
 var t:=Time.get_ticks_msec()/1000.0
 var header:=Rect2(size.x*0.055,size.y*0.06,size.x*0.89,size.y*0.39)
 draw_rect(header,Color(0.025,0.065,0.15,0.86))
 draw_rect(header,Color("#2D91CD"),false,2)
 _text("PARVAZ",Vector2(size.x*0.5,size.y*0.16+sin(t*1.4)*2.5),mini(48,int(size.x*0.12)),CYAN)
 _text("AIR COMBAT • CAMPAIGN EDITION",Vector2(size.x*0.5,size.y*0.24),13,Color("#96B7DC"))
 var preview:=Vector2(size.x*0.5,size.y*0.335)
 draw_arc(preview,48,0,TAU,48,Color(_ship().primary,0.24),3)
 draw_arc(preview,37,0,TAU,40,Color(_ship().primary,0.12),2)
 _draw_ship_icon(preview,_ship().primary,38,_ship().id)
 _text("ACTIVE FIGHTER / "+_ship().name,Vector2(size.x*0.5,size.y*0.425),13,_ship().primary)
 var strip:=Rect2(size.x*0.08,size.y*0.465,size.x*0.84,36)
 draw_rect(strip,Color(0.04,0.09,0.17,0.95))
 draw_rect(strip,Color("#2D648E"),false,1)
 _text("CAMPAIGN %d/%d CLEARED • BEST %d • CR %d" % [max_unlocked_stage-1+int(campaign_complete),CAMPAIGN_STAGE_COUNT,best_stage,credits],Vector2(size.x*0.5,size.y*0.49),14,GOLD)
 _button(Rect2(size.x*0.18,size.y*0.535,size.x*0.64,size.y*0.082),"CAMPAIGN / LEVEL SELECT",GREEN)
 _button(Rect2(size.x*0.18,size.y*0.617,size.x*0.64,size.y*0.082),"HANGAR • FLEET %d/%d" % [unlocked_ships.size(),SHIPS.size()],GOLD)
 _button(Rect2(size.x*0.18,size.y*0.699,size.x*0.64,size.y*0.082),"SETTINGS",CYAN)
 _button(Rect2(size.x*0.18,size.y*0.781,size.x*0.64,size.y*0.082),"FLIGHT SCHOOL / HELP",PURPLE)
 _button(Rect2(size.x*0.18,size.y*0.863,size.x*0.64,size.y*0.082),"ACHIEVEMENTS",Color("#8E9BFF"))
 _text("DRAG TO STEER • AUTO FIRE • TAP DASH",Vector2(size.x*0.5,size.y*0.95),11,Color("#879EBE"))
 _button(Rect2(size.x-78,12,66,42),"MUTE" if muted else "AUDIO",PINK if muted else CYAN)

func _draw_hangar(size: Vector2) -> void:
 _button(Rect2(size.x-78,12,66,42),"MUTE" if muted else "AUDIO",PINK if muted else CYAN)
 _text("FLEET HANGAR",Vector2(size.x*0.5,size.y*0.10),36,CYAN)
 _text("CREDITS %d • TAP TO EQUIP OR UNLOCK" % credits,Vector2(size.x*0.5,size.y*0.16),12,GOLD)
 _button(Rect2(12,12,130,48),"BACK",GOLD)
 var columns:=2 if size.x<650 else 4
 var card_width:=size.x/columns
 var card_height:=size.y*0.17 if size.x<650 else size.y*0.37
 var top:=size.y*0.20
 for i in range(SHIPS.size()):
  var ship:Dictionary=SHIPS[i]
  var row:=floori(float(i)/float(columns))
  var col:=i%columns
  var rect:=Rect2(col*card_width+8,top+row*card_height,card_width-16,card_height-8)
  var unlocked:=unlocked_ships.has(ship.id)
  var equipped: bool = selected_ship==ship.id
  draw_rect(rect,Color(0.06,0.09,0.17,0.96))
  draw_rect(rect,Color(ship.primary,0.85 if equipped else 0.6),false,3 if equipped else 2)
  _text(ship.name,Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+28),16,ship.primary)
  _text(ship.role,Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+52),11,Color.WHITE)
  _draw_ship_icon(Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+rect.size.y*0.43),ship.primary,int(ship.size),ship.id)
  _text("ARMOR %d • DMG %d%% • RATE %.2f" % [ship.hp,int(ship.damage*100),ship.rate],Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+rect.size.y*0.67),10,Color("#A8B9D7"))
  _text(ship.ability,Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+rect.size.y*0.79),10,GOLD)
  var status: String="EQUIPPED" if equipped else ("UNLOCKED" if unlocked else "REACH STAGE %d" % ship.stage)
  _text(status,Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+rect.size.y*0.91),12,GREEN if unlocked else PINK)

func _draw_ship_icon(pos: Vector2,color: Color,r: int,ship_id: String="viper") -> void:
 var shape:=PackedVector2Array()
 match ship_id:
  "viper":shape=PackedVector2Array([Vector2(0,-r*1.3),Vector2(r*0.25,-r*0.25),Vector2(r*1.05,r*0.4),Vector2(r*0.72,r*0.55),Vector2(0,r*0.35),Vector2(-r*0.72,r*0.55),Vector2(-r*1.05,r*0.4),Vector2(-r*0.25,-r*0.25)])
  "interceptor":shape=PackedVector2Array([Vector2(0,-r*1.35),Vector2(r*0.22,r*0.55),Vector2(r*0.9,r*0.8),Vector2(r*0.45,r*0.25),Vector2(0,r*0.6),Vector2(-r*0.45,r*0.25),Vector2(-r*0.9,r*0.8),Vector2(-r*0.22,r*0.55)])
  "valkyrie":shape=PackedVector2Array([Vector2(0,-r*1.25),Vector2(r*0.3,-r*0.25),Vector2(r*1.1,r*0.25),Vector2(r*0.8,r*0.55),Vector2(r*0.38,r*0.35),Vector2(0,r*0.7),Vector2(-r*0.38,r*0.35),Vector2(-r*0.8,r*0.55),Vector2(-r*1.1,r*0.25),Vector2(-r*0.3,-r*0.25)])
  "phantom":shape=PackedVector2Array([Vector2(0,-r*1.4),Vector2(r*0.18,r*0.55),Vector2(r*0.85,r*0.35),Vector2(r*0.45,r*0.72),Vector2(0,r*0.4),Vector2(-r*0.45,r*0.72),Vector2(-r*0.85,r*0.35),Vector2(-r*0.18,r*0.55)])
  "titan":shape=PackedVector2Array([Vector2(0,-r*1.2),Vector2(r*0.4,-r*0.25),Vector2(r*1.25,r*0.5),Vector2(r*0.9,r*0.85),Vector2(r*0.35,r*0.55),Vector2(0,r*0.75),Vector2(-r*0.35,r*0.55),Vector2(-r*0.9,r*0.85),Vector2(-r*1.25,r*0.5),Vector2(-r*0.4,-r*0.25)])
 if shape.is_empty():
  shape=PackedVector2Array([Vector2(0,-r*1.3),Vector2(r*0.25,-r*0.25),Vector2(r*1.0,r*0.45),Vector2(r*0.6,r*0.55),Vector2(0,r*0.35),Vector2(-r*0.6,r*0.55),Vector2(-r*1.0,r*0.45),Vector2(-r*0.25,-r*0.25)])
 draw_set_transform(pos,0,Vector2.ONE)
 draw_colored_polygon(shape,color)
 shape.append(shape[0])
 draw_polyline(shape,Color(0.78,0.95,1.0),2.0,true)
 draw_set_transform(Vector2.ZERO)
 draw_colored_polygon(PackedVector2Array([Vector2(0,-r*0.85),Vector2(r*0.15,-r*0.05),Vector2(0,r*0.18),Vector2(-r*0.15,-r*0.05)]),CYAN)
 if ship_id=="titan":
  for side in [-1.0,0.0,1.0]:draw_circle(pos+Vector2(side*r*0.4,-r*0.12),r*0.1,Color.WHITE)
 else:
  for side in [-1.0,1.0]:draw_circle(pos+Vector2(side*r*0.35,r*0.38),r*0.08,Color.WHITE)

func _draw_settings(size: Vector2) -> void:
 _button(Rect2(size.x-78,12,66,42),"MUTE" if muted else "AUDIO",PINK if muted else CYAN)
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
 _text("TOTAL KILLS %d • PLAYTIME %dm • RUNS %d" % [total_kills,int(total_playtime/60.0),total_runs],Vector2(size.x*0.5,size.y*0.47),12,Color("#A5B4D6"))
 _text("SFX VOLUME",Vector2(size.x*0.5,size.y*0.79),16,Color.WHITE)
 draw_rect(Rect2(size.x*0.2,size.y*0.82,size.x*0.6,8),Color("#25324D"))
 draw_rect(Rect2(size.x*0.2,size.y*0.82,size.x*0.6*sfx_volume,8),CYAN)
 _text("MUSIC VOLUME",Vector2(size.x*0.5,size.y*0.89),16,Color.WHITE)
 draw_rect(Rect2(size.x*0.2,size.y*0.92,size.x*0.6,8),Color("#25324D"))
 draw_rect(Rect2(size.x*0.2,size.y*0.92,size.x*0.6*music_volume,8),PURPLE)

func _draw_achievements(size: Vector2) -> void:
 _button(Rect2(size.x-78,12,66,42),"MUTE" if muted else "AUDIO",PINK if muted else CYAN)
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
 _button(Rect2(size.x-78,12,66,42),"MUTE" if muted else "AUDIO",PINK if muted else CYAN)
 _draw_overlay(size,"MISSION FAILED","SCORE %d • RECORD %d" % [score,high_score],PINK)
 _text("STAGE %d • WAVE %d • CREDITS %d" % [stage,subwave,credits],Vector2(size.x*0.5,size.y*0.61),15,GOLD)
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
 var font: Font = ThemeDB.fallback_font
 if font == null:
  font = SystemFont.new()
 var width: float = font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
 draw_string(font,Vector2(pos.x-width*0.5 if centered else pos.x,pos.y),value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

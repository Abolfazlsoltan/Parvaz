extends Node
# Procedural audio port of the original V3.5 SoundBank.
const SAMPLE_RATE := 22050
const POOL_SIZE := 12
var muted := false
var sfx_volume := 0.7
var music_volume := 0.5
var sounds: Dictionary = {}
var music_player: AudioStreamPlayer
var players: Array[AudioStreamPlayer] = []
var next_player := 0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
 rng.randomize()
 for i in range(POOL_SIZE):
  var player := AudioStreamPlayer.new()
  player.bus="Master"
  add_child(player)
  players.append(player)
 music_player=AudioStreamPlayer.new()
 music_player.bus="Master"
 add_child(music_player)
 _build_bank()

func _make_wave(f1: float,f2: float,duration: float,kind: String,volume: float,loop: bool=false) -> AudioStreamWAV:
 var count:=maxi(1,int(SAMPLE_RATE*duration))
 var bytes:=PackedByteArray()
 bytes.resize(count*2)
 var phase:=0.0
 for i in range(count):
  var t:=float(i)/float(count)
  var env:=1.0 if loop else pow(1.0-t,1.45)
  phase+=(f1+(f2-f1)*t)*TAU/SAMPLE_RATE
  var v:=0.0
  match kind:
   "square":v=1.0 if sin(phase)>=0.0 else -1.0
   "saw":v=2.0*fposmod(phase/TAU,1.0)-1.0
   "noise":v=rng.randf_range(-1.0,1.0)
   _:v=sin(phase)
  var sample=clampi(int(v*env*volume*32767.0),-32767,32767)
  bytes.encode_s16(i*2,sample)
 var stream:=AudioStreamWAV.new()
 stream.format=AudioStreamWAV.FORMAT_16_BITS
 stream.mix_rate=SAMPLE_RATE
 stream.stereo=false
 stream.data=bytes
 if loop:
  stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
  stream.loop_begin=0
  stream.loop_end=count
 return stream

func _build_bank() -> void:
 var bank: Dictionary={
  "shoot_light":[860.0,380.0,0.055,"saw",0.09],
  "shoot_heavy":[420.0,150.0,0.09,"square",0.13],
  "shoot_plasma":[980.0,520.0,0.075,"sine",0.12],
  "hit":[280.0,150.0,0.045,"square",0.11],
  "explode":[165.0,40.0,0.24,"noise",0.26],
  "big_explode":[115.0,25.0,0.48,"noise",0.35],
  "dash":[360.0,980.0,0.15,"sine",0.22],
  "powerup":[480.0,960.0,0.18,"sine",0.22],
  "morph":[330.0,1120.0,0.30,"sine",0.26],
  "hurt":[210.0,60.0,0.30,"saw",0.30],
  "subwave":[520.0,780.0,0.18,"sine",0.18],
  "stage_clear":[392.0,988.0,0.42,"sine",0.25],
  "menu_select":[620.0,880.0,0.12,"sine",0.15],
  "menu_back":[440.0,320.0,0.10,"sine",0.12],
  "achievement":[720.0,1200.0,0.35,"sine",0.28]
 }
 for key in bank:
  var spec:Array=bank[key]
  sounds[key]=_make_wave(spec[0],spec[1],spec[2],spec[3],spec[4])
 var ambient:=AudioStreamWAV.new()
 var count:=SAMPLE_RATE*2
 var bytes:=PackedByteArray()
 bytes.resize(count*2)
 for i in range(count):
  var v:=0.55*sin(i*TAU*55.0/SAMPLE_RATE)+0.35*sin(i*TAU*110.0/SAMPLE_RATE)+0.15*sin(i*TAU*165.0/SAMPLE_RATE)
  bytes.encode_s16(i*2,clampi(int(v*0.065*32767.0),-32767,32767))
 ambient.format=AudioStreamWAV.FORMAT_16_BITS
 ambient.mix_rate=SAMPLE_RATE
 ambient.stereo=false
 ambient.data=bytes
 ambient.loop_mode=AudioStreamWAV.LOOP_FORWARD
 ambient.loop_begin=0
 ambient.loop_end=count
 sounds["ambient"]=ambient

func play_sfx(key: String) -> void:
 if muted or not sounds.has(key) or players.is_empty():return
 var player:=players[next_player]
 next_player=(next_player+1)%players.size()
 player.stop()
 player.stream=sounds[key]
 player.volume_db=linear_to_db(clampf(sfx_volume,0.0,1.0))
 player.play()

func start_music() -> void:
 if muted or music_player==null:return
 if music_player.playing:return
 music_player.stream=sounds.get("ambient")
 music_player.volume_db=linear_to_db(clampf(music_volume,0.0,1.0))
 music_player.play()

func stop_music() -> void:
 if music_player!=null:music_player.stop()

func set_muted(value: bool) -> void:
 muted=value
 if muted:stop_music()

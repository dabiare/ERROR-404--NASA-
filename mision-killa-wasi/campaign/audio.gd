extends Node
var indoor: AudioStreamPlayer
var outdoor: AudioStreamPlayer
var tension: AudioStreamPlayer
var voice: AudioStreamPlayer
var effect: AudioStreamPlayer
var alarm: AudioStreamPlayer
var outside_wait := 20.0
var alarm_wait := 15.0
var context := "menu"
var fade: Tween
var tone_step: AudioStreamWAV
var tone_confirm: AudioStreamWAV
var tone_alarm: AudioStreamWAV
var voice_cooldown := 0.0
var menu_music:AudioStreamPlayer
var spoken_voice:=''
var english_voices:PackedStringArray=[]
var narration:AudioStreamPlayer
var narration_pitch:AudioEffectPitchShift
var missing_voice_lines:Array[String]=[]
const VOICE_PROFILES={
 'commander':{'voice':0,'pitch':1.02,'rate':0.98},
 'engineer':{'voice':1,'pitch':0.87,'rate':1.07},
 'botanist':{'voice':2,'pitch':1.18,'rate':1.08},
 'doctor':{'voice':0,'pitch':0.91,'rate':0.86},
 'geologist':{'voice':1,'pitch':1.08,'rate':1.13},
 'robot':{'voice':2,'pitch':1.48,'rate':1.16},
 'control':{'voice':0,'pitch':0.79,'rate':0.93}
}

func player(stream: AudioStream, bus: String) -> AudioStreamPlayer:
 var p := AudioStreamPlayer.new()
 p.stream = stream
 p.bus = bus
 add_child(p)
 return p

func mp3(name: String, loop: bool) -> AudioStreamMP3:
 var a: AudioStreamMP3 = load("res://campaign/audio/"+name+".mp3").duplicate()
 a.loop = loop
 return a

func _ready() -> void:
 for name in ["Music","Effects","Voice"]:
  if AudioServer.get_bus_index(name)<0:
   AudioServer.add_bus()
   AudioServer.set_bus_name(AudioServer.bus_count-1,name)
 if AudioServer.get_bus_index('Narration')<0:
  AudioServer.add_bus();AudioServer.set_bus_name(AudioServer.bus_count-1,'Narration')
 AudioServer.set_bus_send(AudioServer.get_bus_index('Narration'),'Voice')
 narration_pitch=AudioEffectPitchShift.new()
 AudioServer.add_bus_effect(AudioServer.get_bus_index('Narration'),narration_pitch)
 narration=player(null,'Narration')
 indoor = player(mp3("musica_dentro_nave",true),"Music")
 menu_music=player(mp3('musica_menu',true),'Music')
 menu_music.volume_db=-3
 menu_music.play()
 if DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
  english_voices=DisplayServer.tts_get_voices_for_language('en')
  if not english_voices.is_empty():spoken_voice=english_voices[0]
 outdoor = player(mp3("musica_fuera_nave",false),"Music")
 tension = player(mp3("musica_tension",true),"Music")
 voice = player(load("res://campaign/audio/Blip.wav"),"Voice")
 effect = player(null,"Effects")
 alarm = player(null,"Effects")
 tone_step = tone(0.07,85,0.12)
 tone_confirm = tone(0.18,660,0.12)
 tone_alarm = tone(1.5,600,0.18,true)
 outdoor.finished.connect(func(): outside_wait = randf_range(45,90))
 Mission.emergency_started.connect(func(_kind): alarm_once(); alarm_wait = 15.0)
 set_levels()
 refresh_voices()

func tone(seconds: float, hz: float, gain: float, siren := false) -> AudioStreamWAV:
 var data := PackedByteArray()
 var samples := int(seconds * 22050)
 data.resize(samples*2)
 for i in samples:
  var t := i/22050.0
  var phase := TAU*hz*t + (50.0*sin(TAU*2*t) if siren else 0.0)
  var envelope := minf(1,t*30)*minf(1,(seconds-t)*20)
  data.encode_s16(i*2,int(sin(phase)*envelope*gain*32767))
 var wav := AudioStreamWAV.new()
 wav.format = AudioStreamWAV.FORMAT_16_BITS
 wav.mix_rate = 22050
 wav.data = data
 return wav

func set_levels() -> void:
 for pair in [["Music","music"],["Effects","effects"],["Voice","voice"]]:
  var index := AudioServer.get_bus_index(pair[0])
  var level: float = Mission.settings[pair[1]]
  AudioServer.set_bus_volume_db(index,linear_to_db(maxf(0.0001,level)))
  AudioServer.set_bus_mute(index,level<=0.001)

func switch_context(next: String) -> void:
 if context == next: return
 context = next
 if next=="outside":
  outdoor.stop()
  outside_wait=randf_range(15,35)
 if fade: fade.kill()
 fade = create_tween().set_parallel(true)
 for p in [indoor,outdoor,tension,menu_music]:
  var selected: bool = (p==indoor and next=="inside") or (p==outdoor and next=="outside") or (p==tension and next=="danger") or (p==menu_music and next=='menu')
  if selected:
   if p.stream_paused: p.stream_paused = false
   if not p.playing and p!=outdoor:
    p.volume_db = -60
    p.play()
   fade.tween_property(p,"volume_db",-7.0 if p==tension else -3.0,1.0)
  else:
   fade.tween_property(p,"volume_db",-60.0,1.0)
 fade.finished.connect(func():
  for p in [indoor,outdoor,tension,menu_music]:
   if p.volume_db < -55: p.stream_paused = true)
 if next != "danger": alarm.stop()

func _process(delta: float) -> void:
 voice_cooldown = maxf(0,voice_cooldown-delta)
 if not Mission.active: switch_context("menu"); return
 if get_tree().get_meta('landing',false):switch_context('menu');return
 var task_id: String = Mission.current().get("id","")
 var danger := not Mission.emergency.is_empty() or task_id in ["dose_check","wait_control"]
 switch_context("danger" if danger else ("outside" if Mission.room=="exterior" else "inside"))
 if not Mission.focused:stop_speech();return
 if context=="outside" and not outdoor.playing and Mission.movable():
  outside_wait -= delta
  if outside_wait<=0: outdoor.stream_paused=false; outdoor.play()
 if not Mission.emergency.is_empty() and Mission.movable():
  alarm_wait-=delta
  if alarm_wait<=0: alarm_once(); alarm_wait=15

func step() -> void:
 effect.stream=tone_step
 effect.volume_db=-6
 effect.play()

func confirm() -> void:
 effect.stream=tone_confirm
 effect.volume_db=0
 effect.play()

func blip() -> void:
 if voice_cooldown>0: return
 voice_cooldown=0.085
 voice.pitch_scale=randf_range(0.96,1.06)
 voice.play()

func alarm_once() -> void:
 alarm.stream=tone_alarm
 alarm.play()

func shutdown() -> void:
 stop_speech()
 set_process(false)
 if fade: fade.kill()
 for p in [indoor,outdoor,tension,voice,effect,alarm,menu_music,narration]:
  if is_instance_valid(p):
   p.stop()
   p.stream=null
 tone_alarm=null
 tone_step=null
 tone_confirm=null

func speak(text:String,speaker:='robot')->void:
 if spoken_voice.is_empty():refresh_voices()
 if Mission.settings.voice<=0:return
 var profile:Dictionary=VOICE_PROFILES.get(speaker,VOICE_PROFILES.robot)
 var clip:String=voice_clip_path(text)
 if ResourceLoader.exists(clip):
  stop_speech()
  narration.stream=load(clip)
  narration.pitch_scale=profile.rate
  narration_pitch.pitch_scale=profile.pitch/profile.rate
  narration.play()
  return
 if english_voices.is_empty():
  if not text in missing_voice_lines:missing_voice_lines.append(text)
  return
 var voice_id:String=english_voices[int(profile.voice)%english_voices.size()]
 DisplayServer.tts_speak(text,voice_id,int(Mission.settings.voice*100),profile.pitch,profile.rate,0,true)

func refresh_voices()->void:
 if DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):english_voices=DisplayServer.tts_get_voices_for_language('en')
 if not english_voices.is_empty():spoken_voice=english_voices[0]
 elif ResourceLoader.exists(voice_clip_path('We will look after our crew and explore together.')):spoken_voice='Bundled English audio'

func voice_clip_path(text:String)->String:
 return 'res://campaign/audio/voices_en/'+text.sha256_text().substr(0,24)+'.wav'

func stop_speech()->void:
 if not english_voices.is_empty():DisplayServer.tts_stop()
 if is_instance_valid(narration):narration.stop()

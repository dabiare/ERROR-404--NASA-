extends Node
var ambience: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var sound_step: AudioStreamWAV
var sound_beep: AudioStreamWAV
var sound_confirm: AudioStreamWAV
var next_voice := 0

func _ready() -> void:
	ambience = AudioStreamPlayer.new()
	add_child(ambience)
	var stream := tone(8.0, [110.0,164.81,220.0,277.18],0.08,true)
	ambience.stream = stream
	ambience.volume_db = -10
	ambience.play()
	for i in 4:
		var p := AudioStreamPlayer.new()
		add_child(p)
		effects.append(p)
	sound_step = tone(0.07,[100.0,71.0],0.12)
	sound_beep = tone(0.12,[720.0,960.0],0.09)
	sound_confirm = tone(0.3,[523.25,659.25,783.99],0.11)
	set_volume(Session.volume)

func tone(duration: float, frequencies: Array, level: float, looping := false) -> AudioStreamWAV:
	var rate := 22050
	var count := int(duration * rate)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var t := float(i)/rate
		var sample := 0.0
		for f in frequencies: sample += sin(TAU * float(f) * t)
		var envelope := sin(PI * float(i) / count) if not looping else minf(1.0, minf(t, duration - t) * 1.5)
		var value := int(sample / frequencies.size() * level * envelope * 32767)
		data.encode_s16(i*2, value)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	if looping:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = count
	return wav

func set_volume(value: float) -> void:
	Session.volume = value
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(value,0.0001)))
	AudioServer.set_bus_mute(0,value <= 0.001)

func play_effect(stream: AudioStreamWAV) -> void:
	var p := effects[next_voice % effects.size()]
	next_voice += 1
	p.stream = stream
	p.play()

func step() -> void: play_effect(sound_step)
func beep() -> void: play_effect(sound_beep)
func confirm() -> void: play_effect(sound_confirm)

func shutdown() -> void:
	ambience.stop()
	ambience.stream = null
	for p in effects:
		p.stop()
		p.stream = null
	sound_step = null
	sound_beep = null
	sound_confirm = null

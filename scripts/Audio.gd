extends Node
## Audio — Autoload that generates procedural sound effects and background music
## using AudioStreamGenerator so no external audio files are required.

var _music_player: AudioStreamPlayer
var _music_playback: AudioStreamGeneratorPlayback
var _music_hz: float = 44100.0
var _music_phase: float = 0.0
var _music_time: float = 0.0
var _music_enabled: bool = true

# Simple melody for background music (frequencies in Hz, 0 = rest)
const _MELODY: Array[float] = [
	261.6, 261.6, 293.7, 329.6,  # C C D E
	329.6, 293.7, 261.6, 220.0,  # E D C A
	246.9, 246.9, 261.6, 293.7,  # B B C D
	261.6, 0.0,   261.6, 0.0,    # C rest C rest
]
const _NOTE_LEN: float = 0.18  # seconds per note
var _note_idx: int = 0
var _note_timer: float = 0.0

func _ready() -> void:
	_setup_music()

func _setup_music() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = _music_hz
	gen.buffer_length = 0.1
	_music_player.stream = gen
	_music_player.play()
	_music_playback = _music_player.get_stream_playback()

func _process(_delta: float) -> void:
	_fill_music_buffer()

func _fill_music_buffer() -> void:
	if not _music_enabled or _music_playback == null:
		return
	var frames := _music_playback.get_frames_available()
	if frames <= 0:
		return
	var freq: float = _MELODY[_note_idx % _MELODY.size()]
	for i in range(frames):
		_note_timer += 1.0 / _music_hz
		if _note_timer >= _NOTE_LEN:
			_note_timer = 0.0
			_note_idx = (_note_idx + 1) % _MELODY.size()
			freq = _MELODY[_note_idx % _MELODY.size()]
		var sample: float = 0.0
		if freq > 0.0:
			_music_phase += freq / _music_hz
			if _music_phase >= 1.0:
				_music_phase -= 1.0
			# Soft square wave blended with triangle for chiptune feel
			var sq: float = 1.0 if _music_phase < 0.5 else -1.0
			var tri: float = 1.0 - absf(_music_phase - 0.5) * 4.0
			sample = (sq * 0.3 + tri * 0.5) * 0.18
			# Note fade-out envelope
			var note_left: float = _NOTE_LEN - _note_timer
			if note_left < 0.03:
				sample *= note_left / 0.03
		_music_playback.push_frame(Vector2(sample, sample))

func set_music_enabled(enabled: bool) -> void:
	_music_enabled = enabled
	if not enabled and _music_playback != null:
		# Push silence
		var frames := _music_playback.get_frames_available()
		for _i in range(frames):
			_music_playback.push_frame(Vector2.ZERO)

# ── One-shot SFX ───────────────────────────────────────────────────────────────
func play_collect() -> void:
	_play_tone(880.0, 0.08, 0.5)
	_play_tone(1047.0, 0.08, 0.5, 0.08)

func play_jump() -> void:
	_play_sweep(220.0, 440.0, 0.12, 0.4)

func play_hurt() -> void:
	_play_sweep(440.0, 110.0, 0.2, 0.5)

func play_death() -> void:
	_play_tone(220.0, 0.15, 0.6)
	_play_tone(165.0, 0.15, 0.6, 0.15)
	_play_tone(110.0, 0.3,  0.6, 0.3)

func play_levelup() -> void:
	for i in range(5):
		_play_tone([523.0, 659.0, 784.0, 1047.0, 1319.0][i], 0.1, 0.5, i * 0.1)

func play_menu_select() -> void:
	_play_tone(660.0, 0.06, 0.35)

func play_menu_back() -> void:
	_play_tone(440.0, 0.06, 0.3)

func play_gameover() -> void:
	_play_tone(330.0, 0.2, 0.5)
	_play_tone(262.0, 0.2, 0.5, 0.22)
	_play_tone(196.0, 0.4, 0.5, 0.44)

func play_powerup() -> void:
	for i in range(4):
		_play_tone([523.0, 659.0, 784.0, 1047.0][i], 0.07, 0.45, i * 0.07)

# ── Internal helpers ──────────────────────────────────────────────────────────
func _play_tone(freq: float, duration: float, vol: float, delay: float = 0.0) -> void:
	var player := _make_sfx_player()
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = 44100.0
	gen.buffer_length = duration + 0.05
	player.stream = gen
	player.play()
	var pb := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if pb == null:
		player.queue_free()
		return
	var frames := pb.get_frames_available()
	var phase: float = 0.0
	for i in range(frames):
		var t: float = float(i) / 44100.0
		phase += freq / 44100.0
		if phase >= 1.0:
			phase -= 1.0
		var sq: float = 1.0 if phase < 0.5 else -1.0
		var env: float = 1.0
		if t > duration * 0.7:
			env = 1.0 - (t - duration * 0.7) / (duration * 0.3)
			env = clampf(env, 0.0, 1.0)
		pb.push_frame(Vector2(sq * vol * env, sq * vol * env))
	await get_tree().create_timer(duration + 0.05).timeout
	player.queue_free()

func _play_sweep(freq_start: float, freq_end: float, duration: float, vol: float, delay: float = 0.0) -> void:
	var player := _make_sfx_player()
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = 44100.0
	gen.buffer_length = duration + 0.05
	player.stream = gen
	player.play()
	var pb := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if pb == null:
		player.queue_free()
		return
	var frames := pb.get_frames_available()
	var phase: float = 0.0
	for i in range(frames):
		var t: float = float(i) / 44100.0
		var ratio: float = clampf(t / duration, 0.0, 1.0)
		var freq: float = lerpf(freq_start, freq_end, ratio)
		phase += freq / 44100.0
		if phase >= 1.0:
			phase -= 1.0
		var sq: float = 1.0 if phase < 0.5 else -1.0
		var env: float = 1.0
		if t > duration * 0.7:
			env = 1.0 - (t - duration * 0.7) / (duration * 0.3)
		pb.push_frame(Vector2(sq * vol * env, sq * vol * env))
	await get_tree().create_timer(duration + 0.05).timeout
	player.queue_free()

func _make_sfx_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	add_child(p)
	return p

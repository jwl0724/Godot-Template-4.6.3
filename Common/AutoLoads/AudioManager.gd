extends Node

var _player1: AudioStreamPlayer = null # for cross-fading music
var _player2: AudioStreamPlayer = null

var in_use_player: AudioStreamPlayer = null

var playlist: Array[AudioStream]
var playlist_index: int = 0
var playlist_fade_time: float = 0

var loop_track: bool = false
var loop_playlist: bool = false



func _ready() -> void:
    _player1 = AudioStreamPlayer.new()
    _player1.bus = Constants.AudioBus_DefaultMusic
    in_use_player = _player1

    _player2 = AudioStreamPlayer.new()
    _player2.bus = Constants.AudioBus_DefaultMusic

    SignalBus.OptionsChanged_MusicDB.connect(_on_options_music_db_changed)
    SignalBus.OptionsChanged_SFXDB.connect(_on_options_sfx_db_changed)



func add_to_playlist(stream: AudioStream) -> void:
    var music_index = playlist.find(stream)
    if music_index == -1: push_warning("%s is already in the playlist and has not been added, is this intended behavior?")
    else: playlist.append(stream)



func remove_from_playlist(stream: AudioStream) -> void:
    var music_index = playlist.find(stream)
    if music_index == -1: printerr("%s was not found in the playlist and cannot be remove" % str(stream))
    else: playlist.remove_at(music_index)



func clear_playlist() -> void:
    playlist.clear()
    playlist_index = 0
    loop_playlist = false



func shuffle_playlist() -> void:
    playlist.shuffle()



func set_playlist_loop(do_loop: bool) -> void:
    if playlist.size() == 0 && do_loop:
        printerr("Cannot loop an empty playlist")
        loop_playlist = false
    else: loop_playlist = do_loop



func play_playlist(index: int, transition_fade_time: float) -> void:
    playlist_fade_time = transition_fade_time
    if transition_fade_time <= 0: play_music(playlist[index])
    else: crossfade_music(playlist[index], transition_fade_time)



func play_music(stream: AudioStream, fade_time: float = 0) -> void:
    if in_use_player.stream == stream && in_use_player.playing: return

    if fade_time == 0:
        in_use_player.volume_linear = 1
        in_use_player.stream = stream
        in_use_player.play()

    elif fade_time > 0:
        var current_player: AudioStreamPlayer = in_use_player
        current_player.volume_linear = 0
        var fade: Tween = create_tween()
        fade.tween_property(current_player, "volume_linear", 1, fade_time)
        fade.tween_callback(func(): current_player.play())
        fade.play()



func stop_music(fade_time: float = 0) -> void:
    if fade_time == 0:
        in_use_player.volume_linear = 1
        in_use_player.stop()

    elif fade_time > 0:
        var current_player: AudioStreamPlayer = in_use_player
        current_player.volume_linear = 1
        var fade: Tween = create_tween()
        fade.tween_property(current_player, "volume_linear", 0, fade_time)
        fade.tween_callback(func(): current_player.stop())
        fade.play()



func crossfade_music(new_track: AudioStream, fade_time: float) -> void:
    stop_music(fade_time / 2)
    in_use_player = _player2 if in_use_player == _player1 else _player1
    play_music(new_track, fade_time / 2)



func pause_music(pause: bool) -> void:
    in_use_player.stream_paused = pause



func set_music_loop(do_loop: bool) -> void:
    if in_use_player.stream == null && do_loop:
        printerr("Cannot loop track if no audio stream is provided")
        loop_track = false
    else: loop_track = do_loop



func _on_track_finished() -> void:
    if loop_track:
        in_use_player.play()

    elif loop_playlist:
        playlist_index = 0 if playlist_index + 1 >= playlist.size() else playlist_index
        play_playlist(playlist_index, playlist_fade_time)




func _on_options_music_db_changed(linear: float) -> void:
    AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(Constants.AudioBus_DefaultMusic), linear)



func _on_options_sfx_db_changed(linear: float) -> void:
    AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(Constants.AudioBus_DefaultSFX), linear)
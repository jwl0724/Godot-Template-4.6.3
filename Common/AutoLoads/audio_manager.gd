extends Node

## Private class to hold music player data
class _MusicPair:
    var p1: AudioStreamPlayer
    var p2: AudioStreamPlayer
    var using: AudioStreamPlayer
    func _init(player1: AudioStreamPlayer, player2: AudioStreamPlayer):
        p1 = player1
        p2 = player2
        using = p1


## Private class to hold sound effect player data (Note: expected that sound effects should be global sounds and not positional, like UI and such)
class _SoundsPool:
    var node: Node
    var audio_pool: Array[AudioStreamPlayer] = []

    func _init(parent: Node):
        node = parent

    func get_first_free() -> AudioStreamPlayer:
        var idx = audio_pool.find_custom(func(player: AudioStreamPlayer): return !player.playing)
        if idx != -1: return audio_pool[idx]

        var audio = AudioStreamPlayer.new()
        audio.bus = Constants.AudioBus.DefaultSFX
        audio_pool.append(audio)
        node.add_child(audio)
        return audio


# Private class to hold playlist data
class _Playlist:
    var tracks: Array[AudioStream] = []
    var index: int = 0
    var fade_start_time: float = 0 ## Fade time to stop the music
    var fade_stop_time: float = 0 ## Fade time to start the music
    var loop_list: bool = false ## Loop the entire list
    var loop_track: bool = false ## Loop the currently playing music



var sounds_pool: _SoundsPool = _SoundsPool.new(self)
var playlist: _Playlist = _Playlist.new()
var music_pair: _MusicPair

var currently_playing: AudioStream:
    get: return music_pair.using.stream



func _ready() -> void:
    # Setup audio players
    var p1 = AudioStreamPlayer.new()
    var p2 = AudioStreamPlayer.new()
    p1.bus = Constants.AudioBus.DefaultMusic
    p2.bus = Constants.AudioBus.DefaultMusic
    add_child(p1)
    add_child(p2)
    p1.finished.connect(_on_track_finished.bind(p1))
    p2.finished.connect(_on_track_finished.bind(p2))
    music_pair = _MusicPair.new(p1, p2)

# ---- SOUND EFFECTS FUNCTIONS ----
## Plays an sound effect clip immediately, throws an error if lower pitch is higher than upper
func play_sound(clip: AudioStream, lower_pitch: float = 1, upper_pitch: float = 1):
    if lower_pitch > upper_pitch:
        printerr("The provided lower pitch: %f is greater than the provided upper pitch: %f" % [lower_pitch, upper_pitch])
        return

    var audio = sounds_pool.get_first_free()
    audio.stream = clip
    audio.pitch_scale = randf_range(lower_pitch, upper_pitch)
    audio.play()


# ---- PLAYLIST FUNCTIONS ----
## Adds an audio stream to a playlist, duplicate streams cannot be added
func add_to_playlist(stream: AudioStream) -> void:
    var music_index = playlist.tracks.find(stream)
    if music_index != -1: push_warning("%s is already in the playlist and has not been added, is this intended behavior?" % stream.resource_name)
    else: playlist.tracks.append(stream)


## Removes an audio stream to the playlist, throws an error if the stream was not found
func remove_from_playlist(stream: AudioStream) -> void:
    var music_index = playlist.tracks.find(stream)
    if music_index == -1: printerr("%s was not found in the playlist and cannot be remove" % str(stream))
    else: playlist.tracks.remove_at(music_index)


## Clears all audio streams in the playlist
func clear_playlist() -> void:
    playlist.tracks.clear()
    playlist.index = 0
    playlist.loop_list = false


## Shuffles the order of the playlist
func shuffle_playlist() -> void:
    playlist.tracks.shuffle()


## Set the playlist to loop in the current order, throws an error if the current playlist is empty
func set_playlist_loop(do_loop: bool) -> void:
    if playlist.tracks.size() == 0 && do_loop:
        printerr("Cannot loop an empty playlist")
        playlist.loop_list = false
    else: playlist.loop_list = do_loop


## Plays the audio stream at the provided index, throws error if the index is out of bounds
func play_playlist(index: int, stop_fade: float = 0, start_fade: float = 0) -> void:
    if index >= playlist.tracks.size():
        printerr("The provided index %d is out of range of the playlist of size %d" % [index, playlist.tracks.size()])
        return
    playlist.fade_stop_time = stop_fade
    playlist.fade_start_time = start_fade
    crossfade_music(playlist.tracks[index], playlist.fade_stop_time, playlist.fade_start_time)


## Immediately jump to the next track in the playlist
func play_next_playlist(stop_fade: float = 0, start_fade: float = 0):
    playlist.index += 1
    if playlist.index >= playlist.tracks.size(): playlist.index = 0
    play_playlist(playlist.index, stop_fade, start_fade)

# ---- BASE MUSIC FUNCTIONS ----
## Plays a track with a fade time, does nothing if the track is already playing the track provided
func play_music(stream: AudioStream, fade_time: float = 0) -> void:
    if music_pair.using.stream == stream && music_pair.using.playing: return

    if fade_time == 0:
        music_pair.using.volume_linear = 1
        music_pair.using.stream = stream
        music_pair.using.play()

    elif fade_time > 0:
        var current_player: AudioStreamPlayer = music_pair.using
        current_player.stream = stream
        current_player.volume_linear = 0
        current_player.play()
        var fade: Tween = create_tween()
        fade.tween_property(current_player, "volume_linear", 1, fade_time)
        fade.play()


## Stops a track with a fade time
func stop_music(fade_time: float = 0) -> void:
    if fade_time == 0:
        music_pair.using.volume_linear = 1
        music_pair.using.stop()

    elif fade_time > 0:
        var current_player: AudioStreamPlayer = music_pair.using
        current_player.volume_linear = 1
        var fade: Tween = create_tween()
        fade.tween_property(current_player, "volume_linear", 0, fade_time)
        fade.tween_callback(func(): current_player.stop())
        fade.play()


## Cross fade 2 tracks
func crossfade_music(new_track: AudioStream, stop_fade: float, start_fade: float) -> void:
    stop_music(stop_fade)
    music_pair.using = music_pair.p2 if music_pair.using == music_pair.p1 else music_pair.p1
    play_music(new_track, start_fade)


## Pauses the track
func pause_music(pause: bool) -> void:
    music_pair.using.stream_paused = pause


## Set the track to loop, throws an error if the player has no audio stream to loop
func set_music_loop(do_loop: bool) -> void:
    if music_pair.using.stream == null && do_loop:
        printerr("Cannot loop track if no audio stream is provided")
        playlist.loop_track = false
    else: playlist.loop_track = do_loop



func _on_track_finished(player: AudioStreamPlayer) -> void:
    if player != music_pair.using: return
    if playlist.loop_track:
        music_pair.using.play()

    elif playlist.loop_list:
        playlist.index += 1
        if playlist.index >= playlist.tracks.size(): playlist.index = 0
        play_playlist(playlist.index, playlist.fade_stop_time, playlist.fade_start_time)


# ---- VOLUME ADJUSTING ----
## Sets the bus volume using percentage between 0 to 1
func set_bus_volume_linear(bus_name: String, linear: float) -> void:
    var bus_index = AudioServer.get_bus_index(bus_name)
    if bus_index != -1: AudioServer.set_bus_volume_linear(bus_index, linear)
    else: printerr("The bus %s was not found in the list of bus names" % bus_name)



## Sets the bus volume using DB values
func set_bus_volume_db(bus_name: String, db: float):
    var bus_index = AudioServer.get_bus_index(bus_name)
    if bus_index != -1: AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db)
    else: printerr("The bus %s was not found in the list of bus names" % bus_name)

extends Node

signal loading_finished(uid: String) # Emitted when loading is complete
signal _instantiate_finished(node: Node, worker_thread: Thread) # Emitted when instantiation phase is complete, used internally

var uid_key: Dictionary[String, PackedScene] = {} # Loading progress: null -> packed scene


# Checks all loading instances
func _process(_delta: float):
    for uid: String in uid_key.keys():
        if uid_key[uid] != null: continue
        var status = ResourceLoader.load_threaded_get_status(uid)
        if status == ResourceLoader.THREAD_LOAD_LOADED:
            uid_key[uid] = ResourceLoader.load_threaded_get(uid)
            loading_finished.emit(uid)


## Starts the loading pipeline
func load_scene(scene_uid: String) -> void:
    uid_key[scene_uid] = null
    ResourceLoader.load_threaded_request(scene_uid)


## Gets the packed scene from UID, returns null if the scene is not ready yet
func get_packed_from_uid(uid: String) -> PackedScene:
    if !uid_key.has(uid):
        printerr("Unable to find %s in the UID key" % uid)
        return null
    if uid_key[uid] is PackedScene:
        var packed = uid_key.get(uid)
        uid_key.erase(uid)
        return packed
    else: return null



## Called by loading screens, gets the progress of the loading
func get_load_progress(scene_uid: String) -> float:
    if !uid_key.has(scene_uid):
        printerr("Unable to find %s in the UID key" % scene_uid)
        return 0.
    var progress_array = []
    ResourceLoader.load_threaded_get_status(scene_uid, progress_array)
    return progress_array[0]


## Instantiate a packed scene in a separate thread, optional call if needed (Expected to be called after getting packed)
func thread_instantiate(packed: PackedScene) -> Node:
    var thread = Thread.new()
    thread.start(_instantiate_work.bind(packed, thread))

    var node = null # Wait for the finished signal and check if it's the correct worker thread
    while node == null:
        var signal_args = await _instantiate_finished
        if signal_args[1] == thread: node = signal_args[0]
    return node


# Thread work
func _instantiate_work(packed: PackedScene, self_thread: Thread) -> void:
    var scene = packed.instantiate()
    _post_instantiate_work.call_deferred(scene, self_thread)


# Thread cleanup
func _post_instantiate_work(scene: Node, thread: Thread) -> void:
    thread.wait_to_finish()
    _instantiate_finished.emit(scene, thread)
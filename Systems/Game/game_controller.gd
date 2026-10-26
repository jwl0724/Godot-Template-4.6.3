extends Node
class_name GameController

## The node in which running scenes are added to (Could be 2D or 3D)
@export var running_node: Node = null

@export_group("Dev Tools")
@export var debug_mode: bool = false
@export var debug_scene: PackedScene = null


## Changes the scene immediately without a loading screen
func direct_change_scenes(new_scene: PackedScene) -> void:
    if !_free_current_running(): return
    running_node.add_child(new_scene.instantiate())



func thread_change_scenes(scene_uid: String, thread_instantiate: bool = false):
    if !_free_current_running(): return
    Load.load_scene(scene_uid)

    # Load off thread
    var packed: PackedScene = null
    while packed == null:
        await Load.loading_finished
        packed = Load.get_packed_from_uid(scene_uid)
    if !thread_instantiate:
        direct_change_scenes(packed)
        return

    # Call for threaded instantiation
    var node = await Load.thread_instantiate(packed)
    running_node.add_child(node)


## Returns true if succesfully removed, false otherwise
func _free_current_running() -> bool:
    if running_node.get_child_count() > 1: # Error case, more than 1 child node
        printerr("Running node should not have more than one child, multiple scenes were added to running")
        return false
    elif running_node.get_child_count() == 1: # Normal case
        running_node.get_child(0).queue_free()
        return true
    else: return true # No child present
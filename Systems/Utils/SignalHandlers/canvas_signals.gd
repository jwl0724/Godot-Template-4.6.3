extends Node
class_name CanvasSignalHandler

@export var controller: GameController = null



func _ready():
    SignalBus.canvas.gui_add_element.connect(_on_gui_add)
    SignalBus.canvas.gui_free_element.connect(_on_gui_free)
    SignalBus.canvas.gui_clear.connect(_on_gui_clear)
    SignalBus.canvas.pause_show.connect(_on_pause_signal.bind(true))
    SignalBus.canvas.pause_hide.connect(_on_pause_signal.bind(false))
    SignalBus.canvas.debug_show.connect(_on_debug_signal.bind(true))
    SignalBus.canvas.debug_hide.connect(_on_debug_signal.bind(false))



func _on_gui_add(node: Control):
    if controller.gui_layer.find_child(node.name):
        printerr("Trying to add duplicate GUI element %s with name %s" % [node, node.name])
        return
    controller.gui_layer.add_child(node)



func _on_gui_free(node: Control):
    var gui_to_remove := controller.gui_layer.find_child(node.name)
    if gui_to_remove: gui_to_remove.queue_free()
    else: printerr("Could not find GUI element %s with name %s" % [node, node.name])



func _on_gui_clear():
    for child in controller.gui_layer.get_children():
        child.queue_free()



func _on_pause_signal(show: bool):
    controller.pause_layer.visible = show



func _on_debug_signal(show: bool):
    controller.debug_layer.visible = show
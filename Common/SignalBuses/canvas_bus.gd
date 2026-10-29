extends RefCounted
class_name CanvasBus
@warning_ignore_start("unused_signal")

signal transition_uncover(type: BasicTransitions.Type, time: float) ## Transition to show the screen
signal transition_cover(type: BasicTransitions.Type, time: float) ## Transition to cover the screen

signal gui_add_element(node: Control)
signal gui_free_element(node: Control)
signal gui_clear()

signal pause_show()
signal pause_hide()

signal debug_show()
signal debug_hide()
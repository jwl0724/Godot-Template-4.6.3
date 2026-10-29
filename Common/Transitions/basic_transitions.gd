extends ColorRect
class_name BasicTransitions

enum Type { FADE, SLIDE_L, SLIDE_R, SCALE_IN, SCALE_OUT }

@onready var animation: AnimationPlayer = $Animation



func _ready():
    SignalBus.canvas.transition_cover.connect(_on_transition_cover)
    SignalBus.canvas.transition_uncover.connect(_on_transition_uncover)



func _on_transition_cover(type: Type, time: float):
    pass



func _on_transition_uncover(type: Type, time: float):
    pass
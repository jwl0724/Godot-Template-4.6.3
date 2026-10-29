extends ColorRect
class_name BasicTransitions

enum Type { FADE, SLIDE_L, SLIDE_R, SCALE }

const fade_anim := "fade"
const slide_l_anim := "slide_left"
const slide_r_anim := "slight_right"
const scale_anim := "scale"

@onready var animation: AnimationPlayer = $Animation



func _ready():
    SignalBus.canvas.transition_cover.connect(_on_transition_cover)
    SignalBus.canvas.transition_uncover.connect(_on_transition_uncover)



func _on_transition_cover(type: Type, time: float):
    visible = true
    animation.speed_scale = 1 / time
    if type == Type.FADE: handle_fade(false)
    elif type == Type.SLIDE_L: handle_slide_left(false)
    elif type == Type.SLIDE_R: handle_slide_right(false)
    elif type == Type.SCALE: handle_scale(false)



func _on_transition_uncover(type: Type, time: float):
    visible = true
    animation.speed_scale = 1 / time
    if type == Type.FADE: handle_fade(true)
    elif type == Type.SLIDE_L: handle_slide_left(true)
    elif type == Type.SLIDE_R: handle_slide_right(true)
    elif type == Type.SCALE: handle_scale(true)



func handle_fade(cover: bool):
    if cover: animation.play_backwards(fade_anim)
    else: animation.play(fade_anim)

    if cover: return
    await animation.animation_finished
    visible = false




func handle_slide_left(cover: bool):
    if cover: animation.play_backwards(slide_r_anim)
    else: animation.play(slide_l_anim)

    if cover: return
    await animation.animation_finished
    visible = false



func handle_slide_right(cover: bool):
    if cover: animation.play_backwards(slide_l_anim)
    else: animation.play(slide_r_anim)

    if cover: return
    await animation.animation_finished
    visible = false



func handle_scale(cover: bool):
    if cover: animation.play_backwards(scale_anim)
    else: animation.play(scale_anim)

    if cover: return
    await animation.animation_finished
    visible = false
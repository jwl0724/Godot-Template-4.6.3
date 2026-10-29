extends ColorRect
class_name BasicTransitions

enum Type { FADE, SLIDE_L, SLIDE_R, SLIDE_U, SLIDE_D, SCALE }

const fade_anim := "fade"
const slide_l_anim := "slide_left"
const slide_r_anim := "slide_right"
const slide_u_anim := "slide_up"
const slide_d_anim := "slide_down"
const scale_anim := "scale"

@onready var animation: AnimationPlayer = $Animation



func _ready():
    visible = false
    SignalBus.canvas.transition_cover.connect(_on_transition_cover)
    SignalBus.canvas.transition_uncover.connect(_on_transition_uncover)



func _on_transition_cover(type: Type, time: float):
    _reset_transition()
    animation.speed_scale = 1 / time
    if type == Type.FADE: _handle_fade(true)
    elif type == Type.SLIDE_L: _handle_slide_left(true)
    elif type == Type.SLIDE_R: _handle_slide_right(true)
    elif type == Type.SLIDE_U: _handle_slide_up(true)
    elif type == Type.SLIDE_D: _handle_slide_down(true)
    elif type == Type.SCALE: _handle_scale(true)



func _on_transition_uncover(type: Type, time: float):
    _reset_transition()
    animation.speed_scale = 1 / time
    if type == Type.FADE: _handle_fade(false)
    elif type == Type.SLIDE_L: _handle_slide_left(false)
    elif type == Type.SLIDE_R: _handle_slide_right(false)
    elif type == Type.SLIDE_U: _handle_slide_up(false)
    elif type == Type.SLIDE_D: _handle_slide_down(false)
    elif type == Type.SCALE: _handle_scale(false)



func _handle_fade(cover: bool):
    if cover: animation.play_backwards(fade_anim)
    else: animation.play(fade_anim)
    _set_invisible_after_anim(cover)



func _handle_slide_up(cover: bool):
    if cover: animation.play_backwards(slide_d_anim)
    else: animation.play(slide_u_anim)
    _set_invisible_after_anim(cover)



func _handle_slide_down(cover: bool):
    if cover: animation.play_backwards(slide_u_anim)
    else: animation.play(slide_d_anim)
    _set_invisible_after_anim(cover)



func _handle_slide_left(cover: bool):
    if cover: animation.play_backwards(slide_r_anim)
    else: animation.play(slide_l_anim)
    _set_invisible_after_anim(cover)



func _handle_slide_right(cover: bool):
    if cover: animation.play_backwards(slide_l_anim)
    else: animation.play(slide_r_anim)
    _set_invisible_after_anim(cover)



func _handle_scale(cover: bool):
    if cover: animation.play_backwards(scale_anim)
    else: animation.play(scale_anim)
    _set_invisible_after_anim(cover)



func _reset_transition():
    visible = true
    animation.play("RESET")
    animation.advance(0)



func _set_invisible_after_anim(cover: bool):
    if cover: return
    await animation.animation_finished
    visible = false
extends Node
class_name MenuButtonSounds
# This class handles menu button sound effects, data should not be altered while running (everything should be set on launch then never touched)

const theme_type: String = "Button"
const pressed_criteria: String = "font_pressed_color"
const hovered_criteria: String = "font_hover_color"

## Input the associated pressed font color from the theme as the color, and the pressed sound effect as the audio stream
@export var color_sound_pairs_pressed: Array[ThemeColorSoundPair] = []
## Input the associated hover font color from the theme as the color, and the hover sound effect as the audio stream
@export var color_sound_pairs_hovered: Array[ThemeColorSoundPair] = []

var pressed_key: Dictionary[Color, AudioStream] = {}
var hovered_key: Dictionary[Color, AudioStream] = {}



func _ready():
    # Add pairs to key
    for pair in color_sound_pairs_pressed:
        pressed_key[pair.theme_color] = pair.sfx
    for pair in color_sound_pairs_hovered:
        hovered_key[pair.theme_color] = pair.sfx

    # Don't need to connect to signal if nothing is in the keys
    if pressed_key.size() == 0 && hovered_key.size() == 0: return
    get_tree().node_added.connect(_try_attach_sound)




func _try_attach_sound(node: Node):
    if node is not Button: return

    var button = node as Button
    var font_pressed_color: Color = button.get_theme_color(pressed_criteria, theme_type)
    var font_hovered_color: Color = button.get_theme_color(pressed_criteria, theme_type)

    if pressed_key.get(font_pressed_color) == font_pressed_color:
        button.pressed.connect(func(): Audio.play_sound(pressed_key.get(font_pressed_color)))
    if hovered_key.get(font_hovered_color) == font_hovered_color:
        button.mouse_entered.connect(func(): Audio.play_sound(hovered_key.get(font_hovered_color)))
    
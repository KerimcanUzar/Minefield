extends Control

var flagged = false
var mined = false
var covered = true
var questioned = false
signal revealed
signal lost
var long_press = Timer.new()
var long = false


func _ready():
    self.add_child(long_press)
    long_press.connect("timeout", self, "long_pressed")


func land_mine():
    mined = true
    $Hole/Mine.show()


func reveal():
    $Cover.hide()
    covered = false
    var s = 0
    for tile in surround():
        if tile.mined:
            s += 1
    if mined:
        emit_signal("lost")
        game_over()
    else:
        emit_signal("revealed")
        if s:
            $Hole/Number.show()
            $Hole/Number.text = str(s)
            s = 0
        else:
            $Hole/Number.hide()
            for tile in surround():
                if tile.covered:
                    tile.reveal()


func surround():
    var surrounds = []
    var offsets = [
        (Vector2.UP + Vector2.LEFT) * 64 * rect_scale,
        (Vector2.UP) * 64 * rect_scale,
        (Vector2.UP + Vector2.RIGHT) * 64 * rect_scale,
        (Vector2.LEFT) * 64 * rect_scale,
        (Vector2.RIGHT) * 64 * rect_scale,
        (Vector2.DOWN + Vector2.LEFT) * 64 * rect_scale,
        (Vector2.DOWN) * 64 * rect_scale,
        (Vector2.DOWN + Vector2.RIGHT) * 64 * rect_scale
        ]
    for i in offsets:
        for tile in get_parent().tiles:
            if tile is Control:
                if tile.rect_position == rect_position + i:
                    surrounds.append(tile)
    return surrounds


func toggle_flag():
    if flagged:
        flagged = false
        questioned = true
        $Cover/Flag.hide()
        $Cover/Unknown.show()
    elif questioned:
        questioned = false
        $Cover/Unknown.hide()
    else:
        flagged = true
        $Cover/Flag.show()


func game_over():
    get_tree().get_root().get_node("/root/Game").dead = true
    for tile in get_parent().tiles:
        if tile is Control and !tile is PopupDialog:
            tile.mouse_filter = MOUSE_FILTER_IGNORE
            if tile.mined:
                tile.get_child(0).hide()
                tile.get_child(1).hide()
                tile.get_child(2).show()
                tile.get_child(2).play()


func _on_Explosion_animation_finished():
    $Explosion.hide()
    $Exploded.show()


func _on_Control_gui_input(event):
    if event is InputEventScreenTouch:
        if event.is_pressed():
            if long_press.is_stopped():
                long_press.start(0.75)
        elif event.is_pressed() == false:
            long_press.stop()
            if not (flagged or questioned) and $Cover.visible:
                if get_tree().get_root().get_node("/root/Game").dead == false:
                    reveal()
        elif event is InputEventScreenDrag:
            long_press.stop()
    elif event.is_action_pressed("right_click"):
        toggle_flag()


#func _on_Control_gui_input(event):
#    if event is InputEventMouseButton:
#        if event.is_action_pressed("left_click"):
#            if long_press.is_stopped():
#                long_press.start(0.75)
#        elif event.is_action_released("left_click"):
#            long_press.stop()
#            if not (flagged or questioned) and $Cover.visible:
#                if get_tree().get_root().get_node("/root/Game").dead == false:
#                    reveal()
#        elif event.is_action_pressed("right_click"):
#            toggle_flag()
#        elif event is InputEventScreenDrag:
#            long_press.stop()

func long_pressed():
    toggle_flag()

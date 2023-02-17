extends Control

var rng = RandomNumberGenerator.new()
var col = 8
var row = 14
var mines = 11
var opened = 0
var dead = false
var Tile = load("res://Tile.tscn")
var tiles
var tile


func _ready():
    pass


func start_game(difficulty, scale):
    for i in get_children():
        if i is Control and !i is PopupDialog:
            remove_child(i)
    col = [8, 11, 16][difficulty - 2]
    row = [14, 20, 28][difficulty - 2]
    mines = [11, 29, 99][difficulty - 2]
    rng.randomize()
    for r in row:
        for c in col:
            var t = Tile.instance()
            add_child(t)
            t.rect_position = Vector2(c, r) * 64 * scale
            t.rect_scale = Vector2(scale, scale)
            t.connect("revealed", self, "reveal_sound")
            t.connect("lost", self, "lost_sound")
    tiles = get_children()
    land_mines()


func land_mines():
    var n = 0
    while n < mines:
        tile = tiles[rng.randi() % len(tiles)]
        if tile is Control and !tile is PopupDialog:
            if not tile.mined:
                tile.land_mine()
                n += 1


func reveal_sound():
    opened = 0
    if not $RevealSFX.playing:
        $RevealSFX.play()
    for t in tiles:
        if t is Control and !t is PopupDialog:
            if t.get_node("Cover").visible == false:
                opened += 1
        if opened == col * row - mines:
            $Popup.show()
            $Popup/GameOverLbl.text = "YOU WON"


func lost_sound():
    $Popup.show()
    if not $ExplosionSFX.playing:
        $ExplosionSFX.play()


func _on_SmallBtn_pressed():
    $RevealSFX.play()
    start_game(2, 2)
    get_parent().get_node("Menu").hide()


func _on_MediumBtn_pressed():
    $RevealSFX.play()
    start_game(3, 1.5)
    get_parent().get_node("Menu").hide()


func _on_LargeBtn_pressed():
    $RevealSFX.play()
    start_game(4, 1)
    get_parent().get_node("Menu").hide()


func _on_QuitBtn_pressed():
    get_tree().quit()


func _on_MenuBtn_pressed():
    opened = 0
    get_tree().get_root().get_node("/root/Game").dead = false
    $Popup.hide()
    get_parent().get_node("Menu").show()

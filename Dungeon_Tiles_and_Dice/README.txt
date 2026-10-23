DUNGEON TILES + DICE - READY FOR GODOT 4

TILES (29, from your labeled tileset - exact pixel art, nothing redrawn)
tiles/32/     native pixel size (32x32)  - use these for pixel-perfect games
tiles/128/    4x crisp (128x128)
tiles/256/    8x crisp (256x256)
tiles/atlas/  all 29 in one grid image (9 columns x 5 rows)
tiles/tileset_128.tres  ready Godot TileSet (uses atlas_128)   |  tileset_32.tres uses atlas_32
tiles/tile_data.json    name -> set + atlas coords
Names: start, enemy, heal, chest, empty, boss, trap, bonus, skip | portal, shop, key, potion, mystery |
       fire, poison, ice, lightning, bomb | slime, bat, goblin, ghost, evil_eye | sword, shield, scroll, gold, hourglass

DICE (all 6 faces)
dice/die_face_1.png ... die_face_6.png   transparent, same size
dice/die_spritesheet.png                 six faces in one row
dice/die_spriteframes.tres               animations: face_1 ... face_6 and "roll" (loops through the faces)
dice/die_roll_preview.gif                preview of the roll

HOW TO USE
1. Copy "tiles" and "dice" into  res://assets/   (so you get res://assets/tiles/... and res://assets/dice/...)
2. Project Settings > Rendering > Textures > Default Texture Filter = Nearest.
3. TileMapLayer > Tile Set = tiles/tileset_128.tres.  Dice: AnimatedSprite2D > Sprite Frames = dice/die_spriteframes.tres
   Roll:  $Die.play("roll")   then after a moment:  $Die.play("face_%d" % result)

NOTE: your image only showed the 5 face of the die. The other five faces were built from that same die
(same body, outline and pip shape) with the pips moved to the standard positions.

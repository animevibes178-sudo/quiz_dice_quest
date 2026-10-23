PIXEL KING - READY FOR GODOT 4
Same art as your sheet. Cut out, transparent background, upscaled 4x, sharpened and cleaned. Nothing redrawn.

HOW TO USE
1. Copy the "king" folder into  res://assets/   (you get res://assets/king/...)
2. Project Settings > Rendering > Textures > Default Texture Filter = Nearest.
3. Add an AnimatedSprite2D, set Sprite Frames = king/king_spriteframes.tres, then play "idle", "talking" or "walk".

FILES
king/frames/     every frame as a same-size transparent PNG (feet aligned, no jumping between frames)
king/trimmed/    same frames cropped tight
king/king_<anim>_spritesheet.png   all frames of an animation in one row (cell size in king.json)
king/king_spriteframes.tres        ready SpriteFrames: idle (4), talking (4), walk (6), all looping
king/king_<anim>_preview.gif       quick previews

NOTES
- Walk faces RIGHT. In code use  $AnimatedSprite2D.flip_h = true  to walk left.
- Idle and talking face the front/side-front; walk is a side view.

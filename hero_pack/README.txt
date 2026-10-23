ONE-SWORD HERO - READY FOR GODOT 4
Same art as your sheet. Only the usable parts: all animation frames, the 5 power effects, the sword and a big portrait.
(Labels, borders and the color palette were left out.) Cut out, transparent, 4x, sharpened and cleaned. Nothing redrawn.

HOW TO USE
1. Copy the "hero" folder into  res://assets/   (you get res://assets/hero/...)
2. Project Settings > Rendering > Textures > Default Texture Filter = Nearest.
3. AnimatedSprite2D > Sprite Frames = hero/hero_spriteframes.tres
   Animations: idle(8) walk(8) run(9) jump(6) attack(8) skill(4) hurt(5) death(4) turn(4)
   idle/walk/run loop; the others play once.

FILES
hero/frames/<anim>/        same-size transparent frames (feet aligned, jump height kept)
hero/trimmed/<anim>/       same frames cropped tight
hero/spritesheets/         one strip per animation
hero/previews/             GIF previews
hero/vfx/                  slash, dash, energy_burst, aura, power_up (separate effects to spawn in game)
hero/hero_portrait.png     big portrait for menus / dialogue
hero/hero_sword.png        the sword icon
hero/hero.json             frame size, fps and file lists

NOTES
- Hero faces RIGHT. For left use  $AnimatedSprite2D.flip_h = true
- The attack and skill frames already include the glowing slash/aura in the frame.
  The vfx/ files are the same effects as stand-alone images if you want to spawn them yourself.
- In Godot: call play("attack") then wait for animation_finished to return to idle.

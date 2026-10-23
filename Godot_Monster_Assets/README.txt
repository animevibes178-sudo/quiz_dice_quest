QUIZ DICE QUEST - MONSTER & BOSS ASSETS (READY FOR GODOT 4)
Same art as your sheet. Cut out, background removed, upscaled 4x, then sharpened and cleaned (crisp edges, flat colors). Nothing redrawn.

HOW TO USE IN GODOT
1. Copy the "monsters", "effects" and "weapons" folders into  res://assets/   (so you get res://assets/monsters/goblin/...)
2. Project Settings > Rendering > Textures > Default Texture Filter = Nearest.
3. Add an AnimatedSprite2D, set Sprite Frames = monsters/<name>/<name>_spriteframes.tres, then play "idle", "attack", "hurt", "death"...
   (If you use a different folder than res://assets/monsters, just re-drag the frames into a new SpriteFrames.)

FOLDERS
monsters/<name>/frames/      every state as a same-size transparent PNG (feet aligned, so no jumping between states)
monsters/<name>/trimmed/     same sprites cropped tight
monsters/<name>/<name>_portrait.png   large full-art portrait (for battle screens / cards)
monsters/<name>/<name>_spritesheet.png  all states in one row (cell size is in monsters.json "frame_size")
monsters/<name>/<name>_spriteframes.tres  ready Godot SpriteFrames (idle, walk, run, attack, jump, skill, hurt, death, turn)
monsters/<name>/<name>_preview.gif    quick preview
effects/   5 boss power effects
weapons/   9 attack items
monsters.json   HP / ATK / DEF, boss flag, frame size and file list for every monster

NOTE: the original sheet has ONE pose per action (not multi-frame cycles). Goblin, bat and slime have 2 death poses
(death_1, death_2). For smoother idle/walk, add a small bob/scale tween with AnimationPlayer.

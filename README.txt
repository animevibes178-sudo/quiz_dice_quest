QUIZ DICE QUEST - READY-TO-USE ASSETS
(Same art as your pack - nothing redrawn. Only cut out, cleaned and organized.)

Backgrounds_Clean/        Full scene, frame + caption removed, 2x smoother upscale (best quality, keeps full width)
Backgrounds_1920x1080/    Same scenes, center-cropped to exact 1920x1080 for full-screen use
Princess_Frames/<anim>/   Every animation frame as its own transparent PNG (idle, walk, run, jump, talk, hurt)
                          + <anim>_spritesheet.png = all frames in one horizontal strip (same cell size per frame)
Princess_Expressions/     8 portraits (normal, happy, sad, surprised, angry, worried, shy, blushing), same size each
                          + expressions_spritesheet_4x2.png
Princess_Poses/           sit, sleep, flower, heart, back view (transparent)
Props/                    crown, jeweled crown, bow, heart, flower, speech bubble, banners, chest, lantern,
                          planter, signpost, arch, pillar, bushes (transparent)
Preview_GIFs/             quick animated previews of each animation

GODOT TIPS
- Project Settings > Rendering > Textures > Default Texture Filter = Nearest (keeps pixels crisp).
- AnimatedSprite2D: use the frame PNGs, or Sprite2D/AnimatedSprite2D with the spritesheet (hframes = frame count).
- Frame cell sizes: idle 240x340, walk 240x332, run 252x320, jump 240x424, talk 232x336, hurt 324x344.
- Jump/hurt keep the original vertical position inside the cell, so the jump height is preserved.

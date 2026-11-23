; ============================================================================
; DrawSprite - draw a 16x16 (or 16x32) picture, clipped at every screen edge
; In (stack): x, y, address of sprite data, flags      (ret 8)
;   flags bit 0 = mirror (face left), bit 1 = tall (32 rows)
; Sprite data: one character per pixel. '.' = transparent, '1'..'9' and
; 'A'..'F' = palette colours 1..15.
; Registers changed: none
; ============================================================================
DrawSprite:
    push bp
    mov  bp, sp
    pusha
    push es
    mov  ax, [bp+10]
    mov  [spx], ax
    mov  ax, [bp+8]
    mov  [spy], ax
    mov  si, [bp+6]
    mov  ax, [bp+4]
    mov  [spflags], ax
    mov  ax, [drawseg]
    mov  es, ax
    mov  cx, 16
    test word [spflags], 2
    jz   .rowloop
    mov  cx, 32
.rowloop:
    mov  bx, [spy]
    cmp  bx, SCREEN_H
    jae  .nextrow                   ; off the top or bottom: skip the row
    mov  di, bx
    shl  di, 8
    shl  bx, 6
    add  di, bx                     ; DI = row * 320
    xor  bx, bx                     ; BX = sprite column 0..15
.col:
    mov  dx, [spx]
    add  dx, bx                     ; DX = screen x of this pixel
    cmp  dx, SCREEN_W
    jae  .skip                      ; off the left or right edge
    mov  ax, bx
    test word [spflags], 1
    jz   .norm
    mov  ax, 15
    sub  ax, bx                     ; mirrored: read the row backwards
.norm:
    push si
    add  si, ax
    mov  al, [si]
    pop  si
    cmp  al, '.'
    je   .skip
    sub  al, '0'
    cmp  al, 9
    jbe  .ok
    sub  al, 7                      ; 'A'..'F' -> 10..15
.ok:
    mov  bp, dx
    mov  [es:bp+di], al             ; based-indexed addressing
.skip:
    inc  bx
    cmp  bx, 16
    jb   .col
.nextrow:
    inc  word [spy]
    add  si, 16
    LOOPFAR .rowloop
    pop  es
    popa
    pop  bp
    ret  8

; ============================================================================
; DrawEntities - goombas, koopas, shells and mushrooms that are on screen
; ============================================================================
DrawEntities:
    pusha
    mov  si, enemies
    mov  cx, ENEMY_MAX
.next:
    cmp  byte [si+E_TYPE], 0
    je   .adv
    call DrawOneEntity
.adv:
    add  si, E_SIZE
    dec  cx
    jnz  .next
    popa
    ret

; DrawOneEntity - draw record SI if it is on screen
DrawOneEntity:
    pusha
    mov  ax, [si+E_X]
    sub  ax, [cam_x]                ; screen x = world x - camera x
    cmp  ax, -16
    jle  .out
    cmp  ax, SCREEN_W
    jge  .out
    xor  dx, dx                     ; flags
    mov  bx, spr_goomba
    cmp  byte [si+E_TYPE], 3
    je   .mush
    cmp  byte [si+E_TYPE], 2
    je   .koopa
    cmp  byte [si+E_STATE], 2
    jne  .gwalk
    mov  bx, spr_goomba_flat
    jmp  .draw
.gwalk:
    mov  dx, [frames]               ; flip the goomba every 8 frames = walking
    shr  dx, 3
    and  dx, 1
    jmp  .draw
.koopa:
    mov  bx, spr_koopa
    cmp  byte [si+E_STATE], 3
    jb   .kdir
    mov  bx, spr_shell
    jmp  .draw
.kdir:
    cmp  byte [si+E_DIR], 0
    jne  .draw
    mov  dx, 1                      ; sprite faces left, mirror to face right
    jmp  .draw
.mush:
    mov  bx, spr_mushroom
.draw:
    push ax
    push word [si+E_Y]
    push bx
    push dx
    call DrawSprite
.out:
    popa
    ret

; ============================================================================
; DrawMario - blink while invulnerable, otherwise draw the right pose
; ============================================================================
DrawMario:
    cmp  byte [mario_hidden], 0
    jne  .out
    cmp  word [invuln], 0
    jle  .vis
    test byte [frames], 2           ; blink while invulnerable
    jnz  .out
.vis:
    call DrawMarioBody
.out:
    ret

; DrawMarioBody - pose 0 stand, 1 run, 2 jump; small or super; mirrored if left
DrawMarioBody:
    pusha
    xor  bx, bx                     ; pose 0 = stand
    cmp  byte [on_ground], 0
    jne  .grounded
    mov  bx, 2                      ; pose 2 = jump (in the air)
    jmp  .pose
.grounded:
    cmp  word [vx], 0
    je   .pose
    test byte [frames], 4           ; moving: alternate stand / run
    jz   .pose
    mov  bx, 1
.pose:
    mov  si, spr_small_stand
    mov  ax, 256
    xor  di, di
    cmp  byte [form], 0
    je   .sel
    mov  si, spr_super_stand
    mov  ax, 512
    mov  di, 2                      ; tall sprite
.sel:
    mul  bx                         ; AX = pose * sprite size
    add  si, ax
    cmp  byte [facing], 0
    je   .noflip
    or   di, 1                      ; mirror when facing left
.noflip:
    mov  ax, [xpix]
    sub  ax, [cam_x]
    push ax
    push word [ypix]
    push si
    push di
    call DrawSprite
    popa
    ret

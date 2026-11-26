; EntityGravity - record SI falls 2 px per frame until it stands on a tile
EntityGravity:
    push ax
    push bx
    push dx
    mov  dx, [si+E_Y]
    add  dx, 16                     ; line under the feet
    mov  bx, [si+E_X]
    add  bx, 3
    SOLID bx, dx
    test al, al
    jnz  .ground
    mov  bx, [si+E_X]
    add  bx, 12
    SOLID bx, dx
    test al, al
    jnz  .ground
    add  word [si+E_Y], 2
    mov  byte [si+E_GND], 0
    cmp  word [si+E_Y], 192         ; fell into a pit: remove
    jl   .out
    mov  byte [si+E_TYPE], 0
    jmp  .out
.ground:
    and  dx, 0FFF0h
    sub  dx, 16
    mov  [si+E_Y], dx
    mov  byte [si+E_GND], 1
.out:
    pop  dx
    pop  bx
    pop  ax
    ret

; EntityWalk - horizontal movement of record SI: speed, walls, ledges,
; turning at other enemies, and what a sliding shell does to others.
EntityWalk:
    pusha
    mov  ax, 0080h                  ; goomba 0.5 px/frame
    cmp  byte [si+E_TYPE], 2
    jne  .t3
    mov  ax, 00C0h                  ; koopa 0.75
.t3:
    cmp  byte [si+E_TYPE], 3
    jne  .t4
    mov  ax, 0100h                  ; mushroom 1.0
.t4:
    cmp  byte [si+E_STATE], 4
    jne  .t5
    mov  ax, 0300h                  ; sliding shell 3.0
.t5:
    add  [si+E_FRAC], al            ; add the fraction, carry = extra pixel
    mov  al, ah
    mov  ah, 0
    adc  ax, 0                      ; AX = pixels to move this frame
    mov  bx, [si+E_X]               ; BX = old x (to undo the move)
    mov  di, bx
    cmp  byte [si+E_DIR], 0
    jne  .goleft
    add  di, ax
    jmp  .moved
.goleft:
    sub  di, ax
.moved:
    mov  [si+E_X], di
    mov  dx, [si+E_Y]
    add  dx, 8                      ; test the wall at half height
    mov  cx, di
    cmp  byte [si+E_DIR], 0
    jne  .w1
    add  cx, 15                     ; right edge
.w1:
    SOLID cx, dx
    test al, al
    jz   .nowall
    mov  [si+E_X], bx               ; wall: undo and turn around
    xor  byte [si+E_DIR], 1
    jmp  .out
.nowall:
    cmp  byte [si+E_TYPE], 2        ; walking Koopa does not walk off ledges
    jne  .others
    cmp  byte [si+E_STATE], 1
    jne  .others
    cmp  byte [si+E_GND], 0
    je   .others
    mov  dx, [si+E_Y]
    add  dx, 16
    SOLID cx, dx
    test al, al
    jnz  .others
    mov  [si+E_X], bx
    xor  byte [si+E_DIR], 1
    jmp  .out
.others:
    cmp  byte [si+E_TYPE], 3
    je   .out                       ; mushrooms ignore enemies
    mov  di, enemies
    mov  cx, ENEMY_MAX
.chk:
    cmp  di, si
    je   .nextj
    mov  al, [di+E_TYPE]
    cmp  al, 1
    je   .typeok
    cmp  al, 2
    jne  .nextj
.typeok:
    mov  al, [di+E_STATE]
    cmp  al, 1
    je   .live
    cmp  al, 3
    jne  .nextj
.live:
    call Overlap
    jnc  .nextj
    cmp  byte [si+E_STATE], 4
    jne  .turn
    mov  byte [di+E_TYPE], 0        ; sliding shell removes it: +500
    push word 500
    call AddScore
    jmp  .nextj
.turn:
    mov  [si+E_X], bx
    xor  byte [si+E_DIR], 1
    jmp  .out
.nextj:
    add  di, E_SIZE
    dec  cx
    jnz  .chk
.out:
    popa
    ret

; UpdateEntity - one record (SI): activation, removal, gravity, walking
UpdateEntity:
    pusha
    mov  al, [si+E_STATE]
    cmp  al, 0
    je   .waiting
    cmp  al, 2
    je   .flat
    mov  ax, [cam_x]
    sub  ax, 32
    cmp  [si+E_X], ax
    jl   .remove                    ; far left of the screen: remove
    call EntityGravity
    cmp  byte [si+E_TYPE], 0
    je   .out
    cmp  byte [si+E_STATE], 4       ; kick grace timer counts down
    jne  .nograce
    cmp  byte [si+E_TIMER], 0
    je   .nograce
    dec  byte [si+E_TIMER]
.nograce:
    cmp  byte [si+E_STATE], 3       ; stationary shell does not walk
    je   .out
    call EntityWalk
    jmp  .out
.waiting:                           ; starts walking when within one tile of the screen
    mov  ax, [si+E_X]
    sub  ax, [cam_x]
    cmp  ax, SCREEN_W+16
    jge  .out
    mov  byte [si+E_STATE], 1
    jmp  .out
.flat:                              ; flattened goomba disappears after ~1 s
    dec  byte [si+E_TIMER]
    jnz  .out
.remove:
    mov  byte [si+E_TYPE], 0
.out:
    popa
    ret

; UpdateEntities - step 4: loop over the whole table (indexed addressing)
UpdateEntities:
    pusha
    mov  si, enemies
    mov  cx, ENEMY_MAX
.next:
    cmp  byte [si+E_TYPE], 0
    je   .adv
    call UpdateEntity
.adv:
    add  si, E_SIZE
    dec  cx
    jnz  .next
    popa
    ret

; StompPoints - points from the stomp chain table; 11th stomp = extra life
StompPoints:
    push bx
    xor  bh, bh
    mov  bl, [stomp_chain]
    cmp  bl, 10
    jae  .oneup
    shl  bx, 1
    push word [chain_table+bx]
    call AddScore
    inc  byte [stomp_chain]
    jmp  .out
.oneup:
    call AddLife
.out:
    pop  bx
    ret

; KickShell - record SI is a stationary shell: kick it away from Mario (+400)
KickShell:
    push ax
    push word 400
    call AddScore
    mov  byte [si+E_STATE], 4
    mov  byte [si+E_TIMER], 8       ; shell ignores Mario for 8 frames
    mov  ax, [si+E_X]
    cmp  ax, [xpix]
    jg   .right
    mov  byte [si+E_DIR], 1
    jmp  .out
.right:
    mov  byte [si+E_DIR], 0
.out:
    pop  ax
    ret

; EnemyContact - Mario overlaps record SI: stomp from above, or side contact
EnemyContact:
    pusha
    cmp  word [vy], 0
    jle  .side                      ; not falling: cannot be a stomp
    mov  ax, [prev_ypix]
    add  ax, [mheight]              ; feet in the previous frame
    mov  bx, [si+E_Y]
    add  bx, 8
    cmp  ax, bx
    jg   .side                      ; feet were not above the upper half
    call StompEnemy
    jmp  .out
.side:
    call SideContact
.out:
    popa
    ret

; StompEnemy - Mario landed on record SI
StompEnemy:
    cmp  byte [si+E_STATE], 3
    je   .kick
    cmp  byte [si+E_STATE], 4
    je   .stopshell
    cmp  byte [si+E_TYPE], 1
    je   .flatten
    mov  byte [si+E_STATE], 3       ; Koopa becomes a shell
    jmp  .score
.flatten:
    mov  byte [si+E_STATE], 2       ; Goomba is flattened
    mov  byte [si+E_TIMER], 35
    jmp  .score
.stopshell:
    mov  byte [si+E_STATE], 3
.score:
    call StompPoints
    jmp  .bounce
.kick:
    call KickShell
.bounce:
    mov  word [vy], STOMP_V
    cmp  byte [keys+SC_SPACE], 0
    je   .b2
    mov  word [vy], STOMP_HI        ; Space held = higher bounce
.b2:
    mov  word [yfrac], 0
    mov  byte [on_ground], 0
    mov  ax, [si+E_Y]
    sub  ax, [mheight]
    mov  [ypix], ax                 ; feet on the enemy's head
    ret

; SideContact - Mario touched record SI from the side or below
SideContact:
    cmp  byte [si+E_STATE], 3
    je   .kick
    cmp  byte [si+E_STATE], 4
    jne  .hurt
    cmp  byte [si+E_TIMER], 0
    jne  .out                       ; kick grace time: shell ignores Mario
.hurt:
    call HurtMario
    ret
.kick:
    call KickShell
.out:
    ret

; ResolveEntities - step 5: Mario against every enemy / mushroom / coin
ResolveEntities:
    pusha
    mov  si, enemies
    mov  cx, ENEMY_MAX
.next:
    cmp  byte [si+E_TYPE], 0
    je   .adv
    cmp  byte [si+E_STATE], 0
    je   .adv
    cmp  byte [si+E_STATE], 2
    je   .adv
    call MarioOverlap
    jnc  .adv
    cmp  byte [si+E_TYPE], 3
    je   .mush
    call EnemyContact
    jmp  .adv
.mush:
    call CollectMushroom
.adv:
    add  si, E_SIZE
    dec  cx
    jnz  .next
    call CheckBodyTiles
    popa
    ret

EntityGravity:
    push ax
    push bx
    push dx
    mov  dx, [si+E_Y]
    add  dx, 16
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
    cmp  word [si+E_Y], 192
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

EntityWalk:
    pusha
    mov  ax, 0080h
    cmp  byte [si+E_TYPE], 2
    jne  .t3
    mov  ax, 00C0h
.t3:
    cmp  byte [si+E_TYPE], 3
    jne  .t4
    mov  ax, 0100h
.t4:
    cmp  byte [si+E_STATE], 4
    jne  .t5
    mov  ax, 0300h
.t5:
    add  [si+E_FRAC], al
    mov  al, ah
    mov  ah, 0
    adc  ax, 0
    mov  bx, [si+E_X]
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
    add  dx, 8
    mov  cx, di
    cmp  byte [si+E_DIR], 0
    jne  .w1
    add  cx, 15
.w1:
    SOLID cx, dx
    test al, al
    jz   .nowall
    mov  [si+E_X], bx
    xor  byte [si+E_DIR], 1
    jmp  .out
.nowall:
    cmp  byte [si+E_TYPE], 2
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
    je   .out
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
    mov  byte [di+E_TYPE], 0
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
    jl   .remove
    call EntityGravity
    cmp  byte [si+E_TYPE], 0
    je   .out
    cmp  byte [si+E_STATE], 4
    jne  .nograce
    cmp  byte [si+E_TIMER], 0
    je   .nograce
    dec  byte [si+E_TIMER]
.nograce:
    cmp  byte [si+E_STATE], 3
    je   .out
    call EntityWalk
    jmp  .out
.waiting:
    mov  ax, [si+E_X]
    sub  ax, [cam_x]
    cmp  ax, SCREEN_W+16
    jge  .out
    mov  byte [si+E_STATE], 1
    jmp  .out
.flat:
    dec  byte [si+E_TIMER]
    jnz  .out
.remove:
    mov  byte [si+E_TYPE], 0
.out:
    popa
    ret

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

KickShell:
    push ax
    push word 400
    call AddScore
    mov  byte [si+E_STATE], 4
    mov  byte [si+E_TIMER], 8
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

EnemyContact:
    pusha
    cmp  word [vy], 0
    jle  .side
    mov  ax, [prev_ypix]
    add  ax, [mheight]
    mov  bx, [si+E_Y]
    add  bx, 8
    cmp  ax, bx
    jg   .side
    call StompEnemy
    jmp  .out
.side:
    call SideContact
.out:
    popa
    ret

StompEnemy:
    cmp  byte [si+E_STATE], 3
    je   .kick
    cmp  byte [si+E_STATE], 4
    je   .stopshell
    cmp  byte [si+E_TYPE], 1
    je   .flatten
    mov  byte [si+E_STATE], 3
    jmp  .score
.flatten:
    mov  byte [si+E_STATE], 2
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
    mov  word [vy], STOMP_HI
.b2:
    mov  word [yfrac], 0
    mov  byte [on_ground], 0
    mov  ax, [si+E_Y]
    sub  ax, [mheight]
    mov  [ypix], ax
    ret

SideContact:
    cmp  byte [si+E_STATE], 3
    je   .kick
    cmp  byte [si+E_STATE], 4
    jne  .hurt
    cmp  byte [si+E_TIMER], 0
    jne  .out
.hurt:
    call HurtMario
    ret
.kick:
    call KickShell
.out:
    ret

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
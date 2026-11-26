; ============================================================================
; MARIO: input, physics, collision with tiles
; ============================================================================
; MarioInput - horizontal speed, jump, gravity (all 8.8 fixed point)
MarioInput:
    pusha
    mov  bx, WALK_MAX
    cmp  byte [keys+SC_LSHIFT], 0
    je   .lim
    mov  bx, RUN_MAX                ; Left Shift raises the speed limit
.lim:
    mov  ax, [vx]
    cmp  byte [keys+SC_RIGHT], 0
    je   .noright
    cmp  byte [keys+SC_LEFT], 0
    jne  .friction                  ; both held: act as if none
    mov  byte [facing], 0
    mov  cx, ACCEL
    cmp  ax, 0
    jge  .racc
    add  cx, ACCEL                  ; moving left but pressing right = brake harder
.racc:
    add  ax, cx
    cmp  ax, bx
    jle  .storevx
    mov  ax, bx
    jmp  .storevx
.noright:
    cmp  byte [keys+SC_LEFT], 0
    je   .friction
    mov  byte [facing], 1
    mov  cx, ACCEL
    cmp  ax, 0
    jle  .lacc
    add  cx, ACCEL
.lacc:
    sub  ax, cx
    neg  bx
    cmp  ax, bx
    jge  .storevx
    mov  ax, bx
    jmp  .storevx
.friction:                          ; no key: slide to a stop, never past zero
    cmp  ax, 0
    je   .storevx
    jl   .fneg
    sub  ax, FRICTION
    jge  .storevx
    xor  ax, ax
    jmp  .storevx
.fneg:
    add  ax, FRICTION
    jle  .storevx
    xor  ax, ax
.storevx:
    mov  [vx], ax
    ; --- jump: only from the ground, no auto-repeat, no double jump ---
    cmp  byte [keys+SC_SPACE], 0
    je   .nojump
    cmp  byte [jump_ready], 0
    je   .grav
    cmp  byte [on_ground], 0
    je   .grav
    mov  word [vy], JUMP_V
    mov  byte [jump_ready], 0
    mov  byte [on_ground], 0
    jmp  .grav
.nojump:
    mov  byte [jump_ready], 1
    cmp  word [vy], JUMP_CUT        ; Space released while rising fast:
    jge  .grav                      ; cut the speed = smaller jump
    mov  word [vy], JUMP_CUT
.grav:
    mov  ax, [vy]
    add  ax, GRAVITY                ; gravity pulls down every frame
    cmp  ax, MAX_FALL
    jle  .gok
    mov  ax, MAX_FALL               ; terminal velocity
.gok:
    mov  [vy], ax
    popa
    ret

; MarioMoveX - move sideways, then push Mario out of walls
MarioMoveX:
    pusha
    mov  ax, [xfrac]
    add  ax, [vx]
    mov  bx, ax
    sar  bx, 8                      ; whole pixels (signed)
    and  ax, 0FFh
    mov  [xfrac], ax                ; keep the fraction
    add  [xpix], bx
    cmp  word [vx], 0
    je   .out
    jl   .left
    mov  ax, [xpix]
    add  ax, HIT_R-1
    push ax
    call SideHit
    test al, al
    jz   .out
    mov  ax, [xpix]                 ; wall on the right: stand against it
    add  ax, HIT_R-1
    and  ax, 0FFF0h
    sub  ax, HIT_R
    jmp  .stop
.left:
    mov  ax, [xpix]
    add  ax, HIT_L
    push ax
    call SideHit
    test al, al
    jz   .out
    mov  ax, [xpix]                 ; wall on the left
    add  ax, HIT_L
    and  ax, 0FFF0h
    add  ax, 16
    sub  ax, HIT_L
.stop:
    mov  [xpix], ax
    mov  word [vx], 0
    mov  word [xfrac], 0
.out:
    popa
    ret

; MarioMoveY - move up/down, then land on floors or bump the head
MarioMoveY:
    pusha
    mov  ax, [yfrac]
    add  ax, [vy]
    mov  bx, ax
    sar  bx, 8
    and  ax, 0FFh
    mov  [yfrac], ax
    add  [ypix], bx
    cmp  word [vy], 0
    jl   .rising
    call MarioFall
    jmp  .out
.rising:
    call MarioRise
.out:
    popa
    ret

; MarioFall - Mario is falling (or standing): is there floor under his feet?
MarioFall:
    pusha
    mov  byte [on_ground], 0
    mov  cx, [ypix]
    add  cx, [mheight]              ; CX = line just under Mario's feet
    mov  dx, [xpix]
    add  dx, HIT_L
    SOLID dx, cx
    test al, al
    jnz  .land
    mov  dx, [xpix]
    add  dx, HIT_R-1
    SOLID dx, cx
    test al, al
    jz   .out
.land:
    and  cx, 0FFF0h                 ; top of the tile we landed on
    sub  cx, [mheight]
    mov  [ypix], cx
    mov  word [vy], 0
    mov  word [yfrac], 0
    mov  byte [on_ground], 1
    mov  byte [stomp_chain], 0
.out:
    popa
    ret

; MarioRise - Mario is moving up: test head (centre first, then corners)
MarioRise:
    pusha
    mov  byte [on_ground], 0
    mov  si, hx_list
    mov  cx, 3
.hl:
    xor  ah, ah
    mov  al, [si]
    add  ax, [xpix]
    mov  dx, ax
    SOLID dx, word [ypix]
    test al, al
    jnz  .bump
    inc  si
    loop .hl
    jmp  .out
.bump:
    mov  bx, [ypix]
    sar  bx, 4                      ; row of the tile that was hit
    mov  ax, dx
    shr  ax, 4                      ; its column
    push ax
    push bx
    call HitBlock                   ; brick / question block reacts
    inc  bx
    shl  bx, 4
    mov  [ypix], bx                 ; Mario now sits just under the tile
    mov  word [vy], 0
    mov  word [yfrac], 0
.out:
    popa
    ret

; UpdateMario - step 3 of the frame
UpdateMario:
    push ax
    mov  ax, [ypix]
    mov  [prev_ypix], ax            ; needed later for the stomp test
    call MarioInput
    call MarioMoveX
    call MarioMoveY
    pop  ax
    ret

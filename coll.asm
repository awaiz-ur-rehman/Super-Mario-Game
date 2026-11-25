; IsSolid - is the pixel inside a solid tile?  In (stack): x, y  (ret 4)
; Out: AL = 1 solid, 0 not.  Solid tiles are codes 1..10.
IsSolid:
    push bp
    mov  bp, sp
    push word [bp+6]
    push word [bp+4]
    call GetTile
    cmp  al, T_GROUND
    jb   .no
    cmp  al, T_STAIR
    ja   .no
    mov  al, 1
    jmp  .out
.no:
    xor  al, al
.out:
    pop  bp
    ret  4

; SideHit - is there something solid beside Mario at world x?
; In (stack): x  (ret 2).  Tests three heights (top, middle, bottom).
; Out: AL = 1 if solid.
SideHit:
    push bp
    mov  bp, sp
    push bx
    push dx
    mov  bx, [ypix]
    SOLID word [bp+4], bx
    test al, al
    jnz  .out
    mov  dx, [mheight]
    shr  dx, 1
    add  dx, bx
    SOLID word [bp+4], dx
    test al, al
    jnz  .out
    mov  dx, [mheight]
    dec  dx
    add  dx, bx
    SOLID word [bp+4], dx
.out:
    pop  dx
    pop  bx
    pop  bp
    ret  2

; ENEMIES, SHELLS, MUSHROOMS

; Overlap - do the records SI and DI touch?  Out: CF = 1 if yes.
Overlap:
    push ax
    push dx
    mov  ax, [si+E_X]
    sub  ax, [di+E_X]
    cwd
    xor  ax, dx
    sub  ax, dx                     ; |dx|
    cmp  ax, 14
    jae  .no
    mov  ax, [si+E_Y]
    sub  ax, [di+E_Y]
    cwd
    xor  ax, dx
    sub  ax, dx                     ; |dy|
    cmp  ax, 12
    jae  .no
    pop  dx
    pop  ax
    stc
    ret
.no:
    pop  dx
    pop  ax
    clc
    ret


; MARIO MEETS ENEMIES AND ITEMS  (step 5)

; MarioOverlap - does Mario's hit box touch record SI?  Out: CF = 1 if yes
MarioOverlap:
    push ax
    push bx
    mov  ax, [xpix]
    add  ax, HIT_R
    mov  bx, [si+E_X]
    add  bx, 2
    cmp  ax, bx
    jle  .no
    mov  ax, [xpix]
    add  ax, HIT_L
    mov  bx, [si+E_X]
    add  bx, 14
    cmp  ax, bx
    jge  .no
    mov  ax, [ypix]
    add  ax, [mheight]
    mov  bx, [si+E_Y]
    add  bx, 2
    cmp  ax, bx
    jle  .no
    mov  ax, [ypix]
    mov  bx, [si+E_Y]
    add  bx, 16
    cmp  ax, bx
    jge  .no
    pop  bx
    pop  ax
    stc
    ret
.no:
    pop  bx
    pop  ax
    clc
    ret

; CheckDeathAndFlag - step 7: pit, clock, flag pole
CheckDeathAndFlag:
    cmp  word [ypix], 192
    jl   .nopit
    call KillMarioPit
    ret
.nopit:
    cmp  word [time_left], 0
    jne  .noclk
    call KillMario
    ret
.noclk:
    cmp  byte [flag_hit], 0
    je   .out
    call StartWin
.out:
    ret
